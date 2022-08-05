# README

Easily package your buildout-compiled software!

## Workflow

```
cd obs
source <software_name>/env.sh
make
```

## Add your own software

### Mandatory

Add a directory ```obs/<software_name>```. In this directory you MUST create a file ```env.sh``` (in any shell compatible with bash) where you define and export at least the following variables: ```SOFTWARE_NAME, MAINTAINTER_NAME, MAINTAINER_EMAIL, OBS_USER```.

### Optional

You CAN customize (i.e. define and export) other variables, see the full list of variables you can tweak in ```obs/_generic/build-scripts/00env.sh```.

You CAN also create your own files or templates for compilation and distribution files.
You MUST put them in ```obs/<software_name>/compilation``` and ```obs/<software_name>/distributions```.

The type of customizations include (but are not limited to) the version and Debian revision of the software you compile, the scripts used to compile or install the software, the distribution files like the ```debian/control``` or ```debian/changelot```.
You can see examples in the subdirectories of ```obs/``` except ```_generic```, ```slapos``` and ```re6st```.

### More on compilation files

The ```Makefile``` used by OBS (at the root of the tarball we send) is written in a generic way, you SHOULD NOT override it.
The scripts called by the ```Makefile``` are located in ```obs/<software_name>/compilation/makefile-scripts/``` and you SHOULD write your own (in particular the ```install.sh``` script.

You CAN also write your own buildout files, there is one for the local building when buildout is executed with an internet access, and one for the OBS building without internet access.

### More on distribution files.

You SHOULD add a directory ```obs/distributions/<software_name>/distributions/``` with files for the distributions, as they are hardly generic. There is typically a ```.dsc``` file and a ```debian/``` directory in it.

Please note that this project was developped supporting only one Debian distribution at a time, so it most probably has many limitations, in particular regarding to distributions handling.
You are encouraged to report limitations you run into.
