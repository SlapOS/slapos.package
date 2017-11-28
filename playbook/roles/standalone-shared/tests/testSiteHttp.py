import requests
import unittest
import os


class TestSiteHttp(unittest.TestCase):
  """Check that configuration generated in the machine works"""
  def setUp(self):
    self.http_url = os.environ['TEST_ACCESS_URL_HTTP']
    self.https_url = os.environ['TEST_ACCESS_URL_HTTPS']
    self.http_url_norm = self.http_url.replace(':10080', '')
    self.https_url_norm = self.https_url.replace(':10443', '')

  def test_http_erp5_login_form(self):
    """Check that accessing site over HTTP redirects to HTTPS"""
    result = requests.get(
        self.http_url + '/erp5/login_form', verify=False,
        allow_redirects=False)
    self.assertEqual(
      dict(
        ok=result.ok,
        is_redirect=result.is_redirect,
        is_permanent_redirect=result.is_permanent_redirect,
        status_code=result.status_code,
        location=result.headers['Location']
      ),
      dict(
        ok=True,
        is_redirect=True,
        is_permanent_redirect=False,
        status_code=302,
        location=self.https_url_norm + '/erp5/login_form'
      )
    )

  def test_http_erp5_anydomain(self):
    """Checks that any domain can be used"""
    result = requests.get(
        self.http_url + '/erp5/', allow_redirects=False,
        headers={'Host': 'anyhost'}
        )
    self.assertEqual(
      dict(
        ok=result.ok,
        is_redirect=result.is_redirect,
        is_permanent_redirect=result.is_permanent_redirect,
        status_code=result.status_code,
        location=result.headers['Location']
      ),
      dict(
        ok=True,
        is_redirect=True,
        is_permanent_redirect=False,
        status_code=302,
        location='https://anyhost/erp5/'
      )
    )