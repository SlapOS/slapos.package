import os
import pexpect
import re
import subprocess
import sys
import unittest

class TestVifibPlaybook(unittest.TestCase):
  mock_ipv6 = "fd46::1"
  mock_mask = "64"
  playbook = "vifib.yml"
  token = os.environ['SLAPOS_TEST_COMPUTER_TOKEN']

  def mockRe6st(self):
    dir_path = os.path.join('/', 'etc', 're6stnet')
    file_path = os.path.join(dir_path, 're6stnet.conf')
    if not os.path.exists(dir_path):
      os.mkdir(dir_path)
    if not os.path.exists(file_path):
      with open(file_path, 'w') as fh:
        fh.write("")

  def mockIPv6(self):
    subprocess.call(['ip', '-6', 'addr', 'del', '%s/%s' % (self.mock_ipv6, self.mock_mask), 'dev', 'lo'])
    subprocess.check_call(['ip', '-6', 'addr', 'add', '%s/%s' % (self.mock_ipv6, self.mock_mask), 'dev', 'lo'])

  def bootstrapAnsible(self):
    bootstrap_ansible = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ansible-bootstrap')
    subprocess.check_call([bootstrap_ansible])

  def setUp(self):
    self.mockRe6st()
    self.mockIPv6()
    self.bootstrapAnsible()
     
  def getPlaybookFile(self):
    return os.path.realpath(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', self.playbook))

  def getPlaybookCommand(self):
    return "ansible-playbook %s -i hosts --connection=local" % (self.getPlaybookFile())

  def test(self):
    child = pexpect.spawn(self.getPlaybookCommand(), timeout=3600)
    child.logfile = sys.stdout
    
    child.expect(re.compile("What is this computer name?"))
    child.sendline(self.id())
    child.expect(re.compile("Input your slapos token"))
    child.sendline(self.token)
    child.expect(re.compile("Which interface will provide IPv6?"))
    child.sendline("lo")
    child.expect(pexpect.EOF)
    self.fail(self.getPlaybookFile())
