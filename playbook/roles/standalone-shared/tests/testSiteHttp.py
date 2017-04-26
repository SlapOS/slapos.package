import requests
import unittest
import os


class TestSiteHttp(unittest.TestCase):
  """Check that configuration generated in the machine works"""
  def setUp(self):
    self.http_url = os.environ['TEST_ACCESS_URL_HTTP']
    self.https_url = os.environ['TEST_ACCESS_URL_HTTPS']

  def test_http_erp5_login_form(self):
    """Check that accessing site over HTTP redirects to HTTPS"""
    result = requests.get(self.http_url + '/erp5/login_form', verify=False)
    self.assertTrue(result.ok)
    self.assertTrue(result.is_redirect)
    self.assertTrue(result.is_permanent_redirect)
    self.assertEqual(result.status_code, 302)
    self.assertTrue(result.headers['Location'].endswith('/erp5/login_form'))
    self.assertTrue(result.headers['Location'].startswith('https://'))
