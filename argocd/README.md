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
