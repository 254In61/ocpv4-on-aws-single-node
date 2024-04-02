#!/usr/bin/bash

vpc_and_subnets(){
    # Build vpc and the subnets
    echo "" && echo "==> Build vpc and subnets"
    
    echo "" && echo "==> Update 1. aws credentials 2. terraform.tvars file using ansible"
    cd config-files/ && ansible-playbook terraform-vars.yml && cd ..
    
    echo "" && echo "===> Run terraform IAC"
    cd aws-infra/ && terraform init && terraform apply -auto-approve && cd ..

}

vpc_and_subnets