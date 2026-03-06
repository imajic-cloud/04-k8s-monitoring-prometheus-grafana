#!/bin/bash

echo "🗑️  Uninstalling Kubernetes Monitoring Stack..."

# Uninstall Prometheus stack
echo "📦 Removing Prometheus and Grafana..."
helm uninstall prometheus --namespace monitoring

# Delete sample app
echo "🧹 Removing sample application..."
kubectl delete -f sample-app/ --ignore-not-found=true

# Optional: Delete namespace (uncomment if you want to remove everything)
# echo "📂 Deleting monitoring namespace..."
# kubectl delete namespace monitoring

echo "✅ Uninstall complete!"
echo ""
echo "Note: To also delete the monitoring namespace, uncomment the last section in this script."