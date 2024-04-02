Overview
==========
 Directory contains ansible playbooks and roles.

Ansible Roles
===============
1) aws-creds : Builds the ~/.aws/c* files for the AWS CLI to consume.
2) ignition  : Build the ignition config files for the cluster.
3) terraform : Updates the aws-infra-build/terraform.tvars file for the terraform IAC to consume.

Playbooks
=========
1) ignition-files.yml : Playbook that builds the ignition config files.
2) terraform-vars.yml : Playbook that populates the terraform.tvars file.
