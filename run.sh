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

ROOT_DIR_ABS=$(realpath ${BASH_SOURCE[0]})
ROOT_DIR=$(dirname $ROOT_DIR_ABS)
CONFIG_DIR=$ROOT_DIR/config
source $CONFIG_DIR/shell_config/network.cfg
source $CONFIG_DIR/shell_config/image.cfg
source $CONFIG_DIR/shell_config/volume.cfg

get_gateway_ip() {
    echo $1 | awk -F "/" '{print $1}' | awk -F "." '{print $1"."$2"."$3".254"}'
}

set_docker_bridge() {
    TMP_BRIDGE_NAME=$2
    TMP_SUBNET=$1
    docker network create --driver=bridge --subnet=$TMP_SUBNET --ip-range=$TMP_SUBNET --gateway=$(get_gateway_ip $TMP_SUBNET) $TMP_BRIDGE_NAME
}

pull_docker_image() {
    TMP_DOCKER_IMAGE=$1
    docker pull $TMP_DOCKER_IMAGE
}

get_origin_volume_params() {
    case "$1" in
        $HSS_DB_NAME)
            echo ${HSS_DB_CFG_ORIG[@]}
            ;;
        $HSS_NAME)
            echo ${HSS_CFG_ORIG[@]}
            ;;
        $MME_NAME)
            echo ${MME_CFG_ORIG[@]}
            ;;
        $SPGWC_NAME)
            echo ${NGIC_CFG_ORIG[@]}
            ;;
        $SPGWU_NAME)
            echo ${NGIC_CFG_ORIG[@]}
            ;;
        *)
            echo ""
            ;;
    esac
}

get_target_volume_params() {
    case "$1" in
        $HSS_DB_NAME)
            echo ${HSS_DB_CFG_TARGET[@]}
            ;;
        $HSS_NAME)
            echo ${HSS_CFG_TARGET[@]}
            ;;
        $MME_NAME)
            echo ${MME_CFG_TARGET[@]}
            ;;
        $SPGWC_NAME)
            echo ${NGIC_CFG_TARGET[@]}
            ;;
        $SPGWU_NAME)
            echo ${NGIC_CFG_TARGET[@]}
            ;;
        *)
            echo ""
            ;;
    esac
}

get_volume_param() {
    TMP_CONTAINER_NAME=$1
    TMP_ORIG_PARAM=( $(get_origin_volume_params $TMP_CONTAINER_NAME)  )
    TMP_TARGET_PARAM=( $(get_target_volume_params $TMP_CONTAINER_NAME) )
    RETURN=""
    ITER_IDX=0
    for ELEM in ${TMP_ORIG_PARAM[@]}
    do
        RETURN=$RETURN"-v ${CONFIG_DIR}/${TMP_ORIG_PARAM[ITER_IDX]}:${TMP_TARGET_PARAM[ITER_IDX]} "
        ITER_IDX=$(expr $ITER_IDX + 1)
    done
    echo $RETURN
}

run_docker_image() {
    TMP_CONTAINER_NAME=$1
    TMP_DOCKER_IMAGE=$2
    TMP_VOLUME_OPTION=$(get_volume_param $TMP_CONTAINER_NAME)
    docker run -t -d --name $TMP_CONTAINER_NAME --cap-add=ALL --privileged $TMP_VOLUME_OPTION $TMP_DOCKER_IMAGE bash
}

connect_network_to_image() {
    TMP_BRIDGE_NAME=$1
    TMP_CONTAINER_NAME=$2
    docker network connect $TMP_BRIDGE_NAME $TMP_CONTAINER_NAME
}

pushd $ROOT_DIR

# Pull images
echo "Pull Images!"
pull_docker_image $HSS_DB_IMAGE
pull_docker_image $HSS_IMAGE
pull_docker_image $MME_IMAGE
pull_docker_image $SPGWC_IMAGE
pull_docker_image $SPGWU_IMAGE
pull_docker_image $TRAFFIC_IMAGE

# Make bridges
echo "Make Docker network bridges!"
set_docker_bridge $DB_NET_SUBNET $DB_NET_NAME
set_docker_bridge $S6A_NET_SUBNET $S6A_NET_NAME
set_docker_bridge $S1MME_NET_SUBNET $S1MME_NET_NAME
set_docker_bridge $S11_NET_SUBNET $S11_NET_NAME
set_docker_bridge $SX_NET_SUBNET $SX_NET_NAME
set_docker_bridge $S1U_NET_SUBNET $S1U_NET_NAME
set_docker_bridge $SGI_NET_SUBNET $SGI_NET_NAME

# Run Docker containers
echo "Run containers"
run_docker_image $HSS_DB_NAME $HSS_DB_IMAGE
run_docker_image $HSS_NAME $HSS_IMAGE
run_docker_image $MME_NAME $MME_IMAGE
run_docker_image $SPGWC_NAME $SPGWC_IMAGE
run_docker_image $SPGWU_NAME $SPGWU_IMAGE
run_docker_image $TRAFFIC_NAME $TRAFFIC_IMAGE

# Connect Docker containers to appropriate networks
echo "Connect HSS-DB into db_net"
connect_network_to_image $DB_NET_NAME $HSS_DB_NAME
echo "Connect HSS into db_net and s6a_net"
connect_network_to_image $DB_NET_NAME $HSS_NAME
connect_network_to_image $S6A_NET_NAME $HSS_NAME
echo "Connect MME into s6a_net, s1mme_net, and s11_net"
connect_network_to_image $S6A_NET_NAME $MME_NAME
connect_network_to_image $S1MME_NET_NAME $MME_NAME
connect_network_to_image $S11_NET_NAME $MME_NAME
echo "Connect SPGWC into s11_net and sx_net"
connect_network_to_image $S11_NET_NAME $SPGWC_NAME
connect_network_to_image $SX_NET_NAME $SPGWC_NAME
echo "Connect SPGWU into sx_net, s1u_net, and sgi_net"
connect_network_to_image $SX_NET_NAME $SPGWU_NAME
connect_network_to_image $S1U_NET_NAME $SPGWU_NAME
connect_network_to_image $SGI_NET_NAME $SPGWU_NAME
echo "Connect Traffic into s11_net, s1u_net, and sgi_net"
connect_network_to_image $S11_NET_NAME $TRAFFIC_NAME
connect_network_to_image $S1U_NET_NAME $TRAFFIC_NAME
connect_network_to_image $SGI_NET_NAME $TRAFFIC_NAME

popd

