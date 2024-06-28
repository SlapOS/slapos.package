#!/usr/bin/make -f
# -*- makefile -*-

build: 
	make -C slapos build SLAPOS_BOOTSTRAP_SYSTEM_PYTHON=$(shell which python3 2> /dev/null || echo python2.7)

all: build

install: all
	make -C slapos install
	mkdir -p $(DESTDIR)/usr/bin/
	cp $(DESTDIR)/opt/slapos/bin/slapos $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/etc/opt/slapos/
	mkdir -p $(DESTDIR)/etc/firewalld/
	cp -R $(DESTDIR)/opt/slapos/parts/firewalld/etc/firewalld/* $(DESTDIR)/etc/firewalld/
	mkdir -p $(DESTDIR)/opt/slapos/parts/dbus/var/run/dbus
clean:
#	cd slapos; make clean
