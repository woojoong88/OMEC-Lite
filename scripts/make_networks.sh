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

# Network: an overview
# db_net (b/w hss_db and hss): 192.168.100.0/24
DB_NET_SUBNET="192.168.100.0/24"
# s6a_net (b/w hss and mme): 192.168.101.0/24
S6A_NET_SUBNET="192.168.101.0/24"
# s1mme_net (b/w eNB and mme): 192.168.102.0/24
S1MME_NET_SUBNET="192.168.102.0/24"
# s11_net (b/w mme and spgw-c): 192.168.103.0/24
S11_NET_SUBNET="192.168.103.0/24"
# sx_net: (b/w spgw-c and spgw-u): 192.168.104.0/24
SX_NET_SUBNET="192.168.104.0/24"
# s1u_net: (uplink b/w spgw-u and eNB): 192.168.105.0/24
S1U_NET_SUBNET="192.168.105.0/24"
# sgi_net: (downlink b/w spgw-u and eNB): 192.168.106.0/24
SGI_NET_SUBNET="192.168.106.0/24"

get_gateway_ip() {
    echo $1 | awk -F "/" '{print $1}' | awk -F "." '{print $1"."$2"."$3".254"}'
}

echo "Make networks"
docker network create --driver=bridge --subnet=$DB_NET_SUBNET --ip-range=$DB_NET_SUBNET --gateway=$(get_gateway_ip $DB_NET_SUBNET) db_net
docker network create --driver=bridge --subnet=$S6A_NET_SUBNET --ip-range=$S6A_NET_SUBNET --gateway=$(get_gateway_ip $S6A_NET_SUBNET) s6a_net
docker network create --driver=bridge --subnet=$S1MME_NET_SUBNET --ip-range=$S1MME_NET_SUBNET --gateway=$(get_gateway_ip $S1MME_NET_SUBNET) s1mme_net
docker network create --driver=bridge --subnet=$S11_NET_SUBNET --ip-range=$S11_NET_SUBNET --gateway=$(get_gateway_ip $S11_NET_SUBNET) s11_net
docker network create --driver=bridge --subnet=$SX_NET_SUBNET --ip-range=$SX_NET_SUBNET --gateway=$(get_gateway_ip $SX_NET_SUBNET) sx_net
docker network create --driver=bridge --subnet=$S1U_NET_SUBNET --ip-range=$S1U_NET_SUBNET --gateway=$(get_gateway_ip $S1U_NET_SUBNET) s1u_net
docker network create --driver=bridge --subnet=$SGI_NET_SUBNET --ip-range=$SGI_NET_SUBNET --gateway=$(get_gateway_ip $SGI_NET_SUBNET) sgi_net
