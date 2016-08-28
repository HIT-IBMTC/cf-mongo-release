#!/usr/bin/env bash

set -e

fail() { echo -e "$*" ; exit 1 ; }

bosh_cli_check() {
  if ! command -v bosh &>/dev/null
  then fail "'bosh' command was not found in your path, please 'gem install bosh_cli' and try again."
  fi
}

bosh_target_check() {
  boshTarget=$(bosh target 2>&1)
  case "${boshTarget}" in
    (Current\ target\ is*)
      echo ${boshTarget}
      ;;
    (*)
      fail "A bosh director is not targeted, please target a director and login then try again."
      ;;
  esac
}

usage() {
  echo "
Usage: $0 <prepare|blobs|manifest|release|destroy> [options]
Where [options] for the 'prepare', 'manifest' and 'stemcell' actions are:
  'warden' or 'aws-ec2'
"
}

requireCommands() {
  for cmd in ${@}
  do
    if ! command -v ${cmd} &>/dev/null
    then
      echo "${cmd} must be installed and available in the PATH in order to run $0"
      exit 1
    fi
  done
}

select_infrastructure() {
  infrastructure=${1:-}
  if ! [[ -n ${infrastructure:-} ]]
  then
    usage
    fail
  fi
}

prepare_blobs() {
  [ -d "${releasePath}/blobs" ] || mkdir "${releasePath}/blobs"
  echo "Preparing all packages..."

  #find -path './packages/*' -name prepare -type f -exec bash -c "[ -s ${releasePath}/blobs/${0:2} ] && ( echo $releasePath/blobs/${0:2}; cd ${releasePath}/blobs ; $SHELL ${releasePath}/${0:2} )" {} \;
  for prep in $(find -path './packages/*' -name prepare -type f)
  do
    if [ -s ${prep} ]
    then
      echo ${prep}
      ( cd ${releasePath}/blobs ; ${SHELL} ${releasePath}/${prep} )
    else
      echo Could not find ${prep}
    fi
  done
}

prepare_dev_release() {
  echo "bosh create release --with-tarball --force"
  bosh create release --with-tarball --force
  echo "bosh -n upload release"
  bosh -n upload release
}

if [[ ${DEBUG:-"false"} == "true" ]]
then # Enable xtrace with context if debug is true.
  export PS4='+(${BASH_SOURCE}:${LINENO})> ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  set -x
fi

releasePath=$(cd $(dirname $0) ; echo $PWD)
tmpPath=${releasePath}/tmp
manifestsPath=${releasePath}/manifests
stemcellsPath=${releasePath}/stemcells
releaseName=$(awk -F: '/final_name/{print $2}' $releasePath/config/final.yml | tr -d ' ')
templatesPath="${releasePath}/templates"

if (( $# > 0 ))
then
  action=$1
  shift
else
  usage
  fail
fi

bosh_target_check
bosh_cli_check

declare -a args
if (( ${#@} ))
then args=($(echo "${@}"))
fi
case ${action} in
  (prepare)
    if (( ${#args[@]} == 0 ))
    then
      usage
      fail
    fi
    prepare_blobs
    prepare_dev_release
    ;;
  (release|dev)
    prepare_dev_release
    ;;
  (blobs)
    prepare_blobs
    ;;
  (destroy|delete)
    echo "bosh -n delete deployment sm-mongo-warden --force"
    bosh -n delete deployment sm-mongo-warden --force
    ;;
  (*)
    usage
    fail "Unknown action ${action}."
    ;;
esac

exit 0
