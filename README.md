# GitOps, Blue-Green & Canary deployments using Argo CD, Argo Rollouts, Helm, Prometheus, and the Gateway API

# Setup Environment

## Local
You can use a local Kubernetes cluster like Kind (Kubernetes in Docker). Follow these steps on official [website](https://kind.sigs.k8s.io/) to get started.
If you choose to use KIND, simply use 'kind/kind.yaml' file to deploy a Kubernetes cluster on local environment.

```shell
# To create kind cluster using kind.yaml
kind create cluster --config kind.yaml

# To delete the cluster
kind delete cluster --name argocd-cluster
```

## Crossplane
If you choose you can provision Kubernetes cluster using Crossplane. You can choose to provision on GCP, AWS, or Azure.
--WIP--

# Setup Argo CD
For detailed documentation regarding setup ArgoCD, please see the [ArgoCD README](argocd/README.md).

## Image Used

### Fleetmanager

**image Repos**
- k8s-fleetman-queue
- k8s-fleetman-webapp-angular
- k8s-fleetman-position-tracker
- k8s-fleetman-position-simulator
- k8s-fleetman-api-gateway
- istio-fleetman-staff-service
- istio-fleetman-position-simulator
- istio-fleetman-vehicle-telemetry
- istio-fleetman-position-tracker
- istio-fleetman-api-gateway
- istio-fleetman-webapp-angular
- istio-fleetman-photo-service
- k8s-fleetman-helm-demo


### Callorie Calculator
- calories-grpc-service

### Chip
- chip