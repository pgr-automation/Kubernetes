# Kubernetes Pods:

## Overview

A **Pod** is the smallest deployable unit in Kubernetes. It can contain one or more containers that share the same network namespace and storage. Pods are designed to run a single instance of a service or application and can scale to multiple instances for high availability.

## Key Concepts

### 1. **Pod Structure**
- **Containers**: Each pod can encapsulate one or more containers, which share the pod's resources.
- **Network Namespace**: All containers within a pod share the same IP address and network namespace, enabling them to communicate easily.
- **Storage**: Pods can use volumes to store and share data between containers.

### 2. **Lifecycle of a Pod**
A pod can have several phases during its lifecycle:
- **Pending**: The pod has been accepted by the Kubernetes system, but one or more containers are not yet running.
- **Running**: The pod's containers are running.
- **Succeeded**: All containers in the pod have terminated successfully, and the pod will not be restarted.
- **Failed**: All containers in the pod have terminated, but at least one container has failed.
- **Unknown**: The state of the pod could not be obtained.

### 3. **Pod Definitions**
Pods are defined using YAML or JSON manifest files. A simple pod definition might look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-1
  labels:
    app: app-1
spec:
  containers:
    - name: app-1
      image: nginx:latest
      volumeMounts:
        - name: nginx-logs
          mountPath: /var/log/nginx/

  volumes:
    - name: nginx-logs
      persistentVolumeClaim:
        claimName: nfs-pvc-app1


```
### Use NFS storage

# * Create PV
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv-app1
spec:
  capacity:
    storage: 10Gi  # Adjust as needed
  accessModes:
    - ReadWriteMany  # NFS can support multiple readers/writers
  nfs:
    path:  /var/log/shares/nginx_logs # Path to your NFS share
    server: 192.168.1.130  # IP address of your NFS server
  persistentVolumeReclaimPolicy: Retain  # You can set this to Retain, Recycle, or Delete based on your needs
  mountOptions:
    - nolock
    - noacl
  claimRef:
    namespace: default
    name: nfs-pvc-app1
```
# * Create PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc-app1
spec:
  accessModes:
    - ReadWriteMany  # Ensure this matches the PV access mode
  resources:
    requests:
      storage: 10Gi  # Adjust to match the PV size
```