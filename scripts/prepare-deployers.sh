#!/bin/bash -e

REPODIR=/root/src/${CANONICAL_HOSTNAME}/tungsten/contrail-deployers-containers
BRANCH=${SB_BRANCH:-master}

[ -d ${REPODIR} ] || git clone https://github.com/Juniper/contrail-deployers-containers -b ${BRANCH}  ${REPODIR}
for file in tpc.repo.template common.env ; do
  if [ -f $file ]; then
    cp $file ${REPODIR}
  fi
done
