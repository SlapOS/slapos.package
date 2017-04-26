import unittest
import os
import json


class TestSiteStatus(unittest.TestCase):
  """Asserts site status"""
  def setUp(self):
    self.site_status_json = os.environ['TEST_SITE_STATUS_JSON']
    self.status_dict = json.load(open(self.site_status_json))

  def test_build(self):
    """Checks that site was correctly created"""
    # expose output for debugging
    print 'Standard output:'
    print self.status_dict['stdout']
    print 'Standard error:'
    print self.status_dict['stderr']
    # Assert success
    self.assertTrue(self.status_dict['success'])

  def test_build_time_less_6h(self):
    # Check that site was built in less than 6h
    self.assertLess(self.status_dict['duration'], (3600. * 6))
