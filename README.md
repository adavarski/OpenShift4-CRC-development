
## OpenShift 4 Development Environment (CRC based): 

- Setup CodeReady Containers (CRC) on Laptop (ubuntu)
- Setting up CodeReady Containers (CRC) on a Remote Server (ubuntu) and Remote Access to CRC (remote OpenShift 4 development environment) from Laptop
- OpenShift 4 (CRC) Playground

### 1.Setup Local OpenShift 4.x Cluster with CodeReady Containers

CRC will host your applications. CodeReady Containers brings a minimal, preconfigured OpenShift 4.x cluster to your local Laptop/Workstattion without the need for a server-based infrastructure.

CodeReady Containers requires the following minimum hardware and operating system requirements.

- 4 virtual CPUs (vCPUs)
- 9 GB of memory
- 35 GB of storage space

Pre: Install Ubuntu/Linux Mint 20.1 on your laptop (16G RAM recomeended; 9G requered for CRC) 

Register RH account for Red Hat CodeReady Containers(CRC) download and get pull secrets file (Note that a valid OpenShift user pull secret is required during installation. The pull secret can be copied or downloaded from the Pull Secret section of the Install on [Laptop: Red Hat CodeReady Containers](https://cloud.redhat.com/openshift/install/crc/installer-provisioned) page on cloud.redhat.com.) 

```
### Install required software packages
$ echo "$USER ALL=(ALL) NOPASSWD:ALL"|sudo tee -a /etc/sudoers
$ sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system network-manager dnsmasq
```

Download CRC and pull-secret in OPENSIFT directory:

```
$ mkdir OPENSHIFT && cd OPENSHIFT/
$ wget https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.25.0/crc-linux-amd64.tar.xz
$ tar -xJf ./crc-linux-amd64.tar.xz
### Place the binaries in your $PATH using .bash_profile
$ echo "export PATH=/home/davar/OPENSHIFT/crc-linux-1.25.0-amd64:/home/davar/.crc/bin/oc:$PATH" >> ~/.bash_profile
$ source ~/.bash_profile 
### Place the binaries in your $PATH PATH using .bashrc
$ vim ~/.bashrc
export PATH="~/.crc/bin:$PATH"
eval $(crc oc-env)
$ source ~/.bashrc 
```
Setup CRC:
```
### Check memory
$ vmstat -s
     16283144 K total memory
      9942484 K used memory
     10742588 K active memory
$ crc config set memory 12288
$ crc config set consent-telemetry no
$ crc config set pull-secret-file ~/OPENSHIFT/pull-secret.txt
Successfully configured pull-secret-file to /home/davar/OPENSHIFT/pull-secret.txt
- consent-telemetry                     : no
- memory                                : 12288
- pull-secret-file                      : /home/davar/OPENSHIFT/pull-secret.txt

### Deploy CodeReady Containers virtual machine
$ crc setup
$ crc start

#### Check CRC/Confirm installation:

$ host -R 3 api.crc.testing
api.crc.testing has address 192.168.130.11
$ virsh list
$ virsh net-list
$ ip a s
$ sudo iptables -n -L
$ crc status
$ crc version
$ ssh -i ~/.crc/machines/crc/id_ecdsa core@"$(crc ip)" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  -- systemctl list-unit-files --state=failed --all


### Check inside CRC VM
$ ssh -i ~/.crc/machines/crc/id_ecdsa core@"$(crc ip)"
Red Hat Enterprise Linux CoreOS 47.83.202103292105-0
  Part of OpenShift 4.7, RHCOS is a Kubernetes native operating system
  managed by the Machine Config Operator (`clusteroperator/machine-config`).

WARNING: Direct SSH access to machines is not recommended; instead,
make configuration changes via `machineconfig` objects:
  https://docs.openshift.com/container-platform/4.7/architecture/architecture-rhcos.html

---
[core@crc-xl2km-master-0 ~]$ KUBECONFIG=/opt/kubeconfig kubectl get nodes
[core@crc-xl2km-master-0 ~]$ KUBECONFIG=/opt/kubeconfig kubectl describe nodes


[core@crc-xl2km-master-0 ~]$ sudo su -
[root@crc-xl2km-master-0 kubernetes]# cat /etc/*rele*
NAME="Red Hat Enterprise Linux CoreOS"
VERSION="47.83.202103292105-0"
VERSION_ID="4.7"
OPENSHIFT_VERSION="4.7"
RHEL_VERSION="8.3"
PRETTY_NAME="Red Hat Enterprise Linux CoreOS 47.83.202103292105-0 (Ootpa)"
ID="rhcos"
ID_LIKE="rhel fedora"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8::coreos"
HOME_URL="https://www.redhat.com/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"
REDHAT_BUGZILLA_PRODUCT="OpenShift Container Platform"
REDHAT_BUGZILLA_PRODUCT_VERSION="4.7"
REDHAT_SUPPORT_PRODUCT="OpenShift Container Platform"
REDHAT_SUPPORT_PRODUCT_VERSION="4.7"
OSTREE_VERSION='47.83.202103292105-0'
Red Hat Enterprise Linux CoreOS release 4.7
Red Hat Enterprise Linux CoreOS release 4.7

systemctl list-units --state=failed --all
ps -ef
crictl images
crictl ps -a
ls /etc/kubernetes/
ls /etc/kubernetes/manifests/
cat /etc/kubernetes/kubeconfig 
ls /var/log/containers/
hostname
hostname -i
hostname -I
systemctl status kubelet
critcl images|grep h2o
```

Start working with CRC:
```
### To be able to access your cluster, first set up your environment by running (Run the commands printed in your terminal or add them to your ~/.bashrc or ~/.zshrc or ~/.bash_profile file, then source it.)

$ crc oc-env
export PATH="/home/davar/.crc/bin/oc:$PATH"
# Run this command to configure your shell:
# eval $(crc oc-env)
$ eval $(crc oc-env)
$ crc ip
192.168.130.11
$ crc console --credentials
To login as a regular user, run 'oc login -u developer -p developer https://api.crc.testing:6443'.
To login as an admin, run 'oc login -u kubeadmin -p yiT2o-XfTVU-fr8ET-ahd5f https://api.crc.testing:6443'

### Login as Admin using command printed out:
$ oc login -u kubeadmin -p yiT2o-XfTVU-fr8ET-ahd5f https://api.crc.testing:6443
The server uses a certificate signed by an unknown authority.
You can bypass the certificate check, but any data you send to the server could be intercepted by others.
Use insecure connections? (y/n): y

Login successful.

You have access to 61 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
Welcome! See 'oc help' to get started.

### Confirm cluster setup/Usefull commands

$ oc whoami
$ oc get nodes
$ oc config view
### To view cluster operators (oc get clusteroperators)
$ oc get co
$ oc status
$ oc get po --all-namespaces
$ oc get routes --all-namespaces
$ oc get all --all-namespaces

### You can access the OpenShift cluster deployed locally from CLI or by opening the OpenShift 4.x console on your web browser.
$ oc login -u developer -p developer https://api.crc.testing:6443
### To open the console from your default web browser, run:
$ crc console
$ oc config use-context crc-admin


### To stop your OpenShift cluster, run the command:
$ crc stop
### If you want to delete an existing CodeReady Containers virtual machine, run:
$ crc delete
Do you want to delete the OpenShift cluster? [y/N]: y
Deleted the OpenShift cluster

$ crc cleanup
INFO Removing vsock configuration                 
INFO Removing 'crc' network from libvirt          
INFO Removing /etc/NetworkManager/dispatcher.d/99-crc.sh file 
INFO Using root access: Removing NetworkManager configuration file in /etc/NetworkManager/dispatcher.d/99-crc.sh 
INFO Using root access: Executing systemctl daemon-reload command 
INFO Using root access: Executing systemctl reload NetworkManager 
INFO Cleaning up AppArmor configuration           
INFO Using root access: Updating AppArmor configuration 
INFO Using root access: Changing permissions for /etc/apparmor.d/libvirt/TEMPLATE.qemu to 644  
INFO Removing the crc VM if exists                
INFO Removing pull secret from the keyring        
INFO Removing older logs                          
INFO Removing CRC Machine Instance directory      
INFO Removing hosts file records added by CRC     

### $ crc delete --clear-cache
```


### 2.Setting up CodeReady Containers on a remote server and remote access to CRC (remote OPENSHIFT environment)

Red Hat CodeReady Containers (CRC) is an amazing way of getting a minimal preconfigured OpenShift 4 up & running on your local machine with just two commands: crc setup & crc start. Done. But that simplicity comes at a price: RAM.

CRC minimum memory requirement is 9Gb, even with all the related monitoring, alerting, and telemetry functionality turned off by default. It is a fair price for such a powerful solution but most of us will struggle to run it together with our daily devops tools and enjoy a good user experience.

If you have the resources, a simple solution would be to run CRC on a different host. While it is in fact a pretty straightforward process, CRC itself runs as a VM so in order to access it remotely you will have to work around its network.

#### 2.1.Setup On the remote host
```
### Install packages
$ echo "$USER ALL=(ALL) NOPASSWD:ALL"|sudo tee -a /etc/sudoers
$ sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system network-manager dnsmasq tinyproxy

### Setup tinyproxy
$ sudo systemctl start tinyproxy
$ sudo systemctl enable tinyproxy
$ diff /etc/tinyproxy/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf.ORIG
224c224
< #Allow 127.0.0.1
---
> Allow 127.0.0.1
315d313
< ConnectPort 6443
$ sudo systemctl restart tinyproxy

### Download CRC and pull-secret in OPENSIFT directory:
$ mkdir OPENSHIFT && cd OPENSHIFT/
$ wget https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.25.0/crc-linux-amd64.tar.xz
$ tar -xJf ./crc-linux-amd64.tar.xz

### Place the binaries in your $PATH using .bash_profile
$ echo "export PATH=/home/davar/OPENSHIFT/crc-linux-1.25.0-amd64:/home/davar/.crc/bin/oc:$PATH" >> ~/.bash_profile
$ source ~/.bash_profile (or relogin)
### Place the binaries in your $PATH PATH using .bashrc
$ vim ~/.bashrc
export PATH="~/.crc/bin:$PATH"
eval $(crc oc-env)
$ source ~/.bashrc 

### Setup CRC:
$ crc config set memory 12288
$ crc config set consent-telemetry no
$ crc config set pull-secret-file ~/OPENSHIFT/pull-secret.txt
Successfully configured pull-secret-file to /home/davar/OPENSHIFT/pull-secret.txt
- consent-telemetry                     : no
- memory                                : 12288
- pull-secret-file                      : /home/davar/OPENSHIFT/pull-secret.txt

### Deploy CodeReady Containers virtual machine
$ crc setup
$ crc start

### Check CRC version and credentials
$ crc version
CodeReady Containers version: 1.25.0+0e5748c8
OpenShift version: 4.7.5 (embedded in executable)
$ crc console --credentials
To login as a regular user, run 'oc login -u developer -p developer https://api.crc.testing:6443'.
To login as an admin, run 'oc login -u kubeadmin -p yiT2o-XfTVU-fr8ET-ahd5f https://api.crc.testing:6443'

### Check if CodeReady Containers work
$ oc login -u kubeadmin -p yiT2o-XfTVU-fr8ET-ahd5f https://api.crc.testing:6443
$ oc get nodes
```


#### 2.2.Setup On the Laptop

```
### Install oc client
$ wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.7.5/openshift-client-linux.tar.gz
$ tar -xvf openshift-client-linux.tar.gz 
$ sudo cp oc /usr/local/bin
$ sudo cp kubectl /usr/local/bin
$ oc version

### Configure /etc/hosts file (edit/add this lines):
127.0.0.1 localhost console-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing
### DevOps CRC remote server
192.168.1.99 devops

### SSH keys setup
$ ssh-copy-id -o IdentitiesOnly=yes -i ~/.ssh/id_rsa.pub davar@devops
$ ssh davar@devops
```

Example1: TERMINAL: Setup SSH tunneling to access OpenShift console from terminal (oc client to work)

```
### SSH tunnel in a new terminal
$ sudo ssh davar@devops -L 443:console-openshift-console.apps-crc.testing:443 
### In a new terminal
$ export https_proxy=http://devops:8888
### test api endpoint
$ curl -k https://api.crc.testing:6443
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {
    
  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {
    
  },
  "code": 403
}
### Now you can login using oc client tool
$ oc login -u kubeadmin -p yiT2o-XfTVU-fr8ET-ahd5f https://api.crc.testing:6443
Login successful.

You have access to 62 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
$ oc get route
NAME    HOST/PORT                        PATH   SERVICES   PORT       TERMINATION   WILDCARD
nginx   nginx-default.apps-crc.testing          nginx      8080-tcp                 None
```

Example2 : BROWSER & TERMINAL: Setup SSH tunneling to access OpenShift console from browser and oc client to work

```
### SSH tunnel in a new terminal
$ sudo ssh davar@devops -L 7777:127.0.0.1:8888 -N
```

Access the Openshift Console

The Openshift Console UI is available at https://127.0.0.1:7777

Set proxy for http as well as ssl in your browser to point to: 127.0.0.1:7777

Firefox example below:

<img src="https://github.com/adavarski/OpenShift4-CRC-development/blob/main/pictures/firefox-proxy-config.png" width="300">
<img src="https://github.com/adavarski/OpenShift4-CRC-development/blob/main/pictures/crc-console-ui.png" width="700">

```
### TERMINAL: Setup for oc client to work
# In a new terminal
$ export https_proxy=http://127.0.0.1:7777
# test api endpoint

### Now you can login using oc client tool
$ oc login -u kubeadmin -p yiT2o-XfTVU-fr8ET-ahd5f https://api.crc.testing:6443
Login successful.

You have access to 62 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
$ oc get route
NAME    HOST/PORT                        PATH   SERVICES   PORT       TERMINATION   WILDCARD
nginx   nginx-default.apps-crc.testing          nginx      8080-tcp                 None
```

Example3: BROWSER: Setup SSH tunneling to access routes

```
### Configure /etc/hosts file : add nginx-default.apps-crc.testing
127.0.0.1	localhost console-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing nginx-default.apps-crc.testing

### SSH tunnel in a new terminal
$ sudo ssh davar@devops -L 7777:nginx-default.apps-crc.testing:80 -N

### test route api endpoint
$ curl -k http://nginx-default.apps-crc.testing:7777

### BROWSER -> http://nginx-default.apps-crc.testing:7777/
Welcome to nginx!
If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

For online documentation and support please refer to nginx.org.
Commercial support is available at nginx.com.

Thank you for using nginx.


```

### [3.OpenShift 4 (CRC) Playground](https://github.com/adavarski/OpenShift4-CRC-development/tree/main/playground)

Ref: [OpenShift Cheatsheet](https://github.com/adavarski/OpenShift4-CRC-development/blob/main/playground/README-openshift-cheatsheet.md)
