# Kubernetes Monitoring with Prometheus & Grafana

A production-ready monitoring and observability stack for Kubernetes using Prometheus for metrics collection and Grafana for visualization. This project demonstrates implementing complete cluster monitoring, custom dashboards, and alerting capabilities.

## Overview

This project deploys a comprehensive monitoring solution on a local Kubernetes cluster (kind) using industry-standard tools. It provides real-time visibility into cluster health, resource utilization, application performance, and custom metrics through beautiful Grafana dashboards.

## Architecture
```
Kubernetes Cluster
      │
      ├─► Prometheus (Metrics Collection)
      │   ├─► Node Exporter (System Metrics)
      │   ├─► kube-state-metrics (K8s Object Metrics)
      │   └─► Service Discovery (Auto-discover targets)
      │
      ├─► Grafana (Visualization)
      │   ├─► Pre-built Dashboards
      │   ├─► Custom Dashboards
      │   └─► Data Source (Prometheus)
      │
      ├─► AlertManager (Alerting)
      │
      └─► Sample Application (Nginx)
```

**Data Flow:**
1. **Metrics Collection**: Prometheus scrapes metrics from cluster components
2. **Storage**: Metrics stored in Prometheus time-series database
3. **Visualization**: Grafana queries Prometheus and displays dashboards
4. **Alerting**: AlertManager processes and sends alerts based on rules

## Technologies Stack

| Category | Technology |
|----------|-----------|
| **Monitoring** | Prometheus |
| **Visualization** | Grafana |
| **Alerting** | AlertManager |
| **Metrics Exporters** | Node Exporter, kube-state-metrics |
| **Orchestration** | Kubernetes (kind) |
| **Package Manager** | Helm 3 |
| **Sample Application** | Nginx |
| **Operating System** | Linux (WSL) |

## Project Structure
```
04-k8s-monitoring-prometheus-grafana/
│
├── README.md                          # Project documentation
├── install.sh                         # Automated installation script
├── uninstall.sh                       # Cleanup script
│
├── values/                            # Helm values for customization
│   ├── prometheus-values.yaml         # Prometheus configuration
│   └── grafana-values.yaml            # Grafana configuration
│
├── dashboards/                        # Custom Grafana dashboards
│   └── sample-app-dashboard.json      # Sample app monitoring dashboard
│
├── sample-app/                        # Sample application to monitor
│   ├── deployment.yaml                # Nginx deployment
│   └── service.yaml                   # Service definition
│
└── screenshots/                       # Dashboard screenshots
    ├── grafana-overview.png
    └── sample-app-metrics.png
```

## Prerequisites

Before running this project, ensure you have:

- **Kubernetes Cluster** - kind, Docker Desktop, or minikube
- **kubectl** - Configured and connected to your cluster
- **Helm 3** - Package manager for Kubernetes
- **Docker** - For running containers
- **Linux Environment** - WSL, native Linux, or macOS

### Verify Prerequisites
```bash
# Check Kubernetes
kubectl get nodes

# Check Helm
helm version

# Check Docker
docker ps
```

## Quick Start

### Installation (Automated)
```bash
# Clone or navigate to project directory
cd 04-k8s-monitoring-prometheus-grafana

# Run installation script
./install.sh

# Wait 2-3 minutes for all pods to be ready
kubectl get pods -n monitoring --watch
```

### Access Grafana
```bash
# Port forward Grafana to localhost
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Open browser: **http://localhost:3000**

**Login credentials:**
- Username: `admin`
- Password: Get with:
```bash
  kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## Manual Installation

### Step 1: Add Helm Repositories
```bash
# Add Prometheus community charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Add Grafana charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update repositories
helm repo update
```

### Step 2: Create Namespace
```bash
kubectl create namespace monitoring
```

### Step 3: Install Prometheus Stack
```bash
# Install using custom values
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values/prometheus-values.yaml

# Or install with default values
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring
```

### Step 4: Verify Installation
```bash
# Check all pods are running
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring

# Check persistent volumes
kubectl get pvc -n monitoring
```

### Step 5: Deploy Sample Application
```bash
# Deploy sample nginx app
kubectl apply -f sample-app/

# Verify deployment
kubectl get pods -l app=sample-app
kubectl get svc sample-app
```

## Accessing the Monitoring Stack

### Grafana Dashboard
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Access: **http://localhost:3000**

