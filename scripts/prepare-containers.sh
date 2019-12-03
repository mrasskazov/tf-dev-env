#!/bin/bash -e

REPODIR=/root/src/${CANONICAL_HOSTNAME}/tungsten/contrail-container-builder
BRANCH=${SB_BRANCH:-mcp/R5.1}

[ -f buildpipeline.env ] && . buildpipeline.env

[ -d ${REPODIR} ] || git clone https://gerrit.mcp.mirantis.com/tungsten/contrail-container-builder -b ${BRANCH}  ${REPODIR}

if [ "${GERRIT_PROJECT##*/}" = "contrail-container-builder" ]; then
    pushd ${REPODIR} > /dev/null
        git fetch $(git remote -v | awk '/^origin.*fetch/ {print $2}') ${GERRIT_REFSPEC:?GERRIT_REFSPEC is empty} > /dev/null \
            && git checkout FETCH_HEAD > /dev/null
    popd > /dev/null
fi

for file in tpc.repo.template common.env ; do
  if [ -f $file ]; then
    cp $file ${REPODIR}
  fi
done
