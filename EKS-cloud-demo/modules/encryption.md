# Module 8-3: Compliance and Security-Encryption

**Goal:** Enable wireguard as node to node encryption for data in transit 



## Steps


1. install WireGuard on the default Amazon Machine Image (AMI):
``bash

sudo yum install kernel-devel-`uname -r` -y
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
sudo curl -o /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
sudo yum install wireguard-dkms wireguard-tools -y
``

[Next -> Module 9-1](../modules/dynamic-service-graph.md)

[Previous -> Module 8-2](../modules/intrusion-detection-protection.md)

[Menu](../README.md)