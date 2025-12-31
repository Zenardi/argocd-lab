# ArgoCD and Argo Rollouts Lab

This repository contains a comprehensive lab environment for exploring GitOps practices, continuous deployment, and progressive delivery strategies using ArgoCD and Argo Rollouts. The lab covers various deployment approaches including Blue-Green, Canary, traffic weighting, and header-based routing, integrated with Helm, Prometheus monitoring, Traefik ingress, and the Kubernetes Gateway API.

## Table of Contents

- [ArgoCD and Argo Rollouts Lab](#argocd-and-argo-rollouts-lab)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Local Setup with Kind](#local-setup-with-kind)
  - [Quick Start](#quick-start)
  - [ArgoCD Labs](#argocd-labs)
    - [Core Concepts](#core-concepts)
    - [Application Deployment](#application-deployment)
    - [Advanced Features](#advanced-features)
  - [Argo Rollouts Labs](#argo-rollouts-labs)
    - [Installation \& Setup](#installation--setup)
    - [Deployment Strategies](#deployment-strategies)
    - [Traffic Management](#traffic-management)
  - [Additional Components](#additional-components)
    - [Prometheus Monitoring](#prometheus-monitoring)
    - [Traefik Ingress](#traefik-ingress)
    - [Crossplane (WIP)](#crossplane-wip)
  - [Project Structure](#project-structure)

## Overview

This lab is designed to provide hands-on experience with:

- **GitOps workflows** using ArgoCD for declarative application management
- **Progressive delivery** techniques with Argo Rollouts (Blue-Green, Canary deployments)
- **Traffic management** using Kubernetes Gateway API and Traefik
- **Monitoring and observability** with Prometheus
- **Infrastructure as Code** with Helm charts and Kubernetes manifests

The lab includes multiple scenarios and configurations to demonstrate real-world deployment patterns and best practices.

## Prerequisites

- Kubernetes cluster (local or cloud-based)
- `kubectl` configured to access your cluster
- `helm` package manager
- `kind` (for local clusters)
- Basic understanding of Kubernetes concepts

### Local Setup with Kind

```bash
# Create a Kind cluster
kind create cluster --config kind/kind.yaml

# Verify cluster
kubectl cluster-info --context kind-argocd-cluster
```

## Quick Start

1. **Set up your Kubernetes cluster** (see Prerequisites)

2. **Install ArgoCD**:
   ```bash
   cd argocd
   # Follow the installation steps in argocd/README.md
   ```

3. **Install Argo Rollouts**:
   ```bash
   cd argo-rollouts
   # Follow the installation steps in argo-rollouts/README.md
   ```

4. **Explore the labs** by following the detailed guides in each subdirectory

## ArgoCD Labs

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. This section covers:

### Core Concepts
- Installing ArgoCD with Helm
- Accessing the web UI and CLI
- Understanding ArgoCD components

### Application Deployment
- Deploying first application from Git
- Helm chart deployments
- Public and private repository connections (HTTPS/SSH)
- Customizing deployments with values overrides

### Advanced Features
- Automated sync and pruning
- Self-healing capabilities
- ArgoCD Projects for security guardrails
- Sync phases, hooks, and waves

For detailed instructions, see [argocd/README.md](argocd/README.md).

## Argo Rollouts Labs

Argo Rollouts is a Kubernetes controller and set of CRDs which provide advanced deployment capabilities such as Blue-Green, Canary, and progressive delivery features.

### Installation & Setup
- Installing Argo Rollouts controller
- Kubectl plugin installation
- Dashboard setup

### Deployment Strategies
- **First Rollout**: Converting Deployments to Rollouts with manual pauses
- **Blue-Green Deployments**: Full parallel deployments with preview services
- **Canary Deployments**: Gradual traffic shifting with dedicated endpoints
- **Traffic Weighting**: Precise traffic control using Gateway API
- **Header-Based Routing**: Conditional routing based on HTTP headers

### Traffic Management
- Setting up Traefik with Kubernetes Gateway API
- Configuring traffic routers for progressive delivery
- Testing and verification of deployment strategies

For detailed instructions, see [argo-rollouts/README.md](argo-rollouts/README.md).

## Additional Components

### Prometheus Monitoring
- Pre-configured Prometheus setup for monitoring deployments
- Integration with Argo Rollouts metrics
- Port-forwarding for dashboard access

### Traefik Ingress
- Gateway API provider configuration
- HTTP routing for applications
- Dashboard access

### Crossplane (WIP)
- Infrastructure provisioning on cloud providers (AWS, GCP, Azure)
- Declarative cluster management

## Project Structure

```
argocd-lab/
├── argocd/                    # ArgoCD labs and manifests
│   ├── README.md             # Detailed ArgoCD guide
│   ├── argons.yaml           # Namespace creation
│   ├── guestbook-app*.yaml   # Application manifests
│   ├── projects/             # ArgoCD project examples
│   └── manifests/            # Kubernetes manifests
├── argo-rollouts/            # Argo Rollouts labs
│   ├── README.md            # Detailed Rollouts guide
│   ├── blue-green/          # Blue-Green deployment example
│   ├── canary/              # Canary deployment example
│   ├── traffic-weighting/   # Traffic weighting example
│   └── setup/               # Installation manifests
├── prometheus/               # Monitoring setup
├── traefik/                  # Ingress configuration
├── crossplane/               # Infrastructure provisioning
├── kind/                     # Local cluster configuration
├── imgs/                     # Documentation images
└── README.md                 # This file
```