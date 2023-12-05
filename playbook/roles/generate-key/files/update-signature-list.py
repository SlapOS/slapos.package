#!/usr/bin/env python3

import sys

CONF_PATH = "/etc/opt/slapos/slapos.cfg"
signature = """  -----BEGIN CERTIFICATE-----
  MIIFGTCCAwGgAwIBAgIUIuwzV9UdW5E6yaDd7WpOZWtbdqIwDQYJKoZIhvcNAQEL
  BQAwHDEaMBgGA1UEAwwRQW1hcmlzb2Z0QmluYXJpZXMwHhcNMjMxMjA1MTQzNTE4
  WhcNMjQxMjA0MTQzNTE4WjAcMRowGAYDVQQDDBFBbWFyaXNvZnRCaW5hcmllczCC
  AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMVHqNxsaf6EnYoA7P2GUnKX
  USANvqwuBwwwmleUGsiDowr5uML48K4WR47KFZK0qEYiYgOjS3Otf6yfJbkvPNfp
  vnmMO2U9FlZz+P4SkHFztvYl8Q9omPlGxVtsv13PSgoQDB9LKojTK4C2caxbyv8D
  VWU4HENIS49HurebZXUpCF4pxT4BRdf4JUyv4NEcVm2S10Sr6Br594aQ1xO8I+eP
  7VR6+Dlt5DVNdITWEyKFLG72/qb8fXEG4+quCFw5oPj40njGn3vNJDfra9GDqDrL
  kUjmkUrs0Nsq12whgM/1aZW4hHH+tW3VqKJafVpOMPSYgIW7NEEC2GRBEB6C19uz
  hkb4z3xUOTTtp+RpCHpAN+xNmUeT7om5p/OlDTRR/zO9LZyQL+O4ycCpYlEqULtl
  WWMcMJmkO2wJaJGz7dMnwCrJlRbR4VIUN0JTnhVHJuRMFizjSxqW5QzgvkU/wpIu
  BO0Agzzke4Z6E4JGakaMWD3DAIYeVGpOUoBl6rO2Fi06wxpiiA9wEcMd0bJxXq4r
  UWj1CGwV5oPAWIKVW4KEVTyHK9GQJlh1Ib/i8hQ7gwYN6LyfhOInsaGnM8xL01QZ
  5nNwZ6wVw3chEZtXK0T7a1G88heu4ch9RHvteMCBbp0MlNI4zENc7z5ynkkWIcxE
  Qbi4nSFwkS/OGQypdACxAgMBAAGjUzBRMB0GA1UdDgQWBBSKxm/+23gPQ4pag1Op
  fQ5sdA1t8TAfBgNVHSMEGDAWgBSKxm/+23gPQ4pag1OpfQ5sdA1t8TAPBgNVHRMB
  Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4ICAQAoH7zEvI1B5UiZsOByyeveGBdH
  kTKcP/5x6SVHDvCuZVOZxZ3f+Xq1tIXC3v3c1YiX3UqbWDmLl8taSSwlrWb/kAht
  aw/U430ruvvU8v3U6u9rXHeSS9cOokZMYcR1netdU5wXnDKNZPGyavEVT07lMXaU
  8UFqOfDLIMEt12Zcyr+2T1ICjW3jvhnymt/HwcHHDGr/1MlcpPWfcuhPwknqgbLE
  9+VGilx8hJELhf2m66jfEa8QqM1sSlDNVPQ9a1Rgz0a7ApgeOMraAStCJQQ4cJ+q
  91HAcruIDn3K+8waLQIsoYmPVUQLdXT7grWdi4cQIHLUSXTTnVDGJ4jILuTBLrOY
  1gaxYoiiwLXXaXmZB1tNlsSw9Er2hIJE7KYeagR0cXX+xMUINEB867gLcmg2e5jX
  phrK/Hr4+m2EaTawsbdS9rB7zqB/XpgV+PVw2mr59ViO07b2vPSFFPOmbLEJdoOz
  8fZUM8P1LQz8gN5ZOs06s2GXUfgxDfxfXSYPU5rLq8gH8B11KZLScK8giFKLmzCd
  C56hwH7GjzBKuVraPoW0jt2CO+GeiT2K0O2RRvzQ4adjQm2IWwbaNda4iceUUuB7
  YQWar9yH6F1nt6NCe0NWdgjx744zoTq9K6t7VasFNnZq+oBXtWsEhiciutGnPyfI
  kLLMb2ecywxjSs6U5Q==
  -----END CERTIFICATE-----""".split('\n')

def main():

  with open(CONF_PATH, 'r') as f:
    i = 0
    for l in f:
      if i == len(signature):
        return 0
      if signature[i] == l[:-1]:
        i += 1
      else:
        i = 0
  
  conf = []
  
  with open(CONF_PATH, 'r') as f:
    for l in f:
      conf.append(l[:-1])
      if l[:-1] == 'signature-certificate-list = ':
        conf += signature
  with open(CONF_PATH, 'w+') as f:
    f.write('\n'.join(conf))

  return 0

if __name__ == '__main__':
  sys.exit(main())
