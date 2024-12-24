#!/bin/bash

# Set namespace and user name
USERNAME="aem-user"
ROLE_NAME="aem-full-access-role"
ROLEBINDING_NAME="aem-full-access-binding"
KUBECONFIG_FILE="aem-kubeconfig.yaml"

# Step 1: Create Namespace
echo "Creating namespace ${NAMESPACE}..."
kubectl create namespace $NAMESPACE

# Step 2: Create Role with Full Privileges (instead of ClusterRole for user-based RBAC)
echo "Creating Role with full privileges in the namespace ${NAMESPACE}..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $ROLE_NAME
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "deployments", "replicationcontrollers", "replicasets", "persistentvolumes", "persistentvolumeclaims", "secrets", "configmaps", "pods/log"]
    verbs: ["get", "list"]
  - apiGroups: ["apps"]
    resources: ["daemonsets", "deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list"]
  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: ["get", "list"]
  - apiGroups: ["batch"]
    resources: ["cronjobs", "jobs"]
    verbs: ["get", "list"]
EOF

# Step 3: Create RoleBinding to bind Role to User
echo "Creating RoleBinding to bind Role $ROLE_NAME to User $USERNAME..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $ROLEBINDING_NAME
  namespace: $NAMESPACE
subjects:
  - kind: User
    name: $USERNAME  # The user you want to bind
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: $ROLE_NAME
  apiGroup: rbac.authorization.k8s.io
EOF

# Step 4: Retrieve the Kubernetes API server URL and Certificate
APISERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_CERTIFICATE=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# Step 5: Generate kubeconfig file
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
    user: $USERNAME
  name: aem-context
current-context: aem-context
users:
- name: $USERNAME
  user:
    # User certificate or token should go here. For simplicity, we'll assume user has already been authenticated.
    # If using certificates, specify the paths to the certificate and key:
    # client-certificate: /path/to/cert
    # client-key: /path/to/key
    # Or if using a token, specify the token:
    # token: YOUR_USER_TOKEN
EOF

echo "kubeconfig file generated at $KUBECONFIG_FILE"

# Step 6: Verify kubeconfig access
export KUBECONFIG=$KUBECONFIG_FILE
echo "Verifying access with the generated kubeconfig..."
kubectl create deployment nginx --image=nginx -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get pods -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get services -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get deployments -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get secrets -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get configmaps -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get persistentvolumes -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get persistentvolumeclaims -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get daemonsets -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get replicationcontrollers -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get replicasets -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get statefulsets -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get horizontalpodautoscalers -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get cronjobs -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl get jobs -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
kubectl delete deployment nginx -n $NAMESPACE --kubeconfig=$KUBECONFIG_FILE
