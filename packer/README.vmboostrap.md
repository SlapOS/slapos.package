vm-bootstrap Image
==================

packer vm-boostrap image contain a vm-bootstrap script (see: scripts/vm-bootstrap.sh) which will run in specific bootstrap script when VM boot for the first time.

How to build VM with differents images size?
--------------------------------------------

1) Install Packer locally by https://www.packer.io/downloads.html, like (exemple):



    mkdir /opt/packer/
    cd /opt/packer/
    wget https://releases.hashicorp.com/packer/1.10.1/packer_1.10.1_linux_amd64.zip
    unzip packer_1.10.1_linux_amd64.zip
    PATH=/opt/packer:$PATH packer plugins install github.com/hashicorp/qemu

2) Check and install qemu

  Packer use qemu to build vm images, you need to install it first.

  apt-get install qemu-system-x86


3) Use ansible to build all VMs and compress them in local folder

  ansible-playbook build-vm-bootstrap.yml -i hosts


  After build, images are generated in folder output-DISTRO-XXG-vm-boostrapn, they are gziped to reduce the size when downloading images.
  The file SHA512SUM.txt contain the SHA512SUM of each vm image.
  The file MD5SUM.txt contain the MD5SUM of each vm image.


How to upload images to shacache
--------------------------------

  To build and upload images to shacache, use this ansible command
  
  UPLOAD=yes ansible-playbook build-vm-bootstrap.yml -i hosts
  
  A file URL.txt will be generated with url as well as MD5SUM to download each image from shacache.


How to use Images
-----------------

Boostrap script is downloaded into the VM from a static URL http://10.0.2.100/vm-bootstrap. The script will be executed until it succeed (exit with 0) or until the maximum execution count is reached. By default, the maximum exucution number is 10. To change this value you can write the new value in /root/bootstrap/bootstrap-max-retry.

    #!/bin/bash
    echo 1 > /root/bootstrap/bootstrap-max-retry

    echo "Starting my custom bootstrap commands..."
    ....

To disable bootstrap script execution, remove /root/bootstrap/start-bootstrap from the vm:

    #!/bin/bash
    # temporarily disable bootstrap until XX
    rm -f /root/bootstrap/start-bootstrap

    ...

If no bootstrap script is provided to the vm, an empty script will be generated and will be executed until bootstrap-max-retry=10.

Bootstrap logs are written into file /var/log/vm-bootstrap.log

How boostrap script is downloaded
----------------------------------

Bootstrap script called 'vm-bootstrap' should be placed in and external http server and qemu will be launched with 'guestfwd' option:

    qemu -net 'user,guestfwd=tcp:10.0.2.100:80-cmd:netcat server_ip server_port'

for more information, see qemu 'user network' documentation.