### Prometheus UI
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Access: **http://localhost:9090**

### AlertManager UI
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

Access: **http://localhost:9093**

## Using Grafana

### Pre-built Dashboards

The stack comes with 30+ pre-configured dashboards:

**Cluster Monitoring:**
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace (Pods)
- Kubernetes / Compute Resources / Node (Pods)

**Node Monitoring:**
- Node Exporter / Nodes
- Node Exporter / USE Method / Node

**Application Monitoring:**
- Kubernetes / Compute Resources / Workload
- Kubernetes / Networking / Pod

### Creating Custom Dashboards

1. Click **☰** → **Dashboards** → **New** → **New Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** as data source
4. Switch to **Code** mode
5. Enter your PromQL query
6. Click **Run queries**
7. Customize visualization
8. Click **Save**

### Example Queries

**CPU Usage by Pod:**
```promql
rate(container_cpu_usage_seconds_total{namespace="default", pod=~"sample-app.*"}[5m])
```

**Memory Usage by Pod:**
```promql
container_memory_usage_bytes{namespace="default", pod=~"sample-app.*"}
```

**Pod Restart Count:**
```promql
kube_pod_container_status_restarts_total{namespace="default"}
```

**Network Receive Bytes:**
```promql
rate(container_network_receive_bytes_total{namespace="default"}[5m])
```

## Prometheus Configuration

### Key Features Configured

- **Retention Period**: 7 days of metrics
- **Storage**: 5Gi persistent volume
- **Resource Limits**: CPU (500m), Memory (800Mi)
- **Scrape Interval**: 30 seconds
- **Service Discovery**: Auto-discovers Kubernetes services

### Custom Metrics

To expose custom metrics from your application:

1. **Instrument your code** with Prometheus client library
2. **Expose metrics endpoint** (e.g., `/metrics`)
3. **Add annotations** to your pod:
```yaml
   annotations:
     prometheus.io/scrape: "true"
     prometheus.io/port: "8080"
     prometheus.io/path: "/metrics"
```

## Alerting

### View Alerts

Access AlertManager: **http://localhost:9093** (after port-forward)

### Configure Alert Rules

Create `alert-rules.yaml`:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-alert-rules
  namespace: monitoring
data:
  alert-rules.yaml: |
    groups:
    - name: example
      rules:
      - alert: HighPodMemory
        expr: container_memory_usage_bytes > 100000000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
```

Apply:
```bash
kubectl apply -f alert-rules.yaml
```

## Monitoring Your Applications

### Add Monitoring to Your App

1. **Deploy your application** to Kubernetes
2. **Add Prometheus annotations**:
```yaml
   annotations:
     prometheus.io/scrape: "true"
     prometheus.io/port: "8080"
```
3. **Create Grafana dashboard** with relevant queries
4. **Set up alerts** for critical metrics

### Sample App Metrics

View sample app metrics:
1. Go to Grafana
2. Navigate to: **Kubernetes / Compute Resources / Namespace (Pods)**
3. Select namespace: **default**
4. See metrics for `sample-app` pods

## Troubleshooting

### Pods Not Starting
```bash
# Check pod status
kubectl get pods -n monitoring

# Describe problematic pod
kubectl describe pod <pod-name> -n monitoring

# Check logs
kubectl logs <pod-name> -n monitoring
```

### Grafana Login Issues
```bash
# Reset admin password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Or delete the secret to reset
kubectl delete secret prometheus-grafana -n monitoring
helm upgrade prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

### Prometheus Not Scraping Targets
```bash
# Check Prometheus targets
# Access Prometheus UI and go to Status → Targets

# Check service discovery
# Status → Service Discovery

# Verify pod annotations
kubectl describe pod <pod-name>
```

### Port Forward Fails
```bash
# Kill existing port-forward
pkill -f "port-forward.*grafana"

# Try different port
kubectl port-forward -n monitoring svc/prometheus-grafana 3001:80
```

### Storage Issues
```bash
# Check PVC status
kubectl get pvc -n monitoring

# Describe PVC
kubectl describe pvc <pvc-name> -n monitoring

# Check storage class
kubectl get storageclass
```

## Scaling and Performance

### Prometheus Resources

