#!/bin/sh
mv /home/nxdlap /home/nxdlap.`date '+%Y%m%d%H%M%S'`
mkdir -p /home/nxdlap
chown nxdlap:nxdlap /home/nxdlap
