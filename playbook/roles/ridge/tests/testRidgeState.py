import unittest
import os
import json

class TestRidgeState(unittest.TestCase):
  def test_task_state(self):
    site_status_json = os.environ['TEST_SITE_STATUS_JSON']
    with open(site_status_json) as f:
      status_dict = json.load(f)
    self.assertTrue(status_dict['success'], status_dict)
