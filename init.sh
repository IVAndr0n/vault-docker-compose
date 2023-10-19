#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Name:           init.sh
# Description:    docker_manual-install
# Code revision:  Andrey Eremchuk, https://github.com/IVAndr0n/
# ------------------------------------------------------------------------------
set -o xtrace

location="$(cd "$(dirname -- "$0")" && pwd -P)"

# creating directories for Docker volumes
mkdir -p ${location}/vault/{config,file,logs}

vault_server_fqdn=vault.example.com
vault_dir_config=${location}/vault/config
vault_dir_data=${location}/vault/file
docker_vault_dir_data=/vault/file       # Don't change!
vault_file_config=vault.hcl

# fill in the vault.hcl configuration file
echo "Configuring Vault"
tee ${vault_dir_config}/${vault_file_config} <<EOF
listener "tcp" {
  address               = "0.0.0.0:8200"
  tls_disable           = 1
}
storage "file" {
    path                = "${docker_vault_dir_data}"
}
ui                      = true
disable_mlock           = true
log_level               = "error"
api_addr                = "http://${vault_server_fqdn}:8200"
EOF

# starting container
docker-compose pull && exec docker-compose up -d

# delete container
#docker-compose down -v