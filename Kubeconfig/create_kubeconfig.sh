#!/bin/bash

# Set namespace and service account name
NAMESPACE="aem"
SERVICE_ACCOUNT="aem-user"
ROLE_NAME="aem-full-access-role"
ROLEBINDING_NAME="aem-full-access-binding"
KUBECONFIG_FILE="aem-kubeconfig.yaml"

# Step 1: Create Service Account
echo "Creating Service Account in the namespace ${NAMESPACE}..."
kubectl create namespace $NAMESPACE
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SERVICE_ACCOUNT
  namespace: $NAMESPACE
---
apiVersion: v1
kind: Secret
metadata:
  namespace: $NAMESPACE
  name: $SERVICE_ACCOUNT-token
  annotations:
    kubernetes.io/service-account.name: $SERVICE_ACCOUNT
type: kubernetes.io/service-account-token
EOF

# Step 2: Create ClusterRole with Full Privileges
echo "Creating ClusterRole with full privileges across the cluster..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $ROLE_NAME
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "deployments", "replicationcontrollers", "replicasets", "persistentvolumes", "persistentvolumeclaims", "secrets", "configmaps", "pods/log"]
    verbs: ["get", "list", "create", "update", "delete"]
  - apiGroups: ["apps"]
    resources: ["daemonsets", "deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list", "create", "update", "delete"]
  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: ["get", "list", "create", "update", "delete"]
  - apiGroups: ["batch"]
    resources: ["cronjobs", "jobs"]
    verbs: ["get", "list", "create", "update", "delete"]
EOF

# Step 3: Create ClusterRoleBinding to bind ClusterRole to Service Account
echo "Creating ClusterRoleBinding to bind ClusterRole $ROLE_NAME to Service Account $SERVICE_ACCOUNT..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $ROLEBINDING_NAME
subjects:
  - kind: ServiceAccount
    name: $SERVICE_ACCOUNT
    namespace: $NAMESPACE
roleRef:
  kind: ClusterRole
  name: $ROLE_NAME
  apiGroup: rbac.authorization.k8s.io
EOF

# Step 4: Retrieve the Service Account Token
echo "Retrieving the token for service account $SERVICE_ACCOUNT..."
SECRET_NAME=$(kubectl -n $NAMESPACE get secret | grep $SERVICE_ACCOUNT-token | awk '{print $1}')
TOKEN=$(kubectl -n $NAMESPACE describe secret $SECRET_NAME | grep "token:" | awk '{print $2}')

# Step 5: Get the Kubernetes API server URL and Certificate
APISERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_CERTIFICATE=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# Step 6: Generate kubeconfig file
echo "Generating kubeconfig file..."
cat <<EOF > $KUBECONFIG_FILE
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: $APISERVER_URL
    certificate-authority-data: $CA_CERTIFICATE
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: $NAMESPACE
    user: $SERVICE_ACCOUNT
  name: aem-context
current-context: aem-context
users:
- name: $SERVICE_ACCOUNT
  user:
    token: $TOKEN
EOF

echo "kubeconfig file generated at $KUBECONFIG_FILE"

# Step 7: Verify kubeconfig access
export KUBECONFIG=$KUBECONFIG_FILE
echo "Verifying access with the generated kubeconfig..."
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get deployments -n $NAMESPACE
kubectl get secrets -n $NAMESPACE
kubectl get configmaps -n $NAMESPACE
kubectl get persistentvolumes
kubectl get persistentvolumeclaims -n $NAMESPACE
kubectl get daemonsets -n $NAMESPACE
kubectl get replicationcontrollers -n $NAMESPACE
kubectl get replicasets -n $NAMESPACE
kubectl get statefulsets -n $NAMESPACE
kubectl get horizontalpodautoscalers -n $NAMESPACE
kubectl get cronjobs -n $NAMESPACE
kubectl get jobs -n $NAMESPACE
