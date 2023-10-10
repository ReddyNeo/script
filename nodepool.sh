#!/bin/bash

# Azure AKS Node Pool Add Script

# Set your Azure resource group, AKS cluster name, node pool name, and node count
resource_group="Neo"
cluster_name="testing"
nodepool_name="neo2"
node_count=1

# Get the VM size (instance type) of the old nodes in the cluster
old_node_vm_size=$(az aks show --resource-group $resource_group --name $cluster_name --query "agentPoolProfiles[0].vmSize" --output tsv)


# Define autoscaling parameters
min_node_count=1  # Minimum number of nodes
max_node_count=20  # Maximum number of nodes


# Run the Azure CLI command
az aks nodepool add \
    --resource-group $resource_group \
    --cluster-name $cluster_name \
    --name $nodepool_name \
    --node-count $node_count \
    --min-count $min_node_count \
    --max-count $max_node_count \
    --node-vm-size $old_node_vm_size \
    --enable-cluster-autoscaler

# Cordon and drain nodes in the new node pool using kubectl

nodepool_nodes=$(kubectl get nodes -l agentpool=neo1 --no-headers -o custom-columns=NAME:.metadata.name)

for node in $nodepool_nodes; do
    kubectl cordon $node
    kubectl drain $node --ignore-daemonsets
    #kubectl delete node $node
done
