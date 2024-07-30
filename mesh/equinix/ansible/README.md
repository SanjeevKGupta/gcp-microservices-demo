# Prepare a VM or BareMetal (BM) for Hybrid Cloud Mesh

To use Equinix BM instance as a host machine where application services can run to provide application resiliency using RHSI GW and Hybrid Cloud Mesh, follow the steps described below. We will use [ansible](https://docs.ansible.com) This directory has files needed by `ansible` to 
- Prepare the host machine with necessary packages
- Install microk8s cluster to run application services and RHSI GW
- Install Online Boutique service group as per `MESH_APP_OB_SERVICE_GROUP`below. 
  
  Ref: https://github.com/SanjeevKGupta/gcp-microservices-demo/tree/main/mesh/rhsi

Follow through with OH agent install and necessary configuration in Hybrid Cloud Mesh UI as needed. 

## 1. Pre-requisite
1.1 Provision a VM or BM instance. The script was tested on a BM host machine running Ubuntu 22.04

## 2. Login and setup
2.1 Login as `root`

2.2 Install `ansible`
```
apt install -y ansible
```
2.3 Setup following ENV variables used by the template files in this directory to customize setup and install. Create a file to store ENVs and easily source.
```
# The Hybrid Cloud Mesh Manager URL
export MESH_MANAGER_URL=<https://app.hybridcloudmesh.ibm.com>
# mesh manager access token for the tenancy
export MESH_MANAGER_TOKEN=<mesh-manager-token>
# For palmctl CLI install
export MESH_PALMCTL_FILE_NAME=palmctl_latest_amd64.deb
# At least two public IP addresss for RHSI GW skupper router
export MESH_MICROK8S_LB_IP_RANGE=<xx,xx,xx,xx-xx.xx.xx.yy>
# Version of Online boutique 0.10.0 or 0.9.0
export MESH_APP_OB_VERSION=<0.10.0>
# For microk8s K8S
export MESH_APP_OB_CLUSTER_TYPE=K8S
# Applciation namespace group. Used by `install-ob.sh` script
export MESH_APP_OB_NAMESPACE_GROUP=<zz-test-grp>
# Target specific service group. Used by `install-ob.sh` script
export MESH_APP_OB_SERVICE_GROUP=<m>
```
2.4 Clone this repo
```
git clone https://github.com/SanjeevKGupta/gcp-microservices-demo.git
```
2.5 Source the above ENV
```
source ENV_MESH_MANAGER
```
2.6 Create Hybrid Cloud Mesh configration file using ENV sourced above. WIll be used by ansible playbook
```
cd gcp-microservices-demo/mesh/equinix/ansible
cat mcnm_config.yaml.tmpl | envsubst > mcnm_config.yaml
````
2.7 Prepare the ansible playbook yaml file
```
cat playbook-bm-microk8s-app.yaml.tmpl | envsubst > playbook-bm-microk8s-app.yaml
```
2.8 Update `hosts` file with target host IP addresses for ansible to work with. Make sure that hosts have the ssh-key of the bastion host running this script. Ansible requirement,
```
emacs hosts
```
2.8 Run the ansible-playbook
```
ansible-playbook playbook-bm-microk8s-app.yaml
```
2.9 Verify the install

2.10 Install OH agent

2.11 Configure in Mesh UI and follow through with Mesh activities.
