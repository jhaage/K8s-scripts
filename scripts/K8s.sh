#!/bin/bash

# FUNCTIONS

# This script is designed to output pods in two different K8s contexts so that you can visually compare. For example you may want to compare a test context to production to see differences.

cpods() {
  context1="qa01lax1"  # Your K8s context for the first set of pods
  context2="${3:-kube02lax1}"  # Your K8s context for the second set of pods
  release1="${1:-cxp-team}"  # Release for first set of pods. We pass this into a selector (-l) in the K8s command below to filter it.
  release2="${2:-production}"  # Release for second set of pods.
  echo "Environment: $release1\n"
  kubectl get --context $context1 pods -L tag,chart -l release=$release1,'app in (anxious, core-ui-service, access-control-ui, authentication-api, authenti
cation-ui, authentication-ui-cache, sso-settings-api, uxua-api)' --all-namespaces | awk '{$3=$4=$5=$6="";print $0}' | column -t
  echo "\nEnvironment: $release2\n"
  kubectl get --context $context2 pods -L tag,chart -l release=$release2,'app in (anxious, core-ui-service, access-control-ui, authentication-api, authenti
cation-ui, authentication-ui-cache, sso-settings-api, uxua-api)' --all-namespaces | awk '{$3=$4=$5=$6="";print $0}' | column -t
}

# This script gets pods in a particular context, release and namespace using some colorization in the output.

gcxp() {
  release="${1:-cxp-team}"
  context="${2:-qa01lax1}"
  namespace="${3:-web-application-platform}"

  PURPLE="\033[0;35m"
  LIGHT_PURPLE="\033[1;35m"
  GRAY="\033[1;30m"
  WHITE="\033[1;37m"
  ORANGE="\033[0;33m"
  BOLD="\033[1m" # Bold
  NC="\033[0m" # No color

  # Help/Usage Info
  echo "${WHITE}Usage:${NC} ${GRAY}$0 release context namespace${NC}"
  echo "${WHITE}Arguments:${NC}"
  echo "  ${GRAY}release - staging or production. Default: staging"
  echo "  context - name of the k8s context to use (ex: dev02nym2, qa01lax1).  Default: cxp-inv"
  echo "  namespace - the namespace to use.  Default: web-application-platform${NC}\n"

  # Begin rest of script output
  echo "Release:  $release"
  echo "Context:  $context"
  echo "Namespace:  $namespace \n"
  echo -e "${WHITE}Command:    ${PURPLE}kubectl get pods --context $context -L tag,chart -l release=$release -n $namespace${NC}"
  kubectl get pods --context $context -L tag,chart -l release=$release -n $namespace
}

# Similar to the previous script, this one gets all namespaces (no colorized output or helper/usage info)

gallcxp() {
  release="${1:-cxp-team}"
  context="${2:-qa01lax1}"
  echo "Command:  kubectl get --context $context pods -L tag,chart -l release=$release --all-namespaces"
  kubectl get --context $context pods -L tag,chart -l release=$release --all-namespaces
}

# Gets logs from a particular container, based on context, release and namespace

gcoreuilogs() {
  release="${1:-cxp-team}"
  context="${2:-qa01lax1}"
  namespace="${3:-web-application-platform}"
  echo "Release:  $release"
  echo "Context:  $context"
  echo "Namespace:  $namespace \n"
  container=$(kubectl get pods --context $context -l release=$release,app=core-ui-service -n $namespace | awk 'FNR == 2 {print $1}')
  kubectl logs -f --context $context -n $namespace $container core-ui-service
}

# Same as above script but targets a different container

gdblogs() {
  app="${1:-postgresql}"
  release="${2:-cxp-team}"
  context="${3:-qa01lax1}"
  namespace="${4:-dba}"
  echo "App:  $app"
  echo "Release:  $release"
  echo "Context:  $context"
  echo "Namespace:  $namespace \n"
  container=$(kubectl get pods --context $context -l release=$release,app=$app -n $namespace | awk 'FNR == 2 {print $1}')
  kubectl logs -f --context $context -n $namespace $container
}

# Gets pods for several different contexts

gwap() {
  release="${1:-staging}"
  namespace="${2:-web-application-platform}"
  separator="-------------------------------------------------"
  contexts=("kube02nym2" "kube02ams1" "kube02lax1")

  for context in $contexts
  do
    echo "Release:  $release"
    echo "Context:  $context"
    echo "Namespace:  $namespace \n"
    kubectl get pods --context $context -L chart,tag -l release=$release -n $namespace
    echo $separator
  done
}

# Gets pods for several different contexts, narrowed down by app name. This outputs some Help/Usage info along with some colorized output.

gpods() {
  PURPLE="\033[0;35m"
  LIGHT_PURPLE="\033[1;35m"
  GRAY="\033[1;30m"
  WHITE="\033[1;37m"
  ORANGE="\033[0;33m"
  BOLD="\033[1m" # Bold
  NC="\033[0m" # No color
  release="${1:-staging}"
  app="${2:-core-ui-service}"
  namespace="${3:-web-application-platform}"
  contexts=("kube02nym2" "kube02ams1" "kube02lax1")

  # Help/Usage Info
  echo "${WHITE}Usage:${NC} ${GRAY}$0 release app namespace${NC}"
  echo "${WHITE}Arguments:${NC}"
  echo "  ${GRAY}release - staging or production. Default: staging"
  echo "  app - name of the app to get.  Default: core-ui-service"
  echo "  namespace - the namespace to use.  Default: web-application-platform${NC}\n"

  # Script Output Starts Here
  echo "${WHITE}Release:${NC}    $release"
  echo "${WHITE}Namespace:${NC}  $namespace"

  for context in $contexts
  do
    echo "${WHITE}Context:${NC}    ${ORANGE}${BOLD}$context${NC}"
    echo -e "${WHITE}Command:    ${PURPLE}kubectl get pods --context $context -L tag,chart -l release=$release,app=$app -n $namespace${NC}"
    kubectl get pods --context $context -L tag,chart -l release=$release,app=$app -n $namespace
  done
}

gallpods() {
  echo 'Running:  kubectl get pods --context kube02nym2 -L chart,tag -l release=production --all-namespaces'
  kubectl get pods --context kube02nym2 -L tag,chart -l release=production --all-namespaces
}
