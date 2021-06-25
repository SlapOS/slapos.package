import os
import pexpect
import re
import subprocess
import sys
import unittest


class TestVifibPlaybook(unittest.TestCase):
  mock_ipv6 = "fd46::1"
  mock_mask = "64"
  playbook = "vifib.yml"
  token = os.environ['SLAPOS_TEST_COMPUTER_TOKEN']

  def mockRe6st(self):
    dir_path = os.path.join('/', 'etc', 're6stnet')
    file_path = os.path.join(dir_path, 're6stnet.conf')
    if not os.path.exists(dir_path):
      os.mkdir(dir_path)
    if not os.path.exists(file_path):
      with open(file_path, 'w') as fh:
        fh.write("")

  def mockIPv6(self):
    subprocess.call([
      'ip', '-6', 'addr', 'del', '%s/%s' % (
        self.mock_ipv6, self.mock_mask), 'dev', 'lo'])
    subprocess.check_call([
      'ip', '-6', 'addr', 'add', '%s/%s' % (
        self.mock_ipv6, self.mock_mask), 'dev', 'lo'])

  def bootstrapAnsible(self):
    bootstrap_ansible = os.path.join(
      os.path.dirname(os.path.realpath(__file__)), 'ansible-bootstrap')
    subprocess.check_call([bootstrap_ansible])

  def getPlaybookFile(self):
    return os.path.realpath(
      os.path.join(
        os.path.dirname(os.path.realpath(__file__)), '..', self.playbook))

  def getPlaybookCommand(self):
    return "ansible-playbook %s -i hosts --connection=local" % (
      self.getPlaybookFile(),)

  def runPlaybook(self):
    child = pexpect.spawn(self.getPlaybookCommand(), timeout=3600)
    child.logfile = sys.stdout  # XXX fetch data for test result
    child.expect(re.compile("What is this computer name?"))
    child.sendline(self.id())
    child.expect(re.compile("Input your slapos token"))
    child.sendline(self.token)
    child.expect(re.compile("Which interface will provide IPv6?"))
    child.sendline("lo")
    child.expect(pexpect.EOF)

  def setUp(self):
    return  # XXX
    self.mockRe6st()
    self.mockIPv6()
    self.bootstrapAnsible()
    self.runPlaybook()

  def assertSlaposCfg(self):
    with open('/etc/opt/slapos/slapos.cfg') as fh:
      slapos_cfg_list = [q.strip() for q in fh.readlines()]

    self.assertIn('create_tap = True', slapos_cfg_list)
    self.assertIn('interface_name = lo', slapos_cfg_list)
    self.assertIn('partition_amount = 10', slapos_cfg_list)
    self.assertFalse(any([
      q.startswith('shared_part_list') for q in slapos_cfg_list]))

  def assertPackage(self, package):
    self.assertTrue(
      subprocess.call([
        'dpkg', '-s', package],
       stdout=subprocess.PIPE, stderr=subprocess.STDOUT) == 0,
      "Package %r is not present" % (package,)
    )

  def assertKvmNested(self):
    nested_list = []
    for kvm in ['kvm_intel', 'kvm_amd']:
      path = '/sys/module/%s/parameters/nested' % (kvm,)
      if os.path.exists(path):
        with open(path) as fh:
          nested_list.append(fh.read().strip() == '1')
    self.assertTrue(all(nested_list))

  def assertUserCrontab(self):
    with open('/var/spool/cron/crontabs/root') as fh:
      crontab = fh.readlines()
      crontab = ''.join(crontab[3:])
    self.assertEqual(
      crontab.strip(),
      """
#Ansible: ip6tables at reboot
@reboot sleep 20 && /usr/bin/re6stnet-ip6tables-check
#Ansible: Launch Startup with ansible
@reboot cd /opt/upgrader/playbook && ansible-playbook vifib-startup.yml -"""
      """i hosts 2>>/opt/upgrader/startup.log >> /opt/upgrader/startup.log
#Ansible: fstrim
@weekly /sbin/fstrim -a
#Ansible: Launch Upgrader with ansible
0 */3 * * * rm -rf /opt/upgrader/playbook && cp -R /opt/upgrader/playbook-t"""
      """mp /opt/upgrader/playbook && cd /opt/upgrader/playbook && PATH=/us"""
      """r/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin ansible-"""
      """playbook upgrader-run.yml --extra-vars "upgrader_playbook=vifib-up"""
      """grade.yml upgrade_kernel=False" -i hosts 2>>/opt/upgrader/latest_u"""
      """pgrade.log >> /opt/upgrader/latest_upgrade.log""".strip()
    )

  def assertSlaposLimits(self):
    with open('/etc/security/limits.d/slapos.conf') as fh:
      slapos_limit = ''.join([
        q for q in fh.readlines() if not q.startswith('#') and q.strip()])
    self.assertEqual(
      slapos_limit.strip(),
      """
root             hard    nofile          1048576
root             hard    memlock         65536
root             soft    nofile          65536""".strip()
    )

  def test(self):
    self.assertSlaposCfg()
    self.assertEqual(
      oct(os.stat('/dev/kvm').st_mode),
      '020666'
    )
    self.assertPackage('slapos-node')
    self.assertPackage('re6st-node')
    self.assertKvmNested()
    self.assertUserCrontab()
    self.assertSlaposLimits()
