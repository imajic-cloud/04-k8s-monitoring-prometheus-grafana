# Project 4: Kubernetes Monitoring - Prometheus + Grafana

## Stack
- Kubernetes (Docker Desktop)
- Prometheus (kube-prometheus-stack Helm chart)
- Grafana (NodePort 30080)
- AlertManager
- Kube State Metrics
- Sample App: nginx (3 replicas, NodePort 30081)
- Namespace: monitoring

## Prerequisites
- Docker Desktop with Kubernetes enabled
- Helm installed
- kubectl installed

## Installation

### 1. Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

### 2. Create namespace
kubectl create namespace monitoring

### 3. Install kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values/prometheus-values.yaml

### 4. Deploy sample app
kubectl apply -f sample-app/

## Access

| Service    | URL                   | Credentials |
|------------|-----------------------|-------------|
| Grafana    | http://localhost:30080 | admin/admin |
| Sample App | http://localhost:30081 | -           |

## Import Grafana Dashboard
1. Open Grafana → Dashboards → Import
2. Upload dashboards/sample-app-dashboard.json
3. Click Import

## Docker Desktop Limitations
- node-exporter disabled (host filesystem permission issues)
- Persistence disabled for Grafana and Prometheus

## Project Structure
.
├── dashboards/
│   └── sample-app-dashboard.json
├── sample-app/
│   ├── deployment.yaml
│   └── service.yaml
├── values/
│   └── prometheus-values.yaml
├── uninstall.sh
└── README.md

## Uninstall
./uninstall.sh