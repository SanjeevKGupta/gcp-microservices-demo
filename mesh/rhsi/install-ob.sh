#!/bin/bash
#
# Deploy Online Boutique
#

FG_OFF="\033[0m"
FG_BLACK="\033[30m"
FG_RED="\033[31m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"

FG_BBLACK="\033[1;30m"
FG_BRED="\033[1;31m"
FG_BGREEN="\033[1;32m"
FG_BYELLOW="\033[1;33m"
FG_BBLUE="\033[1;34m"

BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_YELLOW="\033[43m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

SUPPORTED_CLOUD="ROKS GKE AKS EKS IKS"

# scripts runs through DEPLOY arrays to create POD and SVC as specified in the corresponding yaml files
DEPLOY_UI=("frontend" "loadgenerator")
DEPLOY_DB=("cartservice" "redis-cart")
DEPLOY_CHECKOUT=("checkoutservice" "currencyservice" "paymentservice" "shippingservice" "emailservice")
DEPLOY_MARKET=("adservice" "productcatalogservice" "recommendationservice")

# List of services creatded by above DEPLOY yamls
SERVICE_UI=("frontend" "frontend-external")
SERVICE_DB=("cartservice" "redis-cart")
SERVICE_CHECKOUT=("checkoutservice" "currencyservice" "paymentservice" "shippingservice" "emailservice")
SERVICE_MARKET=("adservice" "productcatalogservice" "recommendationservice")

usage() {

    echo ""
    echo -e "${FG_BBLACK}Usage: $0 -h -i -n -u -c -p -m -d ${FG_OFF}"
    echo ""
    echo -e "${FG_BBLUE}Deploy and remove Online Boutique on k8s cloud clusters $SUPPORTED_CLOUD ${FG_OFF}"
    echo ""
    echo -e "${FG_BLACK}Services are grouped to be deployed in different namespaces in a cluster as follows. ${FG_OFF}"
    echo -e -n "${FG_BLACK} ui -${FG_OFF}"
    for svc in ${SERVICE_UI[@]}; do echo -n  " $svc"; done

    echo -e -n "${FG_BLACK} \n db -${FG_OFF}"
    for svc in ${SERVICE_DB[@]}; do echo -n  " $svc"; done

    echo -e -n "${FG_BLACK} \n checkout -${FG_OFF}"
    for svc in ${SERVICE_CHECKOUT[@]}; do echo -n  " $svc"; done

    echo -e -n "${FG_BLACK} \n market -${FG_OFF}"
    for svc in ${SERVICE_MARKET[@]}; do echo -n  " $svc"; done
    echo ""
    echo ""
    echo "where "
    echo "   -h help "
    echo "   -i Install workload"
    echo "   -r Remove deployments and services"
    echo "   -n Namespace group to install in, ui, db, checkout and market will be appended to this text."
    echo "   -t Cluster type $SUPPORTED_CLOUD"
    echo "   -u UI cluster KUBECONFIG"
    echo "   -d DB cluster KUBECONFIG"
    echo "   -c Checkout cluster KUBECONFIG"
    echo "   -m Marketing cluster KUBECONFIG"
    echo ""
}

## WIP
fn_setup_sec_context_roks() {
  oc new-project $1
  oc adm policy scc-review -n $1 -f kube/ob-email.yaml
#  oc adm policy add-scc-to-user anyuid -z default -n $1

  sleep 3
  oc adm policy scc-review -n $1 -f kube/ob-email.yaml
  sleep 3
  oc adm policy scc-review -n $1 -f kube/ob-email.yaml
  sleep 3
  oc adm policy scc-review -n $1 -f kube/ob-email.yaml
  sleep 3
  oc adm policy scc-review -n $1 -f kube/ob-email.yaml
}

