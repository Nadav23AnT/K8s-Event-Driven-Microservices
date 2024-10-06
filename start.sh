#!/bin/bash

NAMESPACE="bbg-zak-dev"

# Function to print and run commands
run_command() {
    echo -e "\n\033[1;34m$1\033[0m"
    eval $1
}

# Function to start everything
start_services() {
    echo "Starting RabbitMQ and KEDA..."
    run_command "helm install rabbitmq ./dep/rabbitmq/ -f dep/rabbitmq/values.yaml --namespace $NAMESPACE"
    run_command "helm install keda ./dep/keda -f dep/keda/values.yaml --namespace $NAMESPACE"

    echo "Applying Redis deployment and service..."
    run_command "kubectl apply -f redis-deployment.yaml --namespace $NAMESPACE"
    run_command "kubectl apply -f redis-service.yaml --namespace $NAMESPACE"

    echo "Creating configmap..."
    run_command "kubectl create configmap listener-appsettings-config --from-file=appsettings/listen-conf/appsettings.dev.json --namespace $NAMESPACE"
    run_command "kubectl create configmap publisher-appsettings-config --from-file=appsettings/publish-conf/appsettings.dev.json --namespace $NAMESPACE"

    echo "Applying listener deployment and publisher job..."
    run_command "kubectl apply -f listener-deployment.yaml --namespace $NAMESPACE"
    run_command "kubectl apply -f publisher-job.yaml --namespace $NAMESPACE"

    # echo "Applying RabbitMQ ScaledObject..."
    # run_command "kubectl apply -f rabbitmq-scaler.yaml --namespace $NAMESPACE"

    echo "Running network test pod..."
    run_command "kubectl run --namespace $NAMESPACE network-test-pod --image=curlimages/curl --restart=Never --command -- sleep 3600 "
}

# Function to validate services
validate_services() {
    echo "Validating deployments, pods, and services..."
    run_command "kubectl get deployments --namespace $NAMESPACE"
    run_command "kubectl get pods --namespace $NAMESPACE"
    run_command "kubectl get svc --namespace $NAMESPACE"
    run_command "kubectl get cronjob --namespace $NAMESPACE"
}

# Function to enable port forwarding for RabbitMQ
port_forward() {
    echo "Port forwarding for RabbitMQ..."
    run_command "kubectl port-forward svc/rabbitmq 15672:15672 --namespace $NAMESPACE"
}

# Function to uninstall everything
uninstall_services() {
    echo "Uninstalling KEDA and RabbitMQ Helm releases..."
    run_command "helm uninstall keda --namespace $NAMESPACE"
    run_command "helm uninstall rabbitmq --namespace $NAMESPACE"

    echo "Deleting listener, publisher, and Redis deployments and services..."
    run_command "kubectl delete deployment listener --namespace $NAMESPACE"
    run_command "kubectl delete cronjob.batch/publisher-cronjob --namespace $NAMESPACE"
    run_command "kubectl delete deployment redis-deployment --namespace $NAMESPACE"
    run_command "kubectl delete service rabbitmq --namespace $NAMESPACE"
    run_command "kubectl delete service redis --namespace $NAMESPACE"
    run_command "kubectl delete pod/network-test-pod --namespace $NAMESPACE"
    run_command "kubectl delete configmap/publisher-appsettings-config --namespace $NAMESPACE"
    run_command "kubectl delete configmap/listener-appsettings-config --namespace $NAMESPACE"

    echo "Deleting RabbitMQ ScaledObject..."
    run_command "kubectl delete scaledobject rabbitmq-scaledobject --namespace $NAMESPACE"

    echo "Verifying deletions..."
    run_command "kubectl get deployments --namespace $NAMESPACE"
    run_command "kubectl get services --namespace $NAMESPACE"
    run_command "kubectl get pods --namespace $NAMESPACE"
    run_command "kubectl get scaledobjects --namespace $NAMESPACE"
}

# Main menu
echo "Choose an action:"
echo "1. Start Services"
echo "2. Validate Services"
echo "3. Port Forward RabbitMQ"
echo "4. Uninstall Services"
read -p "Enter your choice [1-4]: " choice

case $choice in
    1)
        start_services
        ;;
    2)
        validate_services
        ;;
    3)
        port_forward
        ;;
    4)
        uninstall_services
        ;;
    *)
        echo "Invalid choice!"
        ;;
esac
