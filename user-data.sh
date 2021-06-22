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
        "value": "production"
    }, 
    "pg_dbname": {
        "value": "${pg_dbname}"
    },
    "pg_netloc": {
        "value": "${pg_netloc}"
    },
    "pg_password": {
        "value": "${pg_password}"
    },
    "pg_user": {
        "value": "${pg_user}"
    },
    "production_type": {
        "value": "external"
    },
     "aws_instance_profile": {
        "value": "1"
    },
    "s3_bucket": {
        "value": "${s3_bucket}"
    },
    "s3_region": {
        "value": "${s3_region}"
    }
}
EOF
#get private ip from instance
# export PRIVATE_IP="$(hostname -I | awk '{print $1}')"
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
#get machine public ip
# export PUBLIC_IP="$(curl ipinfo.io/ip)"
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Hacks - create the initial DBs for users, so they can login
sudo apt-get install postgresql-client -y

if ${pg_user} != postgres
then 
    PGPASSWORD=${pg_password} createdb -h ${pg_address} -U ${pg_user} ${pg_user}
fi

PGPASSWORD=${pg_password} createdb -h ${pg_address} -U ${pg_user} ${pg_dbname}

# install replicated
curl https://install.terraform.io/ptfe/stable > /home/ubuntu/install_ptfe.sh

sudo bash /home/ubuntu/install_ptfe.sh no-proxy private-address=$PRIVATE_IP public-address=$PUBLIC_IP

while ! curl -ksfS --connect-timeout 5 https://${hostname}/_health_check; do
    sleep 15
done

  cat > /home/ubuntu/initialuser.json <<EOF
{
  "username": "${initial_admin_username}",
  "email": "${initial_admin_email}",
  "password": "${initial_admin_password}"
}
EOF

INITIAL_TOKEN=$(replicated admin retrieve-iact | tr -d '\r')

curl --header "Content-Type: application/json" --request POST --data-binary "@/home/ubuntu/initialuser.json" https://${hostname}/admin/initial-admin-user?token=$INITIAL_TOKEN