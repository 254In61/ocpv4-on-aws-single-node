Overview
========
=> Building single node Openshift cluster on AWS for Lab/Demo.

Assumptions
===========
- You are using an Ubuntu/Debian machine as your local environment.


How to use
==========
1. Git clone the repo to your local env.
2. Set your local env variables as put in env-vars file.
3. Download the pull-secret.txt from https://console.redhat.com/openshift/install/pull-secret to $HOME directory.
4. Install openshift-install in your linux local environment
5. Build aws vpc and subnets      : $./1_aws-infra.sh
6. Build install-config.yaml file : $./2_config-file.sh
7. Install cluster                : $./install-cluster.sh


