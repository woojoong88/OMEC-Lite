#!/bin/bash
#
# Copyright 2019-present Woojoong Kim
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DOCKER_ACCOUNT=woojoong
HSS_DB_IMAGE=$DOCKER_ACCOUNT/omec-cassandra:v1-debug
HSS_IMAGE=$DOCKER_ACCOUNT/omec-hss:v1-debug
MME_IMAGE=$DOCKER_ACCOUNT/omec-mme:v1-debug
SPGWC_IMAGE=$DOCKER_ACCOUNT/omec-spgwc:v1-debug
SPGWU_IMAGE=$DOCKER_ACCOUNT/omec-spgwu:v1-debug
TRAFFIC_IMAGE=$DOCKER_ACCOUNT/kone-traffic-gen:lite

docker login

echo "Pull docker images"
docker pull $HSS_DB_IMAGE
docker pull $HSS_IMAGE
docker pull $MME_IMAGE
docker pull $SPGWC_IMAGE
docker pull $SPGWU_IMAGE
docker pull $TRAFFIC_IMAGE
