## Deploy Online Boutique services across different clouds ROKS, GKE, AKS, EKS, IKS, OCP-on-prem

1. Login into each of the target cloud
2. Create one kubernetes cluster in each of the target cloud where you plan to deploy the micro-services
3. Extract KUBECONFIF for the cloud and the cluster using
   ```
   kubectl config view --raw --minify > kubeconfig-<cloud>-<cluster>.yaml
   ```
   You should have one file each for each of the target cloud cluster
4. Switch the context using one of the above files by setting KUBECONFIG environment variable
5. Clone the repo so that you have all the necessary service kube yaml files locally.
6. Review the various command options and the examples to pick the service group and the target cloud cluster.
```
Usage: ./install-ob.sh -h -i -r -v -t -n -N -u -c -d -m -x -B 

Deploy and remove Online Boutique on k8s cloud clusters ROKS GKE AKS EKS IKS 
By default uses original gcr.io images. 
Service groups can be targeted to any cloud using corresponding cloud cluster KUBECONFIG

Online Boutique supported versions 
 App versions - 0.9.0 0.10.0

Services are grouped to be deployed in different namespaces in a cluster as follows. 
 ui - frontend frontend-external 
 db - cartservice redis-cart 
 checkout - checkoutservice currencyservice paymentservice shippingservice emailservice 
 market - adservice productcatalogservice recommendationservice 
 extra - nginx

where 
   -h help 
   -i Install workload
   -r Remove deployments and services
   -v Version
   -t Cluster type ROKS/K8S
   -n Namespace group to install in ui, db, checkout and market will be appended to this text if no -N option is specified.
   -N (Optional) Forces value specfied for -n option to be used literally as Namespace without any modification. Used for deploying ui, db, checkout and market in one single namespace.
   -B (Optional) Build and Patch original deployment of gcr.io to icr.io image location. Uses custom locally built images, authenticated IBM container registry to push image into and deploy customized images instead of gcr.io images.
   -u UI cluster KUBECONFIG
   -c Checkout cluster KUBECONFIG
   -d DB cluster KUBECONFIG
   -m Marketing cluster KUBECONFIG
   -x Extra such NS1 pulsar cluster KUBECONFIG

Examples: 

Specify NAMESPACE_GRP as needed.

Install deployments and services: 
To (-i) install (-v) version on (-t) ROKS in (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -v <version> -t ROKS -n zz-test-grp -u $KUBECONFIG

To (-i) install (-v) version on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -v <version> -t K8S -n zz-test-grp -d $KUBECONFIG

To (-i) install (-v) version on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -v <version> -t K8S -n zz-test-grp -c $KUBECONFIG

To (-i) install (-v) version on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -v <version> -t K8S -n zz-test-grp -m $KUBECONFIG

================
Need to deploy in named group UI, DB, Checkout and Market pods. Use optional -N with -n 
To install in named group as specified by -n option and not modified. Use optional -N option. Useful to 
./install-ob.sh -i -t ROKS -n zz-test -m kubeconfig-ROKS.yaml -N

===Advanced Use=============
To (-B) build custom image using google skaffold and push into ICR (Setup following ENV). Should work with other CRs.
Like before deploy your custom images.
CR_HOST=us.icr.io
CR_HOST_USERNAME=iamapikey
CR_HOST_NAMESPACE=<cr-namespace>
CR_APP_API_KEY_RW_PUSH=<cr-app-key-rw-push>
CR_APP_API_KEY_RO_PULL=<cr-app-key-ro-pull>

./install-ob.sh -i -t ROKS -n zz-test -m kubeconfig-ROKS.yaml -N -B 

=================
Remove deployments and services: 
To (-r) remove from (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -v <version> -n zz-test-grp -u <KUBECONFIG-FILE>

To (-r) remove from (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -v <version> -n zz-test-grp -d <KUBECONFIG-FILE>

To (-r) remove from (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -v <version> -n zz-test-grp -c <KUBECONFIG-FILE>

To (-r) remove from in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -v <version> -n zz-test-grp -m <KUBECONFIG-FILE>
```
