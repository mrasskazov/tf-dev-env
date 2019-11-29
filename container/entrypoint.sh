#!/bin/bash
set -eo pipefail

CANONICAL_HOSTNAME=${CANONICAL_HOSTNAME:-"gerrit.mcp.mirantis.net"}

if [[ -d /config ]]; then
  cp -rf /config/* /
  if [[ -d /config/etc/yum.repos.d ]]; then
    # apply same repos for test containers
    cp -f /config/etc/yum.repos.d/* /root/src/${CANONICAL_HOSTNAME}/tungsten/contrail-test/docker/base/
    cp -f /config/etc/yum.repos.d/* /root/src/${CANONICAL_HOSTNAME}/tungsten/contrail-test/docker/base/
  fi
fi

cd $HOME/contrail
rm -rf .repo
ln -s $HOME/.repo


if [[ "${AUTOBUILD}" -eq 1 ]]; then
    cd $CONTRAIL_DEV_ENV

    echo "INFO: make sync  $(date)"
    make sync

    echo "INFO: make setup  $(date)"
    make setup

    echo "INFO: make dep fetch_packages  $(date)"
    # targets can use yum and will block each other. don't run them in parallel
    make dep fetch_packages
    echo "INFO: Check variables used by makefile"
    uname -a
    make info
    echo "INFO: make rpm  $(date)"
    make rpm

    echo "INFO: make containers  $(date)"
    if [[ "${BUILD_TEST_CONTAINERS}" == "1" ]]; then
        # prepare rpm repo and repos
        echo "INFO: make create-repo prepare-containers prepare-deployers prepare-test-containers  $(date)"
        make -j 4 create-repo prepare-containers prepare-deployers prepare-test-containers
        build_status=$?
        if [[ "$build_status" != "0" ]]; then
            echo "INFO: make prepare containers failed with code $build_status  $(date)"
            exit $build_status
        fi

        # prebuild general base as it might be used by deployers
        echo "INFO: make container-general-base  $(date)"
        make container-general-base
        build_status=$?
        if [[ "$build_status" != "0" ]]; then
            echo "INFO: make general-base container failed with code $build_status $(date)"
            exit $build_status
        fi

        # build containers
        echo "INFO: make containers-only deployers-only test-containers-only  $(date)"
        make -j 6 containers-only deployers-only test-containers-only
        build_status=$?
        if [[ "$build_status" != "0" ]]; then
            echo "INFO: make containers failed with code $build_status $(date)"
            exit $build_status
        fi

        echo Build of containers with deployers has finished successfully
    else
        echo "INFO: make create-repo prepare-containers prepare-deployers   $(date)"
        make -j 3 create-repo prepare-containers prepare-deployers 
        make list-containers | sed -e 's/^container/contrail/' -e 's/_/-/g' > list-containers
        make list-deployers | sed -e 's/^deployer/contrail/' -e 's/_/-/g' > list-deployers

        echo "INFO: make container-general-base $(date)"
        make container-general-base

        echo "INFO: make containers-only deployers-only   $(date)"
        make -j 2 containers-only deployers-only
    fi

    echo "INFO: make successful  $(date)"
    exit 0
fi

/bin/bash
