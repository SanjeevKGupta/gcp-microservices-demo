## Deploy Online Boutique services across different clouds ROKS, GKE, AKS, EKS

1. Login into each of the target cloud
2. Create one kubernetes cluster in each of the target cloud where you plan to deploy the micro-services
3. Extract KUBECONFIF for the cloud and the cluster using
   ```
   kubectl config view --raw --minify > kubeconfig-<cloud>-<cluster>.yaml
   ```
   You should have one file each for each of the target cloud cluster
5. Switch the context using one of the above files by setting KUBECONFIG environment variable
