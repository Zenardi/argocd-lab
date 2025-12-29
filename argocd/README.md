- [Install Argo on K8S Cluster with Helm](#install-argo-on-k8s-cluster-with-helm)
  - [📝 Overview \& Concepts](#-overview--concepts)
  - [📋 Tasks](#-tasks)
- [Access Web UI](#access-web-ui)
  - [📝 Overview \& Concepts](#-overview--concepts-1)
  - [📋 Tasks](#-tasks-1)
- [ArgoCD Components](#argocd-components)
- [Deploying First App](#deploying-first-app)
  - [📝 Overview \& Concepts](#-overview--concepts-2)
  - [📋 Tasks](#-tasks-2)
- [Deploying with Helm Charts](#deploying-with-helm-charts)
  - [🎯 Lab Goal](#-lab-goal)
  - [📝 Overview \& Concepts](#-overview--concepts-3)
  - [📋 Lab Tasks](#-lab-tasks)
- [Deploy Public Available Helm Chart](#deploy-public-available-helm-chart)
  - [🎯 Lab Goal](#-lab-goal-1)
  - [📝 Overview \& Concepts](#-overview--concepts-4)
  - [📋 Lab Tasks](#-lab-tasks-1)
  - [🔍 Key Differences from Git-based Charts](#-key-differences-from-git-based-charts)
    - [Accessing the Dashboard](#accessing-the-dashboard)
- [📚 Helpful Resources](#-helpful-resources)


# Install Argo on K8S Cluster with Helm

Install the Argo CD controller and its components into the cluster using the official Helm chart, ensuring a specific, repeatable version is deployed.

## 📝 Overview & Concepts

We will use Helm, the standard Kubernetes package manager, to install Argo CD. This is the official and recommended method as it correctly handles all of Argo CD's various Kubernetes components. The process involves adding the official Argo Project Helm repository, creating a dedicated `argocd` namespace for organizational hygiene, and then using a `helm install` command with a pinned version to deploy the chart.

## 📋 Tasks

1.  Add the official Argo Project Helm repository to your local Helm client.
2.  Update your Helm repositories to ensure you have the latest chart information.
3.  Create a dedicated `argocd` namespace in your cluster.
4.  Install the `argo-cd` Helm chart version `8.6.0` into the `argocd` namespace.
5.  Verify that all the Argo CD pods have been created and are in a `Running` state.

```shell
kubectl apply -f argocd/argons.yaml # to create argocd namespace 
# OR 
kubectl create ns  argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm search repo argo/argo-cd  --versions

helm upgrade argocd argo/argo-cd --version 8.6.0 --install --create-namespace -n argocd
```


---

# Access Web UI

Access the Argo CD web UI and install the command-line interface (CLI) to gain full control over your Argo CD installation.

## 📝 Overview & Concepts

Argo CD is now running in our cluster, but by default, it's not exposed to the outside world. To interact with it, we need to connect securely. In this lab, we'll first retrieve the auto-generated initial admin password from a Kubernetes secret. Then, we'll use `kubectl port-forward` to create a secure tunnel from our local machine to the Argo CD server pod. This will allow us to log in via a web browser. Finally, we'll install the powerful `argocd` CLI for command-line operations and log in with it as well.

## 📋 Tasks

1.  Retrieve the initial admin password for the `admin` user from the `argocd-initial-admin-secret` Kubernetes secret and decode it.
2.  Use `kubectl port-forward` to make the Argo CD server UI accessible on `localhost:8080`.
3.  Log in to the Argo CD web UI in your browser using the `admin` username and the retrieved password.
4.  Install the `argocd` CLI tool on your local machine.
5.  Log in to the Argo CD API server using the `argocd` CLI.

```shell
kubectl get svc -n argocd
# NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
# argocd-applicationset-controller   ClusterIP   10.96.8.127     <none>        7000/TCP            5m14s
# argocd-dex-server                  ClusterIP   10.96.241.140   <none>        5556/TCP,5557/TCP   5m14s
# argocd-redis                       ClusterIP   10.96.243.30    <none>        6379/TCP            5m14s
# argocd-repo-server                 ClusterIP   10.96.83.32     <none>        8081/TCP            5m14s
# argocd-server                      ClusterIP   10.96.63.202    <none>        80/TCP,443/TCP      5m14s

kubectl port-forward svc/argocd-server -n argocd 8080:80

# To get the admin password
kubectl get secret -n argocd
# NAME                           TYPE                 DATA   AGE
# argocd-initial-admin-secret    Opaque               1      8m36s
# argocd-notifications-secret    Opaque               0      8m37s
# argocd-redis                   Opaque               1      8m41s
# argocd-secret                  Opaque               5      8m37s
# sh.helm.release.v1.argocd.v1   helm.sh/release.v1   1      8m43s

kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd | base64 --decode

# Install argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

---
# ArgoCD Components
![components](../imgs/argocd-components.png)


---

# Deploying First App

Define and deploy your first GitOps-managed application using the core Argo CD resource: the `Application` CRD.

## 📝 Overview & Concepts

The heart of Argo CD is a Custom Resource Definition (CRD) called `Application`. This resource is a declarative manifest that acts as a contract, telling Argo CD three main things: **where** the desired state is defined (a Git repository), **what** to deploy (a specific path and version in that repo), and **where** to deploy it (a destination cluster and namespace).

In this lab, you will write an `Application` manifest from scratch. You will commit this file to your Git repository. Then, you will perform a one-time `kubectl apply` of this manifest to "bootstrap" the application and register it with Argo CD. From that moment on, Argo CD will take over, pulling the manifests from the source repository and deploying them to the destination namespace.

## 📋 Tasks

1.  Create a new YAML file for your `Application` resource.
2.  Define the `metadata` for the `Application`, giving it the name `guestbook` and ensuring it lives in the `argocd` namespace.
3.  Define the `spec.project` as `default` and the `spec.source` to point to a public Git repository containing plain Kubernetes manifests. You can use the following for a demo application:
    - **Repo URL:** `https://github.com/lm-academy/argocd-example-apps.git`
    - **Revision:** `HEAD`
    - **Path:** `guestbook`
4.  Define the `spec.destination` field to deploy the application to the local cluster (`https://kubernetes.default.svc`) into the `default` namespace.
5.  Apply the `Application` manifest to your cluster using `kubectl apply`.
6.  Verify in the Argo CD UI that the `guestbook` application appears and successfully syncs.
7.  Use `kubectl` to verify that the `guestbook` application's resources (Deployments, Services) are running in the `default` namespace.

```shell
kubectl apply -f guestbook-app.yaml
```

![firstapp](../imgs/argocd-first-app.png)

# Deploying with Helm Charts

## 🎯 Lab Goal

Refactor an existing Argo CD `Application` to deploy the same application, but this time from a Helm chart located within our Git repository.

## 📝 Overview & Concepts

Deploying applications from plain YAML is great, but many real-world applications are packaged as Helm charts to manage complexity and templating. In this lab, you'll learn how to adapt an Argo CD `Application` manifest to deploy from a Helm chart instead of a directory of raw manifests.

We will be using a pre-made Helm chart for our `guestbook` application, which is already located in our examples repository. You will modify your existing `guestbook-app.yaml` manifest, changing the `spec.source` to point to this Helm chart, and observe as Argo CD seamlessly transitions the live application to be managed by the chart.

## 📋 Lab Tasks

1.  Explore the `helm-guestbook` directory in your `argocd-example-apps` repository to familiarize yourself with the simple Helm chart structure.
2.  Open your `guestbook-app.yaml` manifest for editing.
3.  Modify the `spec.source` section of the manifest:
    - Change the `repoURL` to point to your own fork of `lm-academy/argocd-example-apps` repository.
    - Set the `path` to `helm-guestbook`.
    - Add a new `helm` block.
    - Inside the `helm` block, add a `valueFiles` entry pointing to the chart's default `values.yaml` file.
4.  Apply the updated manifest to the cluster.
5.  Open the Argo CD UI and wait for the application to be considered `OutOfSync`.
6.  Trigger a `Sync` operation and observe in the Argo CD UI as the application syncs. Notice that although the source has fundamentally changed, the deployed resources remain the same, demonstrating Argo CD's powerful diffing capabilities.
7.  Verify with `kubectl` that the `guestbook` pods are still running correctly.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-helm
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Zenardi/argocd-example-apps.git
    targetRevision: HEAD
    path: helm-guestbook
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
```

![firstapp-helm](../imgs/argocd-first-app-helm.png)

# Deploy Public Available Helm Chart

## 🎯 Lab Goal

Deploy an application to your cluster using Argo CD from a publicly available Helm chart repository, specifically the Kubernetes Dashboard.

## 📝 Overview & Concepts

While Git repositories containing Helm charts are common, many applications are distributed through public Helm chart repositories. Argo CD can seamlessly deploy applications from these public repositories, such as Bitnami charts, official Kubernetes charts, and many others.

In this lab, you'll learn how to configure an Argo CD `Application` to deploy from a public Helm repository. Instead of pointing to a Git repository with a `path` to a chart directory, you'll use the `chart` field to reference a chart by name and specify the chart repository URL.

We will deploy the Kubernetes Dashboard, a web-based UI for Kubernetes cluster management, which is hosted in the official Kubernetes Helm chart repository.

## 📋 Lab Tasks

1.  Create a new namespace named `k8s-dashboard`.
2.  Create a new Argo CD `Application` manifest file named `k8s-dashboard-app.yaml`.
3.  Configure the `spec.source` section to deploy from a public Helm repository:
    - Set the `repoURL` to `https://kubernetes.github.io/dashboard/` (the Kubernetes Dashboard Helm repository).
    - Instead of using `path`, use the `chart` field and set it to `kubernetes-dashboard`.
    - Set `targetRevision` to `7.13.0` to pin to a specific chart version.
4.  Configure the `spec.destination` section:
    - Set `server` to `https://kubernetes.default.svc` (the in-cluster API server).
    - Set `namespace` to `k8s-dashboard` (or your preferred namespace).
5.  Apply the manifest to create the Argo CD Application.
6.  Open the Argo CD UI and observe the application being synced.
7.  Once synced, verify the Kubernetes Dashboard pods are running using `kubectl`.
8.  (Optional) Access the Kubernetes Dashboard by port-forwarding to the service and exploring the UI.

```shell
kubectl create ns k8s-dashboard

```

## 🔍 Key Differences from Git-based Charts

When deploying from a public Helm repository instead of a Git repository:

- **`repoURL`**: Points to the Helm chart repository URL (not a Git repository)
- **`chart`**: Specifies the chart name (replaces the `path` field used for Git repos)
- **`targetRevision`**: Refers to the chart version (not a Git commit/branch/tag)


### Accessing the Dashboard

Port-forward to access the dashboard locally:

```bash
kubectl port-forward svc/k8s-dashboard-kong-proxy 8443:443 -n k8s-dashboard
```

Then access the dashboard at: `https://localhost:8443`

**Note:** You'll need to create a service account and token to log in:

```bash
# Create a service account
kubectl create serviceaccount k8s-dashboard-admin -n k8s-dashboard

# Create a cluster role binding
kubectl create clusterrolebinding k8s-dashboard-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=k8s-dashboard:k8s-dashboard-admin

# Get the token
kubectl create token k8s-dashboard-admin -n k8s-dashboard
```

Use the generated token to log in to the dashboard.



---
---

# 📚 Helpful Resources
- [Argo CD - Getting Started Guide](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Helm `install` Command Documentation](https://helm.sh/docs/helm/helm_install/)
- [Helm `repo` Command Documentation](https://helm.sh/docs/helm/helm_repo/)
- [Kubectl `create namespace` Command Documentation](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create-namespace)
- [Argo CD Docs - Log In To The UI / CLI](https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)
- [Argo CD CLI Installation Guide](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [Kubectl `port-forward` Command Documentation](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward)
- [Argo CD Application CRD Specification](https://argo-cd.readthedocs.io/en/stable/operator-manual/api-docs/#argoproj.io/v1alpha1.Application)
- [Declarative Setup in Argo CD](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
- [The `argocd-example-apps` Repository](https://github.com/argoproj/argocd-example-apps)
- [My Fork of the `argocd-example-apps` Repository](https://github.com/lm-academy/argocd-example-apps)
- [Argo CD - Helm Chart Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)
- [Helm `valueFiles` Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values-files)
- [Argo CD - Helm Chart Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)
- [Kubernetes Dashboard Helm Chart](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard)
- [Argo CD Application Specification](https://argo-cd.readthedocs.io/en/stable/operator-manual/application.yaml)
