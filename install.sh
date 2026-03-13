#!/bin/bash

echo "🚀 Installing Kubernetes Monitoring Stack..."

# Add Helm repo
echo "📦 Adding Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create namespace
echo "📂 Creating monitoring namespace..."
kubectl create namespace monitoring

# Install kube-prometheus-stack
echo "📊 Installing Prometheus + Grafana..."
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values/prometheus-values.yaml

# Deploy sample app
echo "🌐 Deploying sample app..."
kubectl apply -f sample-app/

echo "✅ Done!"
echo "Grafana: http://localhost:30080 (admin/admin)"
echo "Sample App: http://localhost:30081"
