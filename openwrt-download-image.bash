#!/bin/bash

name="openwrt"

download_url="http://downloads.openwrt.org/chaos_calmer/15.05.1/x86/kvm_guest"
download_file="openwrt-15.05.1-x86-kvm_guest-combined-ext4.img.gz"
download_dir="/srv/downloads"

upload_pool="srv" # Pool where we have to upload the volume
upload_vol="openwrt.img" # Name of the volume to upload

# Download file localy

if (test -f "${download_dir}/${download_file}")
then
  echo "File ${download_file} already exists in ${download_dir}"
else
  wget "${download_url}/${download_file}" --directory-prefix "${download_dir}" || exit
fi

# Upload file to a libvirt pool

if (test -f "${download_dir}/${download_file}")
then
  if (virsh vol-info --pool "${upload_pool}" --vol "${upload_vol}" &> /dev/null)
  then
    echo "Volume ${upload_pool}/${upload_vol} already exists"
    exit
  else
    echo "Uploading file ${download_dir}/${download_file} to pool ${upload_pool} as volume ${upload_vol}"
    upload_size=$(stat -Lc%s "${download_dir}/${download_file}")
    virsh vol-create-as --pool "${upload_pool}" --name "${upload_vol}" --capacity "${upload_size}" --format raw

    if [[ "${download_dir}/${download_file}" =~ ".gz" ]]
    then
      virsh vol-upload --pool "${upload_pool}" --vol "${upload_vol}" <(zcat "${download_dir}/${download_file}")
    else
      virsh vol-upload --pool "${upload_pool}" --vol "${upload_vol}" "${download_dir}/${download_file}"
    fi
  fi
fi
