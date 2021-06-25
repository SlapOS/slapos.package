from setuptools import setup, find_packages

version = '0.0'
name = 'playbook-tests'

setup(name=name,
      version=version,
      tests_require=['pexpect'],
      test_suite='tests'
    )
