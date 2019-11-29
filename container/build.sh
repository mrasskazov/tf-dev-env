#!/bin/bash -e
BRANCH=mcp/R5.1
IMAGE=docker-test-local.docker.mirantis.net/tungsten-ci/developer-sandbox

while getopts ":b:i:" opt; do
    case $opt in
      b) BRANCH=$OPTARG
         ;;
      i) IMAGE=$OPTARG
         ;;
      \?) echo "Invalid option: $opt"; exit 1;;
    esac
done

shift $((OPTIND-1))

TAG=${1:-R5.1}
CONTRAIL_KEEP_LOG_FILES=${CONTRAIL_KEEP_LOG_FILES:-'false'}

logfile="./build-tf-dev-env.log"
echo Building tf-dev-env image: ${IMAGE}:${TAG} | tee $logfile
cp ../tpc.repo.template tpc.repo

build_opts="--build-arg LC_ALL=en_US.UTF-8 --build-arg LANG=en_US.UTF-8 --build-arg LANGUAGE=en_US.UTF-8"
build_opts+=" --build-arg BRANCH=${BRANCH} --no-cache --tag ${IMAGE}:${TAG} ."

if [[ "${CONTRAIL_KEEP_LOG_FILES,,}" != 'true' ]] ; then
   docker build $build_opts 2>&1 | tee -a $logfile
   result=${PIPESTATUS[0]}
   if [ $result -eq 0 ]; then
      rm -f $logfile
   fi
else
   # skip output into terminal
   docker build $build_opts >> $logfile 2>&1
fi

exit $result
