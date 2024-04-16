#!/bin/bash
#
# Deploy and remove Online Boutique on target cluster in different clouds
# ROKS GKE AKS EKS IKS"
# Meeds KUBECONFIG of the target cluster
#
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
    echo -e "${FG_BBLACK}Usage: $0 -h -i -r -t -n -N -u -c -d -m  ${FG_OFF}"
    echo ""
    echo -e "${FG_BBLUE}Deploy and remove Online Boutique on k8s cloud clusters $SUPPORTED_CLOUD ${FG_OFF}"
    echo -e "${FG_BBLUE}Service groups can be targeted to any cloud using corresponding cloud cluster KUBECONFIG${FG_OFF}"
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
    echo "   -t Cluster type ROKS/K8S"
    echo "   -n Namespace group to install in ui, db, checkout and market will be appended to this text if no -N option is specified."
    echo "   -N (Optional) Forces value specfied for -n option to be used literally as Namespace without any modification. Used for deploying ui, db, checkout and market in one single namespace."
    echo "   -u UI cluster KUBECONFIG"
    echo "   -c Checkout cluster KUBECONFIG"
    echo "   -d DB cluster KUBECONFIG"
    echo "   -m Marketing cluster KUBECONFIG"
    echo ""
    echo -e "${FG_BBLACK}Examples: ${FG_OFF}"
    echo ""
    echo -e "Specify NAMESPACE_GRP as needed."
    echo ""
    echo -e "${FG_BGREEN}Install deployments and services: ${FG_OFF}"
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}on (-t) ROKS in (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file."
    echo "$0 -i -t ROKS -n zz-test-grp -u <KUBECONFIG-FILE>"
    echo ""
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file."
    echo "$0 -i -t K8S -n zz-test-grp -d <KUBECONFIG-FILE>"
    echo ""
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file."
    echo "$0 -i -t K8S -n zz-test-grp -c <KUBECONFIG-FILE>"
    echo ""
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file."
    echo "$0 -i -t K8S -n zz-test-grp -m <KUBECONFIG-FILE>"
    echo ""
    echo ""
    echo -e "${FG_BRED}Remove deployments and services: ${FG_OFF}"
    echo -e "To (-r) ${FG_BBLACK}remove ${FG_OFF}from (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -u <KUBECONFIG-FILE>"
    echo ""
    echo -e "To (-r) ${FG_BRED}remove ${FG_OFF}from (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -d <KUBECONFIG-FILE>"
    echo ""
    echo -e "To (-r) ${FG_BRED}remove ${FG_OFF}from (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -c <KUBECONFIG-FILE>"
    echo ""
    echo -e "To (-r) ${FG_BRED}remove ${FG_OFF}from in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -m <KUBECONFIG-FILE>"
    echo ""
}

fn_check_yn_set_namespace_context() {
    DEPLOY_UNDEPLOY=$1
    CURRENT_CONTEXT=$(kubectl config current-context)
    echo -e "${FG_BRED}$1${FG_BBLACK} Online Boutique ${FG_BRED}$2${FG_BBLACK} with following parameters... ${FG_OFF}"
    echo -e "${FG_BBLACK}   CLUSTER TYPE:${FG_OFF} $CLUSTER_TYPE"
    echo -e "${FG_BBLACK}      NAMESPACE:${FG_OFF} $3"
    echo -e "${FG_BBLACK}CURRENT_CONTEXT:${FG_OFF} $CURRENT_CONTEXT"
    echo -e "${FG_BBLACK}CLUSTER NODES:${FG_OFF}"
    kubectl get nodes

    shift
    shift
    shift
    local deploys="$@"

    echo -e "${FG_BBLACK}Deployments:${FG_OFF} ${deploys[@]}"
    read -p "Continue? (Y/N)" yn
    case $yn in
	[Yy]* ) ;;
	[Nn]* ) exit;;
    esac
    echo -e ""

    if [[ "$DEPLOY_UNDEPLOY" = "Deploy" ]]; then 
      if [[ "$CLUSTER_TYPE" = "ROKS" ]]; then 
        oc new-project $TARGET_NAMESPACE
        oc adm policy add-scc-to-user anyuid -z default -n $TARGET_NAMESPACE
      else
	kubectl create namespace $TARGET_NAMESPACE
      fi
    fi
    kubectl config set-context --current --namespace=$TARGET_NAMESPACE
}

fn_deploy() {
    if [[ -z $NAMESPACE_TARGET ]]; then
       TARGET_NAMESPACE=$1-$2
    else
       TARGET_NAMESPACE=$1
    fi

    GRP=$2

    shift
    shift
    local deploys=("$@")
    fn_check_yn_set_namespace_context Deploy $GRP $TARGET_NAMESPACE "${deploys[@]}"

    for deploy in ${deploys[@]}; 
    do
	kubectl apply --namespace=$TARGET_NAMESPACE -f kube/$deploy.yaml
    done

    kubectl get deploy -n $TARGET_NAMESPACE
    kubectl get pod -n $TARGET_NAMESPACE
    kubectl get svc -n $TARGET_NAMESPACE
}

fn_undeploy() {
    if [[ -z $NAMESPACE_TARGET ]]; then
       TARGET_NAMESPACE=$1-$2
    else
       TARGET_NAMESPACE=$1
    fi

    GRP=$2

    shift
    shift
    local deploys=("$@")
    fn_check_yn_set_namespace_context Undeploy $GRP $TARGET_NAMESPACE "${deploys[@]}"

    for deploy in ${deploys[@]}; 
    do
	kubectl delete deploy $deploy --namespace=$TARGET_NAMESPACE 
    done
}

fn_delete_svc() {
    if [[ -z $NAMESPACE_TARGET ]]; then
       TARGET_NAMESPACE=$1-$2
    else
       TARGET_NAMESPACE=$1
    fi

    shift
    shift
    svcs=("$@")

    for svc in ${svcs[@]}; 
    do
	kubectl delete svc $svc --namespace=$TARGET_NAMESPACE 
    done
}

while getopts 'hin:u:d:c:m:rt:N' option; do
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
    t) CLUSTER_TYPE=$OPTARG
       ;;
    N) NAMESPACE_TARGET=1
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
    if [ ! -z "$CLUSTER_TYPE" ]; then
      if [[ "$CLUSTER_TYPE" == "ROKS" ]] || [[ "$CLUSTER_TYPE" == "K8S" ]] ; then
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
        echo -e "${FG_RED}Error: Must use -t option to provide CLUSTER_TYPE ROKS/K8S.${FG_OFF}"
        usage
        exit 1
      fi
    else
      echo -e "${FG_RED}Error: Must use -t option to provide CLUSTER_TYPE ROKS/K8S${FG_OFF}"
      usage
      exit 1
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
      fn_delete_svc $NAMESPACE_GRP ui "${SERVICE_UI[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_DB" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_DB"
      fn_undeploy $NAMESPACE_GRP db "${DEPLOY_DB[@]}"
      fn_delete_svc $NAMESPACE_GRP db "${SERVICE_DB[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_CHECKOUT" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_CHECKOUT"
      fn_undeploy $NAMESPACE_GRP checkout "${DEPLOY_CHECKOUT[@]}"
      fn_delete_svc $NAMESPACE_GRP checkout "${SERVICE_CHECKOUT[@]}"
    fi
    if [ ! -z "$CLUSTER_K_CONFIG_MARKET" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_MARKET"
      fn_undeploy $NAMESPACE_GRP market "${DEPLOY_MARKET[@]}"
      fn_delete_svc $NAMESPACE_GRP market "${SERVICE_MARKET[@]}"
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
