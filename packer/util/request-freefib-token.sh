#!/bin/bash

# This script with the values bellow only works for slapos.vifib.com.
slapos request FREEFIB-TOKEN-$1 product.re6st --type default --slave --node instance_guid=SOFTINST-76379
