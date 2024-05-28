#!/usr/bin/env python3

import sys

CONF_PATH = "/etc/opt/slapos/slapos.cfg"
signature = """-----BEGIN CERTIFICATE-----
MIIEDTCCAnWgAwIBAgIUOPXvdYH461MtYKJFh4uf9ANwn5AwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAwwKUmFwaWRTcGFjZTAgFw0yNDA0MTkxMjU0MjNaGA8yMTIy
MTExMjEyNTQyM1owFTETMBEGA1UEAwwKUmFwaWRTcGFjZTCCAaIwDQYJKoZIhvcN
AQEBBQADggGPADCCAYoCggGBAObATKTWgX/3mvapLlrFrlTybAzX2NQqSmjeMrfZ
v/rkGGQzUPVugJ7J8TxDIpaxanDBI0+uIlluGDCVcDh0+jV0xzDOKYGckZqfxcXC
k4RHxIAx2+Z+Y3DCY0QlzEfAyBmsV7U5Xhq6JAcgIIZdc9Fa/lsXJbwgNTQ9F/mx
DfCbN0x/MnAdRHnIWvIhKY3NWEtBPdQvrKAiBYwxXuRE2MYivPHUMWicdAobvVi9
JbXavkmvAQ7lVwOHnRa1I8H+C50RywMdKiW9r5pMlkwu9kdes5a4mVo2wRwoRFNQ
cVh8yHoOg9PNpB5otOjAMazTwZXKVDUxC03LHsBGgEM6y3rtE5fFajvvT0N6/0jR
zJQ+cXNadjevLs9xA94d3VLBZtY1Od9nkyKvZNzu047e/9RGI8lI0eRpbSAWCnE+
p0qDHYaTeT90+Iot/femp+ZG0wNVUNoBkw4jIyatsXRkgFrEVO9chL6FtXgdJH3H
wwus3RT5malA5UZafJTTNrhpyQIDAQABo1MwUTAdBgNVHQ4EFgQUW6DVpr2gLhrr
0vj1o28lBncj8jowHwYDVR0jBBgwFoAUW6DVpr2gLhrr0vj1o28lBncj8jowDwYD
VR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAYEAOgi2NdYRlR7WfNtuUVoq
Yacmmefy9S3si5/hTI0pHuHxAVPYyAYJZJy60bnjxphUF+m5FvErweFVPpkJaUvg
hht23dXUcyYMukDjG2VvJjFcIbfIE9WZFhofN8hGI9PjEFOb98kqexYlCmTN48nP
2EaQ6HC3ZZ6PqKdhCRdWa6MeHSy7UNK+9VKLKbe40sZJRvvgTIazHgb+t+r+qhXi
D9nkcfvvV7BfclKflYrLNLiTcwg8J/gcI2IMbu3lTZyQrYbBCKwxQZGzQfeX1LCV
P26M6mP/wWlo7DrHof/FdJ+Qdr8gUhH59y6vNsofzy4P0oC8GcwcTam7o6FJMC5l
QVWI8zm7G64UGKJBKMoNiP25t1uZzDaJucQAd+4ovsjHctgvcJj8JKzQovIcly+r
PGHKeoTr8UBhoZZxYQTiOO8OK/F0GFfP9OsXoyFp+527X9tezUk28gzmoi7nuaSt
qYacPjDsKHmV1RfQFweSMk57RYN4NRJuHhl1OvY8FafK
-----END CERTIFICATE-----""".split('\n')

def main():

  indentation = "  "

  with open(CONF_PATH, 'r') as f:
    i = 0
    signature_reached = False
    for l in f:
      if i == len(signature):
        return 0
      # Get indentation
      if signature_reached:
        indentation = []
        for c in l:
          if not c.isspace():
            break
          indentation.append(c)
        indentation = ''.join(indentation)
        signature_reached = False
      elif 'signature-certificate-list' == l.split('=')[0].strip():
        signature_reached = True
      # Check if signature is already there
      if signature[i] == l.strip():
        i += 1
      else:
        i = 0
  
  conf = []
  
  with open(CONF_PATH, 'r') as f:
    for l in f:
      conf.append(l[:-1])
      if 'signature-certificate-list' == l.split('=')[0].strip():
        for sl in signature:
          conf.append(indentation + sl)
  with open(CONF_PATH, 'w+') as f:
    f.write('\n'.join(conf))

  return 0

if __name__ == '__main__':
  sys.exit(main())
