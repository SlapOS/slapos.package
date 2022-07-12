
This is a work in progress. This document is not in a usable form yet.



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
