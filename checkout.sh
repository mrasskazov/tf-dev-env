#!/bin/bash -xue
set -o pipefail

cd contrail/
repo download $@
