#!/usr/bin/bash

# Why this script?
# Ansible has this irritating character of converting any double quotes into single quotes when it reads a string into a variable.
# When pasted like that in the install-config.yaml, the manifests build cmd fails!

# After trying a number of ansible modules like slurp, lookup etc, I settled to using a bash script in the backgroud to do the heavy lifting.

# Assign command line arguments to variables
old_string=pull_secret_string
pull_secret_file=$1
new_string=$(cat ${pull_secret_file})
file_path=$2

# Perform replacement using sed
sed -i "s/${old_string}/${new_string}/g" "$file_path"

# Usage 
# replace_string.sh pull_secret_file file_path