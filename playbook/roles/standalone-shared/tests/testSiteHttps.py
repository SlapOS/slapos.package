import requests
import unittest
import os


class TestSiteHttps(unittest.TestCase):
  """Check that configuration generated in the machine works"""
  def setUp(self):
    self.http_url = os.environ['TEST_ACCESS_URL_HTTP']
    self.https_url = os.environ['TEST_ACCESS_URL_HTTPS']

  def test_https_erp5_login_form(self):
    """Check that accessing login_form over HTTPS works"""
    result = requests.get(self.https_url + '/erp5/login_form', verify=False)
    self.assertTrue(result.ok)
    self.assertFalse(result.is_redirect)
    self.assertFalse(result.is_permanent_redirect)
    self.assertEqual(result.status_code, 200)
    self.assertTrue('ERP5 Free Open Source ERP and CRM' in result.text)

  def test_https_erp5(self):
    """Check that accessing site over HTTPS redirects to login_form"""
    result = requests.get(
        self.https_url + '/erp5/', verify=False, allow_redirects=False)
    self.assertTrue(result.ok)
    self.assertTrue(result.is_redirect)
    self.assertFalse(result.is_permanent_redirect)
    self.assertEqual(result.status_code, 302)
    self.assertTrue(result.headers['Location'].endswith('/erp5/login_form'))

  @unittest.skip(
      'Currently HTTPS will reply with "Hostname 172.16.0.9 provided via SNI '
      'and hostname anyhost provided via HTTP are different"')
  def test_https_erp5_anydomain(self):
    """HTTPS: Checks that any domain can be used"""
    result = requests.get(
        self.https_url + '/erp5/', verify=False, allow_redirects=False,
        headers={'Host': 'anyhost'}
        )
    self.assertTrue(result.ok)
    self.assertTrue(result.is_redirect)
    self.assertFalse(result.is_permanent_redirect)
    self.assertEqual(result.status_code, 302)
    self.assertEqual(
        result.headers['Location'],
        'https://anyhost/erp5/login_form'
    )
