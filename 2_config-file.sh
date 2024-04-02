#!/usr/bin/bash

config_file(){
    # Update the install-config.yaml file
    echo "" && echo "==> Create install-config.yml using ansible"
    cd config-files/ && ansible-playbook install-config.yml && cd ..


    # Why this script?
    # Ansible has this irritating character of converting any double quotes into single quotes when it reads a string into a variable.
    # When pasted like that in the install-config.yaml, the manifests build cmd fails!

    # After trying a number of ansible modules like slurp, lookup etc, I settled to using a bash script in the backgroud to do the heavy lifting.

    # Assign command line arguments to variables

    echo "" && echo "==> Replace place holder in the install-config.yaml with pull-secret"
    pull_secret_place_holder=pull_secret_place_holder
    pull_secret_string=$(cat $HOME/pull-secret.txt)

    # Perform replacement using sed
    sed -i "s/${pull_secret_place_holder}/${pull_secret_string}/g" "$HOME/install-config.yaml"
    

    # Obtains subnet IDs
    echo "" && echo "==> Obtain subnets associated with the obtained VPC ID"
    
    # Step 1: Get the VPC ID using the VPC name
    vpc_name=${CLUSTER_NAME}-vpc
    vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --query "Vpcs[0].VpcId" --output text)

    # Step 2: Obtain all subnets associated with the obtained VPC ID
    # subnet_ids=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query "Subnets[].SubnetId" --output text)
    subnet_0=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query "Subnets[0].SubnetId" --output text)
    subnet_1=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query "Subnets[1].SubnetId" --output text)

    subnet_0_place_holder=subnet_0_id_place_holder 
    subnet_1_place_holder=subnet_1_id_place_holder

    # Perform replacement using sed
    sed -i "s/${subnet_0_place_holder}/${subnet_0}/g" "$HOME/install-config.yaml"
    sed -i "s/${subnet_1_place_holder}/${subnet_1}/g" "$HOME/install-config.yaml"
}

config_file
