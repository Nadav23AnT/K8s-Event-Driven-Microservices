#!/bin/bash

NAMESPACE="dev"

# Function to print and run commands
run_command() {
    echo -e "\n\033[1;34m$1\033[0m"
    eval $1
}
# auth: gcloud container clusters get-credentials bbg-zak-gke-cluster --location me-west1
gcloud container clusters get-credentials bbg-zak-gke-cluster \
    --region me-west1 \
    --project=dgt-gcp-moe-bbg-test \
    --impersonate-service-account=gke-sa-admin@dgt-gcp-moe-bbg-test.iam.gserviceaccount.com
# kubectl create configmap ip-masq-agent \
#    --namespace=kube-system \
#    --from-file=config=/home/nadav_chen/GIT/moe-bbg-test/config-ip.yaml

# Function to start dependencies (Redis, RabbitMQ, Internal LB, and ScaledObject)
start_dependencies() {
    echo "Starting RabbitMQ..."
    # Installing RabbitMQ using Helm
    run_command "helm install rabbitmq rabbitmq --namespace $NAMESPACE -f ./rabbitmq/values.yaml"
    
    echo "Installing KEDA..."
    # Installing KEDA using Helm
    run_command "helm install keda keda --namespace $NAMESPACE -f ./keda/values.yaml"

    echo "Starting Redis and RabbitMQ-related dependencies..."

    # Install Redis and RabbitMQ chart
    run_command "helm install redis-rabbitmq ./redis-rabbitmq-chart --namespace $NAMESPACE -f ./redis-rabbitmq-chart/values.yaml"

    echo "Running network test pod..."
    run_command "kubectl run toolbox --image=busybox:latest -n $NAMESPACE --restart=Never -- sleep 3600"
    echo "Dependencies started successfully!"
}

# Function to start services (Listener and Publisher)
start_services() {
    echo "Starting Listener and Publisher services..."

    # Install Listener and Publisher chart
    run_command "helm install listener-publisher ./listener-publisher-chart --namespace $NAMESPACE -f ./listener-publisher-chart/values.yaml"

    echo "Services started successfully!"
}


# Function to validate services
validate_services() {
    echo "Validating deployments, pods, and services..."
    run_command "kubectl get deployments --namespace $NAMESPACE"
    run_command "kubectl get pods --namespace $NAMESPACE"
    run_command "kubectl get svc --namespace $NAMESPACE"
    run_command "kubectl get cronjob --namespace $NAMESPACE"
}

# Function to uninstall dependencies (Redis, RabbitMQ, and Internal LB)
uninstall_dependencies() {

    echo "Uninstalling Redis and RabbitMQ-related dependencies..."

    # Uninstall Redis and RabbitMQ chart
    run_command "helm uninstall redis-rabbitmq --namespace $NAMESPACE"

    echo "Dependencies uninstalled successfully!"

    echo "Uninstalling KEDA and RabbitMQ Helm releases..."

    run_command "helm uninstall rabbitmq --namespace $NAMESPACE"
    run_command "helm uninstall keda --namespace $NAMESPACE"
    run_command "kubectl delete pod toolbox --namespace $NAMESPACE"
}

# Function to uninstall services (Listener and Publisher)
uninstall_services() {
    echo "Uninstalling Listener and Publisher services..."

    # Uninstall Listener and Publisher chart
    run_command "helm uninstall listener-publisher --namespace $NAMESPACE"

    echo "Services uninstalled successfully!"
}

# Function to configure Kubernetes credentials
credentials_apply() {
    run_command "gcloud container clusters get-credentials bbg-zak-gke-cluster --region me-west1"
}


# Main menu loop
while true; do
    clear
    echo -e "\033[1;36m#################################################################\033[0m"
    echo -e "\033[1;36m#           BBG ZAK - Kubernetes Management  [Nadav Chen]         #\033[0m"
    echo -e "\033[1;36m#################################################################\033[0m"
    echo ""
    echo -e "\033[1;33mSelect an action from the list below:\033[0m"
    echo -e "\033[1;32m[1]\033[0m Start Dependencies (Redis, RabbitMQ, etc.)"
    echo -e "\033[1;32m[2]\033[0m Start Services (Listener and Publisher)"
    echo -e "\033[1;32m[3]\033[0m Validate Services (Check Deployments, Pods)"
    echo -e "\033[1;32m[4]\033[0m Uninstall Dependencies"
    echo -e "\033[1;32m[5]\033[0m Uninstall Services"
    echo -e "\033[1;31m[6]\033[0m Exit"
    echo ""
    echo -e "\033[1;33mEnter your choice (1-6):\033[0m"
    read -p "> " choice

    case $choice in
        1)
            start_dependencies
            ;;
        2)
            start_services
            ;;
        3)
            validate_services
            ;;
        4)
            uninstall_dependencies
            ;;
        5)
            uninstall_services
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "\033[1;31mInvalid choice! Please select a valid option.\033[0m"
            ;;
    esac

    # Pause and prompt to return to the menu
    echo -e "\n\033[1;33mPress Enter to return to the menu...\033[0m"
    read
done


