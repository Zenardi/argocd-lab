# Installing Argo Rollouts
## 🎯 Lab Goal

Install the Argo Rollouts controller into your Kubernetes cluster and add the essential `kubectl-argo-rollouts` plugin to your local machine.

## 📝 Overview & Concepts

Before we can perform advanced deployments, we need to install the Argo Rollouts controller. This controller is the brains of the operation; it introduces the `Rollout` Custom Resource Definition (CRD) to our cluster and manages the entire progressive delivery lifecycle. We will use the official Helm chart for a clean and repeatable installation.

We will also install the `kubectl-argo-rollouts` plugin. This is a powerful command-line tool that extends `kubectl` with new commands for visualizing, managing, and interacting with `Rollout` resources, including a rich, real-time dashboard that we'll use extensively.

## 📋 Lab Tasks

### Part 1: Clean Up Previous Labs

If you are coming directly from the Argo CD module, let's clean up the cluster. You can start with a new, fresh cluster by running `minikube delete` and `minikube start`, or delete the resources you created during the course:

1.  Delete the `guestbook` application from Argo CD to ensure a clean slate.
    ```bash
    argocd app delete guestbook --cascade
    ```
2.  (Optional) If you created the `team-finance` project, you can leave it or delete it. It won't interfere.

### Part 2: Install Argo Rollouts

1.  Ensure the Argo Project Helm repository is added to your local Helm client.
2.  Create a dedicated `argo-rollouts` namespace.
3.  Install the `argo-rollouts` Helm chart into the new namespace.
    - Use the chart name `argo/argo-rollouts`.
    - Set the release name to `argo-rollouts`.
    - Set the Chart version to `2.40.5`.
4.  Verify that the Argo Rollouts controller pod is running correctly in the `argo-rollouts` namespace.

```shell
helm search repo argo-rollouts

helm upgrade argo-rollouts argo/argo-rollouts --version 2.40.5 --install --namespace argo-rollouts --create-namespace --set dashboard.enabled=true

kubectl port-forward service/argo-rollouts-dashboard 31000:3100 -n argo-rollouts

```

### Part 3: Install Kubectl Plugin

1.  Install the `kubectl-argo-rollouts` plugin on your local machine.
2.  Verify that the plugin is installed correctly by running the `version` command.

```shell
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64

chmod +x ./kubectl-argo-rollouts-darwin-amd64

sudo mv ./kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts

kubectl argo rollouts version
```

## 📚 Helpful Resources

- [Argo Rollouts - Installation Guide](https://argo-rollouts.readthedocs.io/en/stable/installation/)
- [Argo Rollouts - Kubectl Plugin Installation](https://argo-rollouts.readthedocs.io/en/stable/installation/#kubectl-plugin-installation)
- [Helm `install` Command Documentation](https://helm.sh/docs/helm/helm_install/)

# First Rollout
## 🎯 Lab Goal

Convert a standard Kubernetes Deployment into an Argo Rollout and execute a controlled rollout with a manual pause.

## 📝 Overview & Concepts

In this lab, we will move away from the "all-at-once" update strategy. We will define a `Rollout` resource that uses a progressive delivery strategy. Specifically, we will configure it to replace 20% of the pods with the new version and then **pause indefinitely**.

This "pause" is critical. In a real-world scenario, this is where you would check your metrics or manual test results. We will trigger an update, observe the rollout stop at the 20% mark, and then manually "promote" the rollout to let it finish. We will use the `kubectl argo rollouts` plugin to visualize this process in real-time.

## 📋 Lab Tasks

### Part 1: Deploy the First Version

1.  Create a file named `rollout.yaml` that defines a `Rollout` resource.
    - **Image:** `zenardi/simple-color-app:1.0.0`
    - **Env Var:** `APP_COLOR=orange`
    - **Replicas:** `5`
    - **Strategy:** `canary`
    - **Steps:** `setWeight: 20`, then `pause: {}` (indefinite pause).
2.  Create a file named `service.yaml` pointing to the rollout.
3.  Apply both manifests to deploy **Version 1**.

### Part 2: Execute Rollout

1.  Modify `rollout.yaml` to update the application:
    - Change `APP_COLOR` env var to `blue`.
2.  Apply the change.
3.  Use the `kubectl argo rollouts get rollout ... --watch` command to observe the deployment pausing at the 20% state (1 new pod, 4 old pods).
4.  Manually promote the rollout using the CLI to allow it to proceed to 100%.

## 📚 Helpful Resources

- [Argo Rollouts - Canary Strategy](https://argo-rollouts.readthedocs.io/en/stable/features/canary/)
- [Argo Rollouts - Kubectl Plugin Usage](https://argo-rollouts.readthedocs.io/en/stable/features/kubectl-plugin/)

# Core Rollouts Strategies
