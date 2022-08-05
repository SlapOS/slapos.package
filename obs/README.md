# README

Easily package your buildout-compiled software!

## Workflow

```
make NAME=<software_name>
```
or
```
make <software_name>
```

## Add your software

This is strongly recommended as the default parameters are really limited.
In order to add your software to the project, you will have to add at least one file, and probably a bit more.

Please also note that this project was developped using only one Debian distribution, so it most probably has many limitations, in particular regarding to distributions handling.
You are encouraged to report limitations you run into.

### Create your environment (strongly recommended)

Create a file ```build-scripts/custom-env/<software-name>_env.sh```.
You should at least assign the variables
- ```MAINTAINER_NAME```
- ```MAINTAINER_EMAIL```
- ```SOFTWARE_VERSION```
- ```DEBIAN_REVISION```

You can assign any other variable defined in ```build-scripts/00env.sh```, it will be overriden.
In particular, you should have a look at
- ```TARGET_DIR```
- ```SOFTWARE_NAME```
- any variable under the ```DISTRIBUTIONS INFORMATION``` section
- some variables under the ```BUILDOUT FILES AND VERSIONS``` section
- most variables under the ```OBS INFORMATION``` section

### Additional files

In the following sections, you will read what additional custom files can be added.
The general working is as follow:
- There is a ```_generic``` directory from where some templates are applied and some files are copied.
The directory processing preserves the directory tree.
- You can add a directory named ```<software_name>``` alongside.
Whatever template in it will be applied (any file with a ```.in``` extension is considered a template) and whatever file in it will be copied.
It must follow the same directory tree as ```_generic```.
- You can also add a directory specific to a software version ```<software_name>_<compound_version>``` (for more information on version numbering, see the comments in ```build-scripts/00env.sh```).

In case of conflict, files from ```<software_name>_<compound_version>``` override files from ```<software_name>``` which override files from ```_generic```.

### Add your compilation files (recommended)

You can add a directory ```additional-files/compilation/<software-name>```.
You can add your own buildout wrapper files, your own makefile-scripts and environment.
You may add your own ```Makefile``` or ```Makefile.in``` but this practice is discouraged.
You should contribute upstream if the current Makefile pattern does not suit your needs.

### Add your distributions files (recommended)

You should add a directory ```additional-files/distributions/<software-name>``` as the current templates are very unlikly to cover your use case.

### Add ```Makefile``` targets (optional)

Add targets in ```Makefile``` based on the existing one.
This is simply for convenience as a short cut to ```make NAME=<software_name>``` and for auto-completion.
