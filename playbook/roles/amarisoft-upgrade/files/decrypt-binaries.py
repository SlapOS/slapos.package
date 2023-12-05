#!/usr/bin/env python3

from cryptography.fernet import Fernet
import argparse
import sys

def load_key(keyfile):
  with open(keyfile, 'br') as f:
    key = f.read()
  return Fernet(key)

def decrypt(k, filein, fileout):
  with open(filein, 'br') as f:
    encrypted_data = f.read()
  with open(fileout, 'bw') as f:
    f.write(k.decrypt(encrypted_data))

def main():

  parser = argparse.ArgumentParser(prog='Decrypt binaries')
  parser.add_argument('keyfile')
  parser.add_argument('infile')
  parser.add_argument('outfile')

  args = parser.parse_args()

  k = load_key(args.keyfile)
  decrypt(k, args.infile, args.outfile)

  return 0

if __name__ == '__main__':
  sys.exit(main())
