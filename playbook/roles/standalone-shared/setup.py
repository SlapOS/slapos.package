from setuptools import setup, find_packages

version = '0.0'
name = 'standalone-shared-tests'

setup(name=name,
      version=version,
      packages=[],
      tests_require=['requests'],
      test_suite='tests'
    )
