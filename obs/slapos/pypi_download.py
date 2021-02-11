#!/usr/bin/python3

from pypi_simple import PyPISimple
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("egg")
parser.add_argument("version")
args = parser.parse_args()



with PyPISimple() as client:
  page = client.get_project_page(args.egg)
  for pkg in page.packages:
    #print(pkg.version)
    #print(pkg)
    if pkg.version == args.version and pkg.package_type == 'sdist':
      print(pkg.url)
      exit()


