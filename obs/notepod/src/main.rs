use std::{
    env, fs, io,
    collections::{BTreeMap,BTreeSet},
    os::unix::process::CommandExt,
    path::PathBuf,
    process::{Command, ExitCode, Stdio},
    str::from_utf8,
};
use nix::unistd::{Group,Uid,User,getgroups,seteuid};
use regex_lite::Regex;
use serde::Deserialize;

#[derive(Deserialize)]
struct BlockDevice<'a> {
    #[serde(rename="type")]
    bdtype: &'a str,
    name: &'a str,
    kname: &'a str,
    pkname: Option<&'a str>,
    mountpoints: Vec<&'a str>,
}
#[derive(Deserialize)]
struct Lsblk<'a> {
    #[serde(borrow)]
    blockdevices: Vec<BlockDevice<'a>>,
}

#[derive(Deserialize)]
struct LuksKDF<'a> {
    #[serde(rename="type")]
    kdf_type: &'a str,
}
#[derive(Deserialize)]
struct LuksKeyslot<'a> {
    #[serde(borrow)]
    kdf: LuksKDF<'a>,
}
#[derive(Deserialize)]
struct LuksToken<'a> {
    #[serde(rename="type")]
    token_type: &'a str,
    keyslots: Vec<&'a str>,
    #[serde(rename="fido2-clientPin-required")]
    fido2_pin_required: Option<bool>,
}
#[derive(Deserialize)]
struct LuksDump<'a> {
    #[serde(borrow)]
    keyslots: BTreeMap<&'a str, LuksKeyslot<'a>>,
    #[serde(borrow)]
    tokens: BTreeMap<&'a str, LuksToken<'a>>,
}

/* This check is only effective once the legitimate system-audit instance is
 * deployed: before that, a malicious SR could break through... but for what?
 * It should be safe for anyone to run this setuid executable and this function
 * is just a safety belt in case we have a bug that could be exploited.
 */
fn check_slappart(s: PathBuf) -> io::Result<bool> {
    let mut seen = false;
    for entry in fs::read_dir("/srv/slapgrid")? {
        let entry = entry?;
        if entry.file_type()?.is_dir() {
            let mut path = entry.path();
            let is_caller = path == s;
            path.push("software_release");
            path.push("buildout.cfg");
            if let Ok(buildout) = fs::read_to_string(path) {
                if buildout.contains("/software/system-audit/software.cfg\n") {
                    if is_caller {
                        seen = true;
                        continue;
                    }
                    return Ok(false);
                }
            }
            if is_caller {
                return Ok(false);
            }
        }
    }
    Ok(seen)
}

fn main() -> ExitCode {
    let uid = Uid::current();
    if !uid.is_root() {
        let Some(slapsoft) = Group::from_name("slapsoft").unwrap() else {
            eprintln!("unknown group slapsoft");
            return ExitCode::FAILURE;
        };
        if !getgroups().unwrap().contains(&slapsoft.gid) || !check_slappart(
                User::from_uid(uid).unwrap().unwrap().dir).unwrap() {
            eprintln!("permission denied");
            return ExitCode::FAILURE;
        }
        // Another safety belt: we'll only switch to uid=0 when needed.
        seteuid(uid).unwrap();
    }

    let fido2_required = {
        let mut args = env::args();
        let arg0 = args.next().unwrap();
        if let Some(arg1) = args.next() {
            args.len() == 0 && arg1 == "--fido2-required" || {
                eprintln!("usage: {arg0} [--fido2-required]");
                return ExitCode::FAILURE;
            }
        } else { false }
    };

    let is_virtual_re = Regex::new(r"^(nbd|zram)\d+$").unwrap();
    let mut plain: Vec<String> = vec![];
    let mut crypted: Vec<(&str, &str)> = vec![];
    let mut crypted_all: BTreeSet<&str> = BTreeSet::new();
    let mut root = false;
    let output = Command::new("/usr/bin/lsblk").args([
        "--json", "-o", "PKNAME,KNAME,NAME,TYPE,MOUNTPOINTS",
        "-Q", "TYPE != \"loop\" && !RM",
        ]).output().unwrap();
    for x in serde_json::from_str::<Lsblk>(from_utf8(&output.stdout).unwrap())
            .unwrap().blockdevices {
        if x.bdtype == "crypt" {
            crypted_all.insert(x.kname);
            crypted.push((x.pkname.unwrap(), x.name));
        } else {
            let mut mountpoints = x.mountpoints;
            if !x.pkname.is_none_or(|x| !crypted_all.contains(x)) {
                crypted_all.insert(x.kname);
            } else if !mountpoints.is_empty() &&  !(
                    is_virtual_re.is_match(x.name) ||
                    mountpoints.contains(&"/boot") ||
                    mountpoints.contains(&"/boot/efi")) {
                mountpoints.sort();
                plain.push(format!("{} ({})", x.name, mountpoints.join(", ")));
            }
            if mountpoints.contains(&"/") {
                root = true;
            }
        }
    }
    if !root {
        plain.push(String::from("? (/)"))
    }
    if !plain.is_empty() {
        eprintln!("unencrypted devices: {}", plain.join(", "));
        return ExitCode::FAILURE;
    }
    let mut fido2: Vec<String> = vec![];
    let mut nopin: Vec<String> = vec![];
    let mut argon2: Vec<String> = vec![];
    let mut other: Vec<String> = vec![];
    for (pkname, name) in &crypted {
        let mut cmd = Command::new("/usr/sbin/cryptsetup");
        unsafe {
            cmd.pre_exec(|| Ok(seteuid(Uid::from_raw(0))?));
        }
        let output = cmd.args([
            "luksDump", "--dump-json-metadata", &("/dev/".to_owned() + pkname)
        ]).stderr(Stdio::inherit()).output().unwrap();
        if !output.status.success() {
            return ExitCode::FAILURE;
        }
        let mut dump: LuksDump = serde_json::from_str(
            from_utf8(&output.stdout).unwrap()).unwrap();
        let mut fido2_pin_required = true;
        for token in dump.tokens.values() {
            if token.token_type == "systemd-fido2" {
                if !token.fido2_pin_required.unwrap_or_default() {
                    fido2_pin_required = false;
                }
                for x in &token.keyslots {
                    dump.keyslots.remove(x);
                }
            }
        }
        (if !fido2_pin_required { &mut nopin }
            else if dump.keyslots.is_empty() { &mut fido2 }
            else if dump.keyslots.values().all(|x|
                x.kdf.kdf_type.starts_with("argon2")
            ) { &mut argon2 } else { &mut other }
        ).push(format!("{pkname} ({name})"));
    }
    if !nopin.is_empty() {
        eprintln!("encrypted devices using a FIDO2 key without pin: {}",
                  nopin.join(", "));
        return ExitCode::FAILURE;
    }
    if !other.is_empty() {
        eprintln!("encrypted devices not using Argon2 algorithm: {}",
                  other.join(", "));
        return ExitCode::FAILURE;
    }
    if !fido2_required {
        fido2.append(&mut argon2);
    } else if !argon2.is_empty() {
        eprintln!("encrypted devices not using a FIDO2 key: {}",
                  argon2.join(", "));
        return ExitCode::FAILURE;
    }
    println!("encrypted devices: {}", fido2.join(", "));
    ExitCode::SUCCESS
}