For larger clusters, increase resources in `values/prometheus-values.yaml`:
```yaml
prometheus:
  prometheusSpec:
    resources:
      requests:
        memory: 2Gi
        cpu: 1000m
      limits:
        memory: 4Gi
        cpu: 2000m
    retention: 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 50Gi
```

### High Availability

For production, enable HA mode:
```yaml
prometheus:
  prometheusSpec:
    replicas: 2

alertmanager:
  alertmanagerSpec:
    replicas: 3

grafana:
  replicas: 2
```

## Cleanup

### Uninstall (Automated)
```bash
./uninstall.sh
```

### Manual Uninstall
```bash
# Uninstall Helm release
helm uninstall prometheus -n monitoring

# Delete sample app
kubectl delete -f sample-app/

# Delete namespace (optional)
kubectl delete namespace monitoring
```

## Best Practices Implemented

- ✅ **Persistent Storage** - Metrics retained across pod restarts
- ✅ **Resource Limits** - Prevents resource exhaustion
- ✅ **Service Discovery** - Automatic target detection
- ✅ **Pre-configured Dashboards** - Immediate visibility
- ✅ **Secure Credentials** - Passwords stored in secrets
- ✅ **Namespace Isolation** - Dedicated monitoring namespace
- ✅ **Retention Policies** - Balance storage vs history

## Security Considerations

- Grafana admin password stored in Kubernetes secret
- Access controlled via Kubernetes RBAC
- Metrics endpoints exposed only within cluster
- Port-forward for external access (not exposed LoadBalancer)
- Regular updates for security patches
- TLS encryption can be added for production

## Performance Optimization

- Scrape interval tuned to 30 seconds
- Metric retention set to 7 days (adjustable)
- Resource limits prevent OOM kills
- Storage optimized for time-series data
- Query caching enabled in Grafana

## Future Enhancements

- [ ] Add custom alert rules for applications
- [ ] Integrate with Slack/PagerDuty for notifications
- [ ] Add Loki for log aggregation
- [ ] Add Tempo for distributed tracing
- [ ] Implement recording rules for query optimization
- [ ] Add Thanos for long-term storage
- [ ] Create application-specific dashboards
- [ ] Implement auto-scaling based on metrics
- [ ] Add business metrics dashboards
- [ ] Set up multi-cluster monitoring

## Key Learnings

This project demonstrates:

- **Prometheus Deployment** - Installing and configuring Prometheus on Kubernetes
- **Grafana Dashboards** - Creating and customizing visualization dashboards
- **Metrics Collection** - Understanding exporters and service discovery
- **PromQL** - Writing queries to extract meaningful insights
- **Helm Charts** - Using Helm for complex application deployment
- **Kubernetes Monitoring** - Best practices for cluster observability
- **Alerting** - Setting up and managing alerts

## Metrics Collected

**Cluster Metrics:**
- Node CPU, Memory, Disk, Network
- Pod resource usage and limits
- Container restarts and status
- API server performance

**Application Metrics:**
- HTTP request rate and duration
- Error rates
- Custom business metrics
- Database connections

**Kubernetes Metrics:**
- Deployment status
- ReplicaSet health
- Service endpoints
- Persistent volume usage

## Common Use Cases

**Capacity Planning:**
- Monitor resource trends
- Predict scaling needs
- Optimize resource requests/limits

**Troubleshooting:**
- Identify performance bottlenecks
- Track error rates
- Correlate metrics with incidents

**SLA Monitoring:**
- Track uptime
- Monitor latency
- Measure error rates

**Cost Optimization:**
- Identify over-provisioned resources
- Track resource waste
- Optimize cluster sizing

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)

## Project Status

✅ **Prometheus**: Fully operational collecting metrics  
✅ **Grafana**: Dashboards configured and accessible  
✅ **Sample App**: Deployed and monitored  
✅ **AlertManager**: Configured and running  
✅ **Exporters**: Node Exporter and kube-state-metrics active  

## Author

**DevOps Portfolio Project**

This project showcases hands-on experience with:
- Kubernetes monitoring and observability
- Prometheus metrics collection and querying
- Grafana dashboard creation and customization
- Helm chart deployment and configuration
- Alert management and troubleshooting
- Production-ready monitoring stacks

---

## License

This project is open source and available for educational purposes.

## Contributing

Improvements and suggestions welcome! Feel free to fork and submit pull requests.

---

**⭐ If you find this project helpful, please give it a star!**