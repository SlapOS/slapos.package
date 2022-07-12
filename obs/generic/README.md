# README

## What is it
### In short
Here we turn a *buildout* file or set or files (e.g. *buildout.cfg*, or *software.cfg*) into a *Debian package* thanks to *OBS*! It is not that simple though and you will have to read a bit on how it works before you can get your package.

Note: It is possible to use this project as a starting point to build packages for non Debian-like distributions, but it is not documented at the moment. You might want to read about "spec files" and use them in ```distribution-specifics/```.

### Workflow (short version)
1. Set you OBS repository.

2. Adapt some files.

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

You should checkout (```osc co <home-project> <package>```) in the root directory of this project. So after that, along with *Makefile* and *README.md*, you should have a directory ```<home-project>``` with a directory <```package>``` inside.

Don't cheat! If you don't create them with ```osc``` it won't work...

### 2. Adapt some files.

#### In ```build-scripts/```

The scripts in ```build-scripts``` are those who run the project. Every time you use this project, you will have to modify ```build-scripts/00env.sh```:
1. The software name and versions: ```$SOFTWARE_VERSION```, ```$DEBIAN_VERSION```, ```$SOFTWARE_NAME```
2. The directory where the software should be installed: ```$TARGET_DIR```
3. Your buildout file or the entry point of you buildout files: ```$BUILDOUT_ENTRY_POINT```.

To automatically get you buildout file(s), you can use ```git clone```, which is the default in ```build-scripts/10build_tree.sh```. If you want to use something else, please modify this script. For instance, you can copy a local directory as suggested in the comments of the script.

#### The compilation files

For this project to work with OBS, you will need a *Makefile* and a *buildout wrapper* in the tarball sent to OBS. They are created from templates, see ```templates/compilation-templates/``` for the templates and ```build-scripts/20compilation_templates.sh``` for the workings.

If you do nothing, the templates from ```_generic``` will be used. You can create you own by adding a directory there with the same name as ```$SOFTWARE_NAME``` in ```build-scripts/00env.sh```.

#### The distribution files

In order to build a package, OBS uses distribution files. They are created from templates, see ```templates/distribution-templates/``` for the templates and ```build-scripts/50distrib_files.sh``` for the workings.

At the moment, the supported distributions are only the different Debian versions, and you can only use one of them at a time. It should not take too much effort to adapt ```build-scripts/50distirb_files.sh``` for it to support more Linux distributions.

If the templates do not suit you, you can directly create a directory in ```distribution-specifics/``` with the same name as ```$SOFTWARE_NAME``` in ```build-scripts/00env.sh```. For instance, there is obviously no generic version of *post-install scripts* and if your package need some, you will have write them from scratch yourself.


### 3. Run ```make```

Simply run ```make```.

The processing is separated in stages for more advanced uses and debugging.

In particular, you can run ```make build``` and then use the same instance of this project to work on another packaging while buildout is compiling things locally. For instance you can run several compilation in parallel by running ```make build```, wait for the buildout program to be run, and then change the name and versions in ```build-scripts/00env.sh``` and run ```make build``` again. Run ```make after_build``` to finish the process when a ```make build``` command is done.

Note: The script are numbered in order to make it more easy for the user to follow the various steps of the processing, but there is no automation for running additionnal scripts even if they are numbered too. You can of course add scripts but you will have to add them in the ```Makefile``` yourself.

A last useful advice! The first thing done in the *Makefile target* ```after_build``` is to backup the directory in which buildout has compiled everything. The backup of ```tarballs/<SOFTWARE_AND_VERSION>``` is done in ```tarballs/backup.<SOFTWARE_AND_VERSION```.


Good luck!

