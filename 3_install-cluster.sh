#!/usr/bin/bash
installer(){
    # Assumption is you installed openshift-installer on your local environment.

    # Backup install-config.yaml
    echo "" && echo "==> Backup install-config.yaml"
    cp $HOME/install-config.yaml $HOME/backup-${CLUSTER_NAME}-install-config.yaml

    # Run the installer.
    echo "" && echo "==> Run the installer"
    openshift-install create cluster --dir=$HOME
}

installer