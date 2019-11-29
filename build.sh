#!/bin/bash -xue
set -o pipefail

./cleanup.sh -v
sudo -E \
    AUTOBUILD=${AUTOBUILD:-1} \
    EXTERNAL_REPOS=${EXTERNAL_REPOS:-${WORKSPACE:-${HOME}}/src} \
    SRC_ROOT=${SRC_ROOT:-${WORKSPACE:-${HOME}}/contrail} \
    CANONICAL_HOSTNAME=${CANONICAL_HOSTNAME:-gerrit.mcp.mirantis.net} \
    ./startup.sh
EXIT_CODE=$?
exit ${EXIT_CODE}