fn_check_yn_set_namespace_context() {
    DEPLOY=$1
    CURRENT_CONTEXT=$(kubectl config current-context)
    echo -e "${FG_BBLACK}$1 Online Boutique $2 with following parameters... ${FG_OFF}"
    echo -e "${FG_BBLACK}      NAMESPACE:${FG_OFF} $3"
    echo -e "${FG_BBLACK}CURRENT_CONTEXT:${FG_OFF} $CURRENT_CONTEXT"
    echo -e "${FG_BBLACK}CLUSTER NODES:${FG_OFF}"
    kubectl get nodes

    shift
    shift
    shift
    deploys=("$@")
    echo -e "${FG_BBLACK}Deployments:${FG_OFF} ${deploys[@]}"

    read -p "Continue? (Y/N)" yn
    case $yn in
	[Yy]* ) ;;
	[Nn]* ) exit;;
    esac
    echo -e ""
    if [[ "$DEPLOY" = "Deploy" ]]; then 
	kubectl create namespace $TARGET_NAMESPACE
    fi
    kubectl config set-context --current --namespace=$TARGET_NAMESPACE
}

fn_deploy() {
    TARGET_NAMESPACE=$1-$2
    shift
    shift
    deploys=("$@")
    fn_check_yn_set_namespace_context Deploy $2 $TARGET_NAMESPACE "${deploys[@]}"

    for deploy in ${deploys[@]}; 
    do
	kubectl apply --namespace=$TARGET_NAMESPACE -f kube/$deploy.yaml
    done

    kubectl get deploy -n $TARGET_NAMESPACE
    kubectl get pod -n $TARGET_NAMESPACE
    kubectl get svc -n $TARGET_NAMESPACE
}

fn_undeploy() {
    TARGET_NAMESPACE=$1-$2
    shift
    shift
    deploys=("$@")
    fn_check_yn_set_namespace_context Undeploy $2 $TARGET_NAMESPACE "${deploys[@]}"

    for deploy in ${deploys[@]}; 
    do
	kubectl delete deploy $deploy --namespace=$TARGET_NAMESPACE 
	kubectl delete svc $deploy --namespace=$TARGET_NAMESPACE 
    done
}

while getopts 'hin:u:d:c:m:r' option; do
  case "$option" in
    h) usage
       exit 1
       ;;
    i) INSTALL=1
       ;;
    n) NAMESPACE_GRP=$OPTARG
       ;;
    u) CLUSTER_K_CONFIG_UI=$OPTARG
       ;;
    d) CLUSTER_K_CONFIG_DB=$OPTARG
       ;;
    c) CLUSTER_K_CONFIG_CHECKOUT=$OPTARG
       ;;
    m) CLUSTER_K_CONFIG_MARKET=$OPTARG
       ;;
    r) REMOVE=1
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ ! -z "$INSTALL" ]; then
  if [ ! -z "$NAMESPACE_GRP" ]; then
    if [ ! -z "$CLUSTER_K_CONFIG_UI" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_UI"
      fn_deploy $NAMESPACE_GRP ui "${DEPLOY_UI[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_DB" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_DB"
      fn_deploy $NAMESPACE_GRP db "${DEPLOY_DB[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_CHECKOUT" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_CHECKOUT"
      fn_deploy $NAMESPACE_GRP checkout "${DEPLOY_CHECKOUT[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_MARKET" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_MARKET"
      fn_deploy $NAMESPACE_GRP market "${DEPLOY_MARKET[@]}"
    fi
  else
    echo -e "${FG_RED}Error: Must use -n option to provide NAMESPACE_GRP${FG_OFF}"
    usage
    exit 1
  fi
elif [ ! -z "$REMOVE" ]; then
  if [ ! -z "$NAMESPACE_GRP" ]; then
    if [ ! -z "$CLUSTER_K_CONFIG_UI" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_UI"
      fn_undeploy $NAMESPACE_GRP ui "${DEPLOY_UI[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_DB" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_DB"
      fn_undeploy $NAMESPACE_GRP db "${DEPLOY_DB[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_CHECKOUT" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_CHECKOUT"
      fn_undeploy $NAMESPACE_GRP checkout "${DEPLOY_CHECKOUT[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_MARKET" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_MARKET"
      fn_undeploy $NAMESPACE_GRP market "${DEPLOY_MARKET[@]}"
    fi
  else
    echo -e "${FG_RED}Error: Must provide NAMESPACE_GRP of the logged in cluster with -n option${FG_OFF}"
    usage
    exit 1
  fi
else
    echo -e "${FG_RED}Error: No valid option specified. ${FG_OFF}"
    usage
    exit 1
fi
