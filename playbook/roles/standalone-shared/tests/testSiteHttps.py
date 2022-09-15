import requests
import unittest
import os
from time import sleep


class TestSiteHttps(unittest.TestCase):
  """Check that configuration generated in the machine works"""
  def setUp(self):
    self.https_url = os.environ['TEST_ACCESS_URL_HTTPS']
    self.https_url_norm = self.https_url.replace(':10443', '')
    self.longMessage = True

  def test_https_erp5_login_form(self):
    """Check that accessing login_form over HTTPS works"""
    result = requests.get(self.https_url + '/erp5/login_form', verify=False)
    self.assertEqual(
      dict(
        ok=result.ok,
        is_redirect=result.is_redirect,
        is_permanent_redirect=result.is_permanent_redirect,
        status_code=result.status_code
      ),
      dict(
        ok=True,
        is_redirect=False,
        is_permanent_redirect=False,
        status_code=200
      ),
      result.content
    )
    self.assertIn('ERP5 Free Open Source ERP and CRM', result.text)

  def test_https_erp5(self):
    """Check that accessing site over HTTPS redirects to login_form"""
    result = requests.get(
        self.https_url + '/erp5/', verify=False, allow_redirects=False)
    self.assertEqual(
      dict(
        ok=result.ok,
        is_redirect=result.is_redirect,
        is_permanent_redirect=result.is_permanent_redirect,
        status_code=result.status_code,
        location=result.headers.get('Location')
      ),
      dict(
        ok=True,
        is_redirect=True,
        is_permanent_redirect=False,
        status_code=302,
        location=self.https_url_norm + '/erp5/login_form'
      ),
      result.content
    )

  def test_https_erp5_auto_configuration_is_successfull(self):
    """
    Check that auto configuration was successfull.
    As it takes certain time for site initialization and installation try
    few times before giving up.
    """
    is_ready = False
    for i in range(60):
      result = requests.get(
          self.https_url + '/erp5/ERP5Site_isReady',
          verify=False,
          allow_redirects=False)
      is_ready = bool(result.content)
      if is_ready:
        # site is prepared
        break
      # give some time
      sleep(120)

    self.assertTrue(is_ready)

  @unittest.skip(
      'Currently HTTPS will reply with "Hostname 172.16.0.9 provided via SNI '
      'and hostname anyhost provided via HTTP are different"')
  def test_https_erp5_anydomain(self):
    """HTTPS: Checks that any domain can be used"""
    result = requests.get(
        self.https_url + '/erp5/', verify=False, allow_redirects=False,
        headers={'Host': 'anyhost'}
        )
    self.assertEqual(
      dict(
        ok=result.ok,
        is_redirect=result.is_redirect,
        is_permanent_redirect=result.is_permanent_redirect,
        status_code=result.status_code,
        location=result.headers.get('Location')
      ),
      dict(
        ok=True,
        is_redirect=True,
        is_permanent_redirect=False,
        status_code=302,
        location='https://anyhost/erp5/login_form'
      ),
      result.content
    )