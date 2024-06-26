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

SUPPORTED_VERSIONS="0.9.0 0.10.0"

# scripts runs through DEPLOY arrays to create POD and SVC as specified in the corresponding yaml files
DEPLOY_UI=("frontend" "loadgenerator")
DEPLOY_DB=("cartservice" "redis-cart")
DEPLOY_CHECKOUT=("checkoutservice" "currencyservice" "paymentservice" "shippingservice" "emailservice")
DEPLOY_MARKET=("adservice" "productcatalogservice" "recommendationservice")
DEPLOY_EXTRA=("nginx")

# List of services creatded by above DEPLOY yamls
SERVICE_UI=("frontend" "frontend-external")
SERVICE_DB=("cartservice" "redis-cart")
SERVICE_CHECKOUT=("checkoutservice" "currencyservice" "paymentservice" "shippingservice" "emailservice")
SERVICE_MARKET=("adservice" "productcatalogservice" "recommendationservice")
SERVICE_EXTRA=("nginx")

usage() {

    echo ""
    echo -e "${FG_BBLACK}Usage: $0 -h -i -r -v -t -n -N -u -c -d -m -x -B ${FG_OFF}"
    echo ""
    echo -e "${FG_BBLUE}Deploy and remove Online Boutique on k8s cloud clusters $SUPPORTED_CLOUD ${FG_OFF}"
    echo -e "${FG_BBLUE}By default uses original gcr.io images. ${FG_OFF}"
    echo -e "${FG_BBLUE}Service groups can be targeted to any cloud using corresponding cloud cluster KUBECONFIG${FG_OFF}"
    echo ""

    echo -e "${FG_BLACK}Online Boutique supported versions ${FG_OFF}"
    echo -e -n "${FG_BLACK} App versions -${FG_OFF}"
    for ver in ${SUPPORTED_VERSIONS[@]}; do echo -n  " $ver"; done

    echo ""
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

    echo -e -n "${FG_BLACK} \n extra -${FG_OFF}"
    for svc in ${SERVICE_EXTRA[@]}; do echo -n  " $svc"; done
    
    echo ""
    echo ""
    echo "where "
    echo "   -h help "
    echo "   -i Install workload"
    echo "   -r Remove deployments and services"
    echo "   -v Version"
    echo "   -t Cluster type ROKS/K8S"
    echo "   -n Namespace group to install in ui, db, checkout and market will be appended to this text if no -N option is specified."
    echo "   -N (Optional) Forces value specfied for -n option to be used literally as Namespace without any modification. Used for deploying ui, db, checkout and market in one single namespace."
    echo "   -B (Optional) Build and Patch original deployment of gcr.io to icr.io image location. Uses custom locally built images, authenticated IBM container registry to push image into and deploy customized images instead of gcr.io images."
    echo "   -u UI cluster KUBECONFIG"
    echo "   -c Checkout cluster KUBECONFIG"
    echo "   -d DB cluster KUBECONFIG"
    echo "   -m Marketing cluster KUBECONFIG"
    echo "   -x Extra such NS1 pulsar cluster KUBECONFIG"
    echo ""
    echo -e "${FG_BBLACK}Examples: ${FG_OFF}"
    echo ""
    echo -e "Specify NAMESPACE_GRP as needed."
    echo ""
    echo -e "${FG_BGREEN}Install deployments and services: ${FG_OFF}"
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}(-v) version on (-t) ROKS in (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file."
    echo "$0 -i -v <version> -t ROKS -n zz-test-grp -u \$KUBECONFIG"
    echo ""
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}(-v) version on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file."
    echo "$0 -i -v <version> -t K8S -n zz-test-grp -d \$KUBECONFIG"
    echo ""
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}(-v) version on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file."
    echo "$0 -i -v <version> -t K8S -n zz-test-grp -c \$KUBECONFIG"
    echo ""
    echo -e "To (-i) ${FG_BGREEN}install ${FG_OFF}(-v) version on (-t) K8S in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file."
    echo "$0 -i -v <version> -t K8S -n zz-test-grp -m \$KUBECONFIG>"
    echo ""
    echo ""
    echo -e "${FG_BRED}Remove deployments and services: ${FG_OFF}"
    echo -e "To (-r) ${FG_BBLACK}remove ${FG_OFF}from (-n) NAMESPACE group zz-test-grp the (-u) UI group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -u \$KUBECONFIG"
    echo ""
    echo -e "To (-r) ${FG_BRED}remove ${FG_OFF}from (-n) NAMESPACE group zz-test-grp the (-d) DB group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -d \$KUBECONFIG"
    echo ""
    echo -e "To (-r) ${FG_BRED}remove ${FG_OFF}from (-n) NAMESPACE group zz-test-grp the (-c) CHECKOUT group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -c \$KUBECONFIG"
    echo ""
    echo -e "To (-r) ${FG_BRED}remove ${FG_OFF}from in (-n) NAMESPACE group zz-test-grp the (-m) MARKET group services as targeted by the KUBECONFIG file."
    echo "$0 -r -n zz-test-grp -m \$KUBECONFIG"
    echo ""
}

