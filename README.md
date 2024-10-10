

# Kubernetes GKE Architecture with RabbitMQ, Redis, and KEDA

This repository contains the infrastructure and configuration files for deploying a scalable architecture on **Google Kubernetes Engine (GKE)**. The architecture includes **RabbitMQ**, **Redis**, and **KEDA** for event-driven autoscaling, with configuration settings for the **Listener** and **Publisher** pods.

![Architecture Diagram](https://github.com/Nadav23AnT/K8s-Event-Driven-Microservices/blob/main/A%20detailed%20architecture%20diagram%20illustrating%20how%20GKE%2C%20RabbitMQ%2C%20Redis%2C%20and%20KEDA%20work%20together%20in%20an%20event-driven%20microservices%20setup.png)

## Overview

The system is designed to process workloads asynchronously, using RabbitMQ as the messaging queue, Redis for caching, and KEDA for auto-scaling based on the number of messages in the RabbitMQ queue. The architecture also uses Kubernetes ConfigMaps to store configuration files for the Listener and Publisher pods.

---

## Components

- **GKE (Google Kubernetes Engine)**: Hosts the Kubernetes cluster where the architecture is deployed.
- **Listener Pod**: Reads data and sends tasks to RabbitMQ and Redis.
- **Publisher Pods**: Consumes tasks from RabbitMQ and scales according to the queue size using KEDA.
- **Redis**: In-memory data store used for caching.
- **RabbitMQ**: Messaging broker that handles tasks.
- **KEDA**: Autoscaler that scales Publisher pods based on RabbitMQ message queue length.
- **ConfigMaps**: Stores configuration files used by Listener and Publisher pods.

---

## Start Script (`start.sh`)

This repository includes a **start.sh** script, which automates the deployment and management of services within the GKE cluster. The script allows you to start services, validate deployments, forward ports for RabbitMQ, and uninstall services.

> **Note:**  
> The `start.sh` script is a temporary solution to quickly test and validate the system. For production environments, it's recommended to use proper CI/CD pipelines with tools like **ArgoCD** to manage deployments, updates, and monitoring in a more scalable and maintainable way.

### Script Actions

1. **Start Services**:
   - Deploys RabbitMQ and KEDA using Helm.
   - Deploys Redis, Listener, and Publisher services.
   - Creates necessary ConfigMaps for storing configuration files for Listener and Publisher.
   - Launches a test pod for network validation.

2. **Validate Services**:
   - Validates that deployments, pods, and services are running successfully.
   - Lists the active deployments, pods, services, and cronjobs in the namespace.

3. **Port Forward RabbitMQ**:
   - Opens a port-forward session to access the RabbitMQ management interface on `localhost:15672`.

4. **Uninstall Services**:
   - Uninstalls RabbitMQ and KEDA Helm charts.
   - Deletes Redis, Listener, Publisher services, and associated Kubernetes resources (ConfigMaps, test pod).

### Running the Script

To execute the script, follow these steps:

1. **Ensure the script is executable**:
   ```bash
   chmod +x start.sh
   ```

2. **Run the script**:
   ```bash
   ./start.sh
   ```

3. **Choose an action** when prompted:
   - `1`: Start Services
   - `2`: Validate Services
   - `3`: Port Forward RabbitMQ
   - `4`: Uninstall Services

---

## Future Enhancements

- **Prometheus Integration**: Add Prometheus for monitoring the health and performance of the system.
- **Grafana Integration**: Implement Grafana for better visualization of the metrics collected by Prometheus.
- **ILB for RabbitMQ**: Instead of using port forwarding, configure an **Internal Load Balancer (ILB)** to expose RabbitMQ as a service within the cluster.
- **CI/CD Pipeline**: Replace the `start.sh` script with a robust CI/CD pipeline using **ArgoCD** or similar tools for production-ready deployments.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

