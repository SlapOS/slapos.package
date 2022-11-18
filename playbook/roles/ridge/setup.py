from setuptools import setup, find_packages

version = '0.0'
name = 'ridge-tests'

setup(name=name,
      version=version,
      tests_require=['requests'],
      test_suite='tests'
    )
