#! /bin/bash


cat > /etc/license.rli <<EOF
${license}
EOF
base64 --decode /etc/license.rli > /etc/replicated.rli

# create replicated unattended installer config
cat > /etc/replicated.conf <<EOF
{
    "BypassPreflightChecks": true,
    "DaemonAuthenticationPassword": "${enc_password}",
    "DaemonAuthenticationType": "password",
    "ImportSettingsFrom": "/etc/replicated-settings.json",
    "LicenseFileLocation": "/etc/replicated.rli",
    "TlsBootstrapType": "self-signed"
}
EOF
cat > /etc/replicated-settings.json <<EOF
{
    "enc_password": {
        "value": "${daemon_password}"
    },
    "hostname": {
        "value": "${hostname}"
    },
    "installation_type": {
        "value": "poc"
    }
}
EOF
#get private ip from instance
# export PRIVATE_IP="$(hostname -I | awk '{print $1}')"
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
#get machine public ip
# export PUBLIC_IP="$(curl ipinfo.io/ip)"
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)


# install replicated
curl https://install.terraform.io/ptfe/stable > /home/ubuntu/install_ptfe.sh

sudo bash /home/ubuntu/install_ptfe.sh no-proxy private-address=$PRIVATE_IP public-address=$PUBLIC_IP
