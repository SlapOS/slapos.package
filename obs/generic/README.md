# README

**WARNING**: This project is a **work in progress** (WIP)!

## What is it
### In short
Here we turn a *software release* (SR) or a *buildout.cfg* into a *Linux package* thanks to *OBS*! It is not that simple though and you will have to read a bit on how it works before you can get your package.

### Workflow (short version)
1. Set you OBS repository.

2. Adapt *build-scripts/configure_release.sh*

3. Run ```make```

### How?
#### 1. OBS Repository
Sorry but first you will have to read this
>https://en.opensuse.org/openSUSE:Build_Service_Tutorial

and follow the "command-line" instructions. So you will have to install this (the *osc* command)
>https://en.opensuse.org/openSUSE:OSC

Advice: to install *osc*, if you are working at Nexedi or whatever affiliated company, you should probably go to
>https://github.com/openSUSE/osc

and follow the installation instructions. They are slightly broken... You may have to install some dependencies:
```
sudo apt install git pip
pip install distutils.core
```
and then to execute the instructions modified as follows:
```
python3 setup.py build
sudo python3 setup.py install
ln -s `pwd`/osc-wrapper.py /usr/bin/osc
# add "3" at the end of the first line (python -> python3)
sed -i "1 s/$/3/" osc-wrapper.py
```

You should checkout (```osc co <home-project> <package>```) in the root directory of this project. So after that, along with *Makefile* and *README.md*, you should have a directory *home-project* with a directory *package* inside.

Don't cheat! If you don't create them with ```osc``` it won't work...

### 2. Adapt *build-scripts/configure_release.sh*

[TODO: describe the needed adaptations]

### 3. Run ```make```
Simply run ```make```. More explanations at section [TODO: section]

Good luck!

Some advices though: [TODO: give some tips to get the logs, etc.]


[TODO: Reorganize the rest]

### Tarballs
The *\<tarball\>* directory to be archived and sent to OBS is to be prepared in tarballs/*\<tarball\>*.

### Templates
The *templates/* directory contains the templates used during first local run of buildout and to prepare the templates to be sent to OBS.

### Distribution specifics
The *distribution-specifics/* directory contains the files needed to build a package in a given distribution. Currently only Debian is supported and the files are in the minimal possible stage. Do not rely solely on them for a serious build.

### Packaging with OBS
Currently, only Debian is supported.
The OBS directory is prepared with obs.sh and the temporary files created for it are cleaned with clean_obs.sh. The scripts assume you already checked out your OBS project.

#### Debian
The *debian/* directory provides only the bare minimum for a package to be built. For more support you will have to add it yourself.

### Complete process
#### Workflow preparation workflow
``` # block of code
make
```
or
```
./build_tree.sh
./tempate_stage.sh
./bootstrap_buildout.sh
./obs.sh
```

#### Clean workflow
```
make clean
```
or
```
./clean_build_tree.sh
./clean_template_stage.sh
./clean_bootstram_buildout.sh
./clean_obs.sh
```


------------------
TMP
------------------

This package aims at minimizing efforts when turning a simple set of buildout.cfg files into something OBS-compatible in order to build a package. It provides a set of scripts and some additional files to ease the process.


The main goal is to prepare a tarball usable with the make/make install workflow. Then it is sent to OBS along with some *.spec* files. *.spec* files are used to actually package the tarball and are often specific to the distribution one wants to build a package for.
