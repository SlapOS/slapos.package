import argparse, base64, sys, os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

def decrypt(key, nonce, encrypted_data):
    cipher = Cipher(algorithms.ChaCha20(key, nonce), mode=None)
    return cipher.decryptor().update(encrypted_data)

def main():
    parser = argparse.ArgumentParser(prog='Encrypt data with chacha20')
    parser.add_argument('-d', '--decrypt')
    parser.add_argument('-o', '--out', help='Required for --encrypt and --decrypt')
    parser.add_argument('-n', '--nonce', help='Required for --decrypt')
    parser.add_argument('-k', '--key-file', required=True)
    args = parser.parse_args()

    if args.decrypt:
        if not args.out:
            parser.print_help()
            parser.exit()
        if not args.nonce:
            parser.print_help()
            parser.exit()
        with open(args.key_file, 'rb') as f:
            key = f.read()
        with open(args.decrypt, 'rb') as f:
            encrypted_data = f.read()
        nonce = base64.b64decode(args.nonce.encode())
        data = decrypt(key, nonce, encrypted_data)
        with open(args.out, 'wb+') as f:
            f.write(data)

if __name__ == '__main__':
  sys.exit(main())
