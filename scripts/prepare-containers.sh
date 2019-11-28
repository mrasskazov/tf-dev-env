#!/bin/bash -e

REPODIR=/root/src/${CANONICAL_HOSTNAME}/tungsten/contrail-container-builder
BRANCH=${SB_BRANCH:-mcp/R5.1}

[ -d ${REPODIR} ] || git clone https://gerrit.mcp.mirantis.com/tungsten/contrail-container-builder -b ${BRANCH}  ${REPODIR}
for file in tpc.repo.template common.env ; do
  if [ -f $file ]; then
    cp $file ${REPODIR}
  fi
done
