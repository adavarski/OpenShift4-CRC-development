TBD
https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.2.0/crc-linux-amd64.tar.xz
https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.2.0/crc_virtualbox_4.2.8.crcbundle

Get: https://cloud.redhat.com/openshift/install/crc/installer-provisioned
Unzip crc 

crc start --vm-driver virtualbox --bundle PATH/crc_virtualbox_4.2.8.crcbundle --pull-secret-file PATH/pull-secre/t.txt
