#!/usr/bin/python
# -*- coding: utf-8 -*-
##############################################################################
#
# Copyright (c) 2012-2014 Vifib SARL and Contributors.
# All Rights Reserved.
#
# WARNING: This program as such is intended to be used by professional
# programmers who take the whole responsibility of assessing all potential
# consequences resulting from its eventual inadequacies and bugs
# End users who are looking for a ready-to-use solution with commercial
# guarantees and support are strongly advised to contract a Free Software
# Service Company
#
# This program is Free Software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
##############################################################################

import datetime
import logging
from optparse import OptionParser, Option
import sys
from base_promise import Config
from promise import promise_list
import os

class Parser(OptionParser):
  """
  Parse all arguments.
  """
  def __init__(self, usage=None, version=None):
    """
    Initialize all options possibles.
    """
    OptionParser.__init__(self, usage=usage, version=version,
                      option_list=[
        Option("--slapos-configuration",
               default='/etc/opt/slapos/update.cfg',
               help="Path to slapos configuration file"),
        Option("--key",
               default="slapos-generic-key",
               help="Upgrade Key for configuration file"),
        Option("--slapos-location",
               default="/opt/slapos",
               help="SlapOS binaries are location"),
        Option("--cron-file",
               default="/etc/cron.d/slappkg-update",
               help="Cron configuration file path"),
        ])

  def check_args(self):
    """
    Check arguments
    """
    (options, args) = self.parse_args()
    return options

def get_template(name):
 
  fd = open('/'.join(__file__.split('/')[:-1]) + '/template/%s' % name, "r")
  try:
    content = fd.read()
  finally:
    fd.close()

  return content

import os, errno

def mkdir_p(path):
  import pdb;pdb.set_trace()
  if not os.path.exists(path):
    os.makedirs(path)
  
def create(path, text=None, mode=0666):
  fd = os.open(path, os.O_CREAT | os.O_WRONLY | os.O_TRUNC, mode)
  try:
    os.write(fd, text)
  finally:
    os.close(fd)

def do_conf():
  """Generate Default Configuration file """
  usage = "usage: %s [options] " % sys.argv[0]
  run_config(Config(Parser(usage=usage).check_args()))

def run_config(config):
  if os.path.exists(config.slapos_configuration):
    raise ValueError("%s already exists!" % config.slapos_configuration)

  mkdir_p('/'.join(config.slapos_configuration.split('/')[:-1]))

  configuration_content = get_template("update.cfg.in")
  create(path=config.slapos_configuration, 
         text=configuration_content % {"upgrade_key": config.key})

  configuration_content = get_template("update.cron.in")
  create(path=config.cron_file,
         text=configuration_content % {
                "configuration_path": config.slapos_configuration,
                "slapos_location": config.slapos_location
        })

  sys.exit()
