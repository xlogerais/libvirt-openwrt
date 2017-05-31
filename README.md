# Libvirt/Openwrt bash helper scripts

## Content

This repository contain bash helper scripts to launch openwrt instances in libvirt.

## Usage

### Install base image

The script **openwrt-download-image.bash** download an official image from the web and upload it to a libvirt pool.

You can edit the script and change the variables "" and "" to choose the libvirt pool and image name.

## Launch an instance

The script **openwrt-launch-instance.bash** launch one or several instances of openwrt in libvirt.

*Usage* : '''openwrt-launch-instance.bash instancename [number of instances]'''

The volume used for the instance is cloned from the base volume.
