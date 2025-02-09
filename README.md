# BBG-Test Cluster




## 🌟 Overview
The **BBG-Test Project** showcases a cutting-edge Kubernetes-based architecture designed to facilitate seamless communication between a **RabbitMQ Listener** and a **Publisher**. This system is built for scalable, efficient message processing while leveraging Kubernetes for robust container orchestration.


## 🚀 Key Features
- **🔗 RabbitMQ Integration**: Facilitates message queuing and seamless data exchange.
- **🔁 Listener & Publisher**: Core components for processing and publishing messages.
- **⚡ Redis Cache**: Enhances performance with efficient temporary data storage.
- **📈 Scalable Architecture**: Ensures resilience and adaptability via Kubernetes.
- **📊 KEDA Integration**: Dynamically scales Listener pods based on queue load.
- **📦 Helm Charts**: Simplifies deployment of core components.

---

## 🏗️ Architecture
The system comprises the following key components:

### 🐇 RabbitMQ
- **Role**: Acts as the message broker for data exchange between Listener and Publisher pods.
- **Capabilities**: Efficient queue management and message routing.

### 🔍 Redis
- **Role**: Temporary caching for enhanced message processing.
- **Benefit**: Boosts system performance.

### 📤 Publisher Pod
- **Tasks**: 
  - Reads data from an **Oracle Database**.
  - Publishes messages to RabbitMQ queues.
  - Pushes container images to Artifact Registry.

### 📥 Listener Pods
- **Triggered By**: Incoming RabbitMQ messages via KEDA.
- **Responsibilities**:
  - Processes messages.
  - Writes results back to the **Oracle Database**.

### 📈 KEDA (Kubernetes Event-Driven Autoscaling)
- **Purpose**: Monitors RabbitMQ queues and dynamically adjusts Listener pod count based on load.

### 🏬 Artifact Registry
- **Function**: Repository for Publisher and Listener container images.

### 🗄️ Oracle Database
- **Role**: Serves as the main data store.
- **Integration**: Used by both Publisher and Listener components for data operations.

---

## 📋 Prerequisites
- **Kubernetes Cluster**: A functioning cluster is required.
- **Helm**: Installed for managing charts.
- **kubectl**: CLI tool for Kubernetes management.
- **Docker**: To build and manage container images.
- **RabbitMQ & Redis**: Pre-deployed on Kubernetes.

---

## 📂 Folder Structure
The repository contains the following folders and files:

```
BBG-Test
│
├── keda
│   └── (KEDA ScaledObject definitions for autoscaling Listener pods)
│
├── listener-publisher-chart
│   ├── files
│   │   └── appsettings
│   │       ├── listen-conf
│   │       │   └── appsettings.dev.json   # Configuration for the Listener component
│   │       ├── publish-conf
│   │       │   └── appsettings.dev.json   # Configuration for the Publisher component
│   ├── templates
│   │   ├── Chart.yaml                     # Helm chart definition
│   │   └── values.yaml                    # Default Helm values for Listener & Publisher
│
├── rabbitmq
│   ├── charts
│   ├── templates
│   │   ├── Chart.yaml                     # RabbitMQ Helm chart definition
│   │   ├── values.yaml                    # Configuration for RabbitMQ deployment
│   │   ├── values.schema.json             # Schema for Helm values
│   ├── README.md                          # Documentation for RabbitMQ setup
│   └── Chart.lock                         # Helm chart lock file
│
├── redis-rabbitmq-chart
│   ├── templates
│   │   ├── rabbitmq-internal-lb.yaml      # Configuration for RabbitMQ internal load balancer
│   │   ├── rabbitmq-scaledobject.yaml     # KEDA ScaledObject for RabbitMQ autoscaling
│   │   ├── redis-deployment.yaml          # Deployment configuration for Redis
│   │   ├── redis-service.yaml             # Service definition for Redis
│   ├── Chart.yaml                         # Helm chart definition for combined Redis and RabbitMQ
│   └── values.yaml                        # Configuration for Redis and RabbitMQ
│
├── start.sh                               # Script to bootstrap and deploy components
└── README.md                              # Main project documentation
```




### Explanation of Folders:
- **`keda`**: Contains the YAML definitions for KEDA ScaledObjects used to autoscale Listener pods dynamically based on RabbitMQ queue metrics.
- **`listener-publisher-chart`**: Helm chart definitions for deploying Listener and Publisher pods.
  - **`files/appsettings`**: Configuration files for the Listener (`listen-conf`) and Publisher (`publish-conf`).
  - **`templates`**: Contains Helm templates, `Chart.yaml`, and `values.yaml` for the Listener and Publisher deployments.
- **`rabbitmq`**: Contains Helm charts and templates for deploying RabbitMQ with configuration files.
  - **`values.schema.json`**: Defines the schema for Helm values to ensure consistency.
- **`redis-rabbitmq-chart`**: Contains the Helm chart for deploying both Redis and RabbitMQ in a single deployment.
- **`start.sh`**: A script for automating deployments and bootstrapping the environment.
- **`README.md`**: Main project documentation for deployment and usage.

---

## 🛠️ Deployment Steps

### Step 1️⃣: Clone the Repository
```bash
git clone <repository-url>
cd bbg-test
```

### Step 2️⃣: Change variables values
all comments with "# image location" and "# iamge tag" insert the correct location
and make sure the namespace are fine with your other depoloyments (default namespace "dev")


### Step 3️⃣: Deploy RabbitMQ and Redis
Run the script `./start.sh`
```bash
./start.sh
```

### Step 4️⃣: Verify Deployment
Check the pod status:
```bash
kubectl get pods
```
Ensure all pods (RabbitMQ, Redis, Publisher, Listener) are running smoothly.

### Test the System
- Confirm RabbitMQ queues are operational and Publisher is sending messages.
- Validate Listener logs for processed messages.
- Ensure data is correctly written to the Oracle Database.

---

## ⚙️ Configuration
### Essential Environment Variables
- `RABBITMQ_HOST`: Address of the RabbitMQ server.
- `REDIS_HOST`: Address of the Redis server.
- `ORACLE_DB_URL`: Oracle Database connection string.
- `QUEUE_NAME`: Name of the RabbitMQ queue.

Set these variables in the deployment files for both Listener and Publisher.

---

## 🛠️ Troubleshooting

### Common Issues
- **Pods Pending**: Check resource availability in the Kubernetes cluster.
- **Connection Problems**: Verify RabbitMQ, Redis, and Oracle configuration.
- **Error Logs**: Inspect pod logs for troubleshooting:
```bash
kubectl logs <pod-name>
```

---

## 📈 Future Enhancements
- **CI/CD Integration**: Automate deployments.
- **Monitoring**: Add metrics and visualization via Prometheus and Grafana.
- **High Availability**: Scale RabbitMQ and Redis for large workloads.

---

## 📝 License
This project is licensed under the MIT License. See the LICENSE file for full details.

---

## ✍️ Author
**Nadav Chen**
- **GitHub**: [Nadav23AnT](https://github.com/Nadav23AnT/)
- **LinkedIn**: [Nadav Chen](https://www.linkedin.com/in/nadavchen97/)

---