fn_patch_need() {
    make "$1" > /dev/null 2>&1
    PATCH_NEED=$?
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
        oc new-project $TARGET_NAMESPACE > /dev/null 2>&1
	if [[ "$VERSION_OB" = "0.10.0" ]]; then
          for deploy in ${deploys[@]}; 
          do
   	    if [[ "$deploy" = "redis-cart" ]]; then 
              oc adm policy add-scc-to-user anyuid -z default -n $TARGET_NAMESPACE
	    else
              oc adm policy add-scc-to-user anyuid -z $deploy -n $TARGET_NAMESPACE
	    fi
	  done
	else # 0.9.0
          oc adm policy add-scc-to-user anyuid -z default -n $TARGET_NAMESPACE
	fi
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
        if [ ! -z "$BUILD_PUSH_PATCH_IMAGE" ]; then
	   fn_patch_need patch-need-$deploy
	   if [[ "$PATCH_NEED" = "0" ]]; then
  	       make patch-file-$deploy NAMESPACE=$TARGET_NAMESPACE 
	   else
	       echo ""
	       echo -e "${FG_BBLACK}No patch prcessing needed fpr $deploy${FG_OFF}"
	   fi
	else
	   echo -e "${FG_BBLACK}Will deploy ORIGINAL gcr.io images${FG_OFF} for $deploy in $TARGET_NAMESPACE ..."
	fi
	kubectl apply --namespace=$TARGET_NAMESPACE -f kube-$VERSION_OB/$deploy.yaml

        if [[ "$PATCH_NEED" = "0" ]]; then
	   echo -e "${FG_BBLACK}Patching${FG_OFF} deployment $deploy in $TARGET_NAMESPACE..."
	   kubectl patch deployment $deploy -n ${TARGET_NAMESPACE} --patch-file ./patch/deploy-$deploy-patch.yaml
	fi
    done

    echo ""
    echo -e "${FG_BBLACK}kubectl get deploy -n $TARGET_NAMESPACE${FG_OFF}"
    kubectl get deploy -n $TARGET_NAMESPACE

    echo ""
    echo -e "${FG_BBLACK}kubectl get pod -n $TARGET_NAMESPACE${FG_OFF}"
    kubectl get pod -n $TARGET_NAMESPACE

    echo ""
    echo -e "${FG_BBLACK}kubectl get svc -n $TARGET_NAMESPACE${FG_OFF}"
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

while getopts 'hiv:n:u:d:c:m:rt:x:NB' option; do
  case "$option" in
    h) usage
       exit 1
       ;;
    i) INSTALL=1
       ;;
    v) VERSION_OB=$OPTARG
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
    x) CLUSTER_K_CONFIG_EXTRA=$OPTARG
       ;;
    r) REMOVE=1
       ;;
    t) CLUSTER_TYPE=$OPTARG
       ;;
    N) NAMESPACE_TARGET=1
       ;;
    B) BUILD_PUSH_PATCH_IMAGE=1
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ ! -z "$INSTALL" ]; then
  if [ ! -z "$VERSION_OB" ]; then

    for version in ${SUPPORTED_VERSIONS[@]};
    do 
      if [[ "$version" == "$VERSION_OB" ]] ; then
	 echo -e "${FG_BGREEN}Supported version: $version ${FG_OFF}"
	 VERSION_MATCH=1
         break
      fi
    done
    if [[ -z $VERSION_MATCH ]]; then
	 echo ""
	 echo -e "${FG_BRED}Error: Unsupported version: $VERSION_OB${FG_OFF}"
	 echo -e "${FG_BLACK}Version value must be one of these: ${FG_OFF}"
         for ver in ${SUPPORTED_VERSIONS[@]}; do echo -n  "$ver "; done
	 echo ""; echo ""
	 exit 1
    else
	if [[ ! -d "kube-$VERSION_OB" ]]; then
	 echo ""
	 echo -e "${FG_BRED}Error: kube-$VERSION_OB not found.${FG_OFF}"
	 echo -e "${FG_BLACK}Make sure to have the directory setup with content all the .yaml files.${FG_OFF}"	    
	 echo "";  echo ""
	 exit 1
	else
	 echo -e "${FG_BGREEN}kube-$VERSION_OB found ${FG_OFF}"
	fi
    fi

    if [ ! -z "$NAMESPACE_GRP" ]; then
      if [ ! -z "$CLUSTER_TYPE" ]; then
        if [[ "$CLUSTER_TYPE" == "ROKS" ]] || [[ "$CLUSTER_TYPE" == "K8S" ]] ; then
          if [ ! -z "$BUILD_PUSH_PATCH_IMAGE" ]; then
	    make build-push
	  fi
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
          if [ ! -z "$CLUSTER_K_CONFIG_EXTRA" ]; then
            export KUBECONFIG="$CLUSTER_K_CONFIG_EXTRA"
            fn_deploy $NAMESPACE_GRP extra "${DEPLOY_EXTRA[@]}"
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
  else
    echo -e "${FG_RED}Error: Must use -v option to provide VERSION_OB${FG_OFF}"
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
    if [ ! -z "$CLUSTER_K_CONFIG_EXTRA" ]; then
      export KUBECONFIG="$CLUSTER_K_CONFIG_EXTRA"
      fn_undeploy $NAMESPACE_GRP extra "${DEPLOY_EXTRA[@]}"
      fn_delete_svc $NAMESPACE_GRP extra "${SERVICE_EXTRA[@]}"
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
