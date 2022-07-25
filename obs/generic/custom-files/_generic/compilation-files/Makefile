all: build

build: build-stamp
build-stamp:
	@echo Executing makefile-scripts/build.sh
	makefile-scripts/build.sh
	@touch build-stamp

clean:
	@echo Executing makefile-scripts/clean.sh
	makefile-scripts/clean.sh
	rm -f build-stamp

install: all
	@echo Executing makefile-scripts/install.sh
	makefile-scripts/install.sh

.PHONY: build all clean install
