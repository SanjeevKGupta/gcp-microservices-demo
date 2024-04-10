## Deploy Online Boutique services across different clouds ROKS, GKE, AKS, EKS

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
Usage: ./install-ob.sh -h -i -t -n -u -c -p -m -d 

Deploy and remove Online Boutique on k8s cloud clusters ROKS GKE AKS EKS IKS 
Service groups can be targeted to any cloud using corresponding cloud cluster KUBECONFIG

Services are grouped to be deployed in different namespaces in a cluster as follows. 
 ui - frontend frontend-external 
 db - cartservice redis-cart 
 checkout - checkoutservice currencyservice paymentservice shippingservice emailservice 
 market - adservice productcatalogservice recommendationservice

where 
   -h help 
   -i Install workload
   -r Remove deployments and services
   -n Namespace group to install in, ui, db, checkout and market will be appended to this text.
   -t Cluster type ROKS/K8S
   -u UI cluster KUBECONFIG
   -d DB cluster KUBECONFIG
   -c Checkout cluster KUBECONFIG
   -m Marketing cluster KUBECONFIG

Examples: 

Specify NAMESPACE_GRP as needed.

Install deployments and services: 
To (-i) install on (-t) ROKS in (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -t ROKS -n zz-test-grp -u <KUBECONFIG-FILE>

To (-i) install on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -t K8S -n zz-test-grp -d <KUBECONFIG-FILE>

To (-i) install on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -t K8S -n zz-test-grp -c <KUBECONFIG-FILE>

To (-i) install on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file.
./install-ob.sh -i -t K8S -n zz-test-grp -m <KUBECONFIG-FILE>


Remove deployments and services: 
To (-r) remove from (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -n zz-test-grp -u <KUBECONFIG-FILE>

To (-r) remove from (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -n zz-test-grp -d <KUBECONFIG-FILE>

To (-r) remove from (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -n zz-test-grp -c <KUBECONFIG-FILE>

To (-r) remove from in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file.
./install-ob.sh -r -n zz-test-grp -m <KUBECONFIG-FILE>
```
