#!/usr/bin/env bash

# Internal cert
function get_internal_cert() {
./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
ubuntulandscape.r00tz0.xyz
}

# Per the documentation, Keeper Automator requires a separate cert
function get_automator_cert() {
./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
UbuntuLandscape.ghgsat.com

keeper_certdir="$(eval echo "~${CURRENT_USER}")/.acme.sh/UbuntuLandscape.ghgsat.com"
openssl pkcs12 -export -passout pass: \
        -out ${keeper_certdir}/ubuntulandscape.r00tz0.xyz.pfx \
        -inkey ${keeper_certdir}/ubuntulandscape.r00tz0.xyz.key \
        -in ${keeper_certdir}/fullchain.cer \
        -certfile ${keeper_certdir}/ubuntulandscape.r00tz0.xyz.cer
}

# function get_analytics_cert() {
# ./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
# ganymede.ghgsat.com,\
# *.ganymede.ghgsat.com,\
# magrathea.ghgsat.com,\
# *.magrathea.ghgsat.com
# }

# # Networking cert
# function get_networking_cert() {
# ./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
# sw-505-1.ghgsat.com,\
# sw-505-2.ghgsat.com,\
# sw-506-1.ghgsat.com,\
# wapmaster.ghgsat.com
# }

# # ESRI cert
# function get_esri_cert() {
# ./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
# 1511-docker.ghgsat.com,\
# esri-fme.ghgsat.com,\
# esri-portal.ghgsat.com
# }

# # Synology certs
# function get_nas_cert() {
# ./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
# aramis.ghgsat.com,\
# backupnas.ghgsat.com,\
# ceres.ghgsat.com,\
# demeter.ghgsat.com,\
# mercury.ghgsat.com,\
# saturn.ghgsat.com,\
# truenas-mtldc-1.ghgsat.com,\
# vesta.ghgsat.com
# }

# function get_visure_cert() {
# ./acme.sh/acme.sh --issue --dns dns_dnsimple -d \
# visure.ghgsat.com

# visure_certdir="$(eval echo "~${CURRENT_USER}")/.acme.sh/visure.ghgsat.com"
# openssl pkcs12 -export -passout pass: \
#         -out ${visure_certdir}/visure.ghgsat.com.pfx \
#         -inkey ${visure_certdir}/visure.ghgsat.com.key \
#         -in ${visure_certdir}/fullchain.cer \
#         -certfile ${visure_certdir}/visure.ghgsat.com.cer
# }

# # Main
# if [[ -z "${DNSimple_OAUTH_TOKEN}" ]]; then
#     echo "DNSimple_OAUTH_TOKEN is not set, please set it:"
#     read -s DNSimple_OAUTH_TOKEN
# fi

# Comment or uncomment those depending on what you need
get_internal_cert
#get_automator_cert
#get_analytics_cert
#get_networking_cert
#get_esri_cert
#get_nas_cert
#get_visure_cert
