import unittest
import datetime
import os
import json


class TestSiteStatus(unittest.TestCase):
  """Asserts site status"""
  def setUp(self):
    self.site_status_json = os.environ['TEST_SITE_STATUS_JSON']
    with open(self.site_status_json) as f:
      self.status_dict = json.load(f)

  def test_build(self):
    """Checks that site was correctly created"""
    # expose output for debugging
    print('Standard output:')
    print(self.status_dict['stdout'])
    print('Standard error:')
    print(self.status_dict['stderr'])
    self.assertTrue(self.status_dict['success'])

  def test_build_time(self):
    """Asserts that site was built in acceptable time"""
    self.assertLess(
      self.status_dict['duration'],
      datetime.timedelta(hours=13).total_seconds())
