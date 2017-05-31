#!/bin/bash

BASEDIR=$( cd $(dirname $0) && pwd )
echo "BASEDIR: $BASEDIR"

instance_name=openwrt-${1-instance}
instance_number=${2}

baseimg_pool="srv"
baseimg_name="openwrt.img"
baseimg_format="raw"
baseimg_path=$(virsh vol-path ${baseimg_name} ${baseimg_pool})

net_lan="openvswitch-home"
net_wan="default"

cpu="2,maxvcpus=4"
memory="256,maxmemory=512"

# disk_size="2G"
# disk_format="raw"

# Base Image

if (virsh vol-info --pool ${baseimg_pool} --vol ${baseimg_name} &> /dev/null)
then
  echo "Found existing volume ${baseimg_name} in pool ${baseimg_pool}"
else
  echo "Base image ${baseimg_name} not found in pool ${baseimg_pool}"
  exit 1
fi

# Instances

# -- compute instances names
if test -z "${instance_number}"
then
  instances="${instance_name}"
else
  if [ $((instance_number - 1)) -ge 0 ]
  then
    for i in $(seq -w 00 $((instance_number -1 )))
    do
      instances="${instances} ${instance_name}${i}"
    done
  else
    echo "Wrong arg \"$2\". This should be a posisite integer"
  fi
fi

# -- launch instances
for instance in ${instances}
do

  echo "Creating volume for instance ${instance}"
  virsh vol-clone --pool ${baseimg_pool} ${baseimg_name} ${instance}
  # virsh vol-create-as ${baseimg_pool} ${instance} ${disk_size} --format ${disk_format} --backing-vol ${baseimg_name} --backing-vol-format ${baseimg_format}

  echo "Launching instance ${instance}"
  echo "  disk      : ${baseimg_pool}/${instance}"
  echo "  net lan   : ${net_lan}"
  echo "  net wan   : ${net_wan}"

  virt-install \
    --accelerate \
    --name     "${instance}" \
    --cpu      "host" \
    --vcpus    "${cpu}" \
    --memory   "${memory}" \
    --disk     "bus=virtio,vol=${baseimg_pool}/${instance}" \
    --network  "model=virtio,network=${net_lan}" \
    --network  "model=virtio,network=${net_wan}" \
    --graphics "none" \
    --os-type=linux \
    --import
done
