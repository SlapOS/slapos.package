import unittest
import os

class TestLogFileCreated(unittest.TestCase):
  def test_log_file_exists(self):
    """Check that MCA created its log file."""
    self.assertTrue(os.path.isfile("/var/log/metadata_collect.log"))
