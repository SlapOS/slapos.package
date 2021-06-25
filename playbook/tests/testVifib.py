import os
import pexpect
import subprocess
import unittest

class TestVifibPlaybook(unittest.TestCase):
  mock_ipv6 = "fd46::1"
  mock_mask = "64"

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

  def setUp(self):
    self.mockRe6st()
    self.mockIPv6()
     
  def test(self):
    self.fail('hi!')
