# Kubernetes CKA, CKAD, CKS Practice Environment with Vagrant

## Overview
This repository offers a comprehensive setup for practicing for the CKA, CKAD, CKS exams using Vagrant. It automates the deployment of a Kubernetes cluster, closely mirroring the Killer.sh environment, and is designed for ease of maintenance and compatibility with various systems. For use with [Kubernetes CKS Killer.sh Course](https://youtu.be/d9xfB5qaOfg)

## Features
- **Automated Kubernetes Cluster Setup**: Utilize Kubeadm to automate the creation of a Kubernetes cluster for CKA, CKAD, and CKS exam practice.
- **Platform Compatibility**: Supports both x86_AMD64 with VirtualBox or Apple Silicon (M1/M2) with VMware Fusion.
- **Customizable Cluster Versions**: Easily deploy clusters with the latest or specific previous versions of Kubernetes.
- **Resource Management**: Includes Vagrant Disksize plugin support for adjusting VM disk sizes as needed.
- **Practice-Oriented Configuration**: Tailored configurations and security settings for realistic CKA, CKAD, CKS exams practice.

## Prerequisites
- [Vagrant](https://www.vagrantup.com/) installed and up-to-date.
- [Vagrant Disksize plugin](https://github.com/sprotheroe/vagrant-disksize) for disk size adjustments.
- Apple Silicon
   - [VMware Fusion](https://www.vmware.com/products/fusion.html)
   - [Vagrant VMware Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility) for Apple Silicon support.
- x86_AMD64
   - [VirtualBox](https://www.virtualbox.org/)

## Setup Instructions
1. **Installation**:
   - [Install Brew](https://brew.sh/)
   - Run `brew update` to refresh the list of available packages
   - [Install Vagrant](https://www.vagrantup.com/docs/installation) Run `brew install hashicorp-vagrant`
   - [Vagrant Disksize plugin](https://github.com/sprotheroe/vagrant-disksize). Run `vagrant plugin install vagrant-disksize`
   - Apple Silicon
      - Install [VMware Fusion](https://www.vmware.com/products/fusion.html). Run `brew install --cask vmware-fusion`
      - Install [Vagrant VMware Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility). Run `brew upgrade vagrant-vmware-utility`
   - x86_AMD64
      - Install [VirtualBox](https://www.virtualbox.org/). Run `brew install --cask virtualbox`
3. **Deployment**:
   - Use provided script to deploy the Kubernetes cluster run `./deploy-latest.sh`.
5. **Clean Up**:
   - Remove all VMs and resources run `./cleanup.sh` after practice sessions.

## Usage
- **Deploy Latest Kubernetes Cluster**: `./deploy-latest.sh`
- **Deploy Previous Version Kubernetes Cluster**: `./deploy-previous.sh`
- **Clean Up Resources**: `./cleanup.sh`

## Supported Platforms
- x86_AMD64 (VirtualBox)
- Apple Silicon (M1/M2 with VMware Fusion)

## License
This project is licensed under the MIT License. See LICENSE.md for more details.

---
