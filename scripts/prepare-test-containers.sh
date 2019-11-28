#!/bin/bash -e

REPODIR=/root/src/${CANONICAL_HOSTNAME}/tungsten/contrail-test
BRANCH=${SB_BRANCH:-mcp/R5.1}

[ -d ${REPODIR} ] || git clone https://gerrit.mcp.mirantis.com/tungsten/contrail-test -b ${BRANCH}  ${REPODIR}
cp common.env ${REPODIR}
if [ -f tpc.repo.template ]; then
  cp tpc.repo.template ${REPODIR}/docker/base/tpc.repo
  cp tpc.repo.template ${REPODIR}/docker/test/tpc.repo
fi
