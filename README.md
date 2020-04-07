# Automated Installation of PTFE with External Services in AWS

## What you need

1. terraform  cli 
2. Access to a PTFE license
3. ssh public key at ~/.ssh/id_rsa.pub
4. Route53 zone id


## Deploy

Populate the tfvars file with:
* license
* zone id
* namespace, owner,

Run the commands:


```terraform init```

```terraform plan```

```terraform apply```

Wait 10 min-ish for the installation, and access the dashboard



## Troublueshooting

Sometimes the connection to the PG database times out. Just hit the Start button again at the Dashboard.


# PostgreSQL server


Test connection from EC2
sudo apt-get install postgresql-client
  psql -h server.domain.org database user

