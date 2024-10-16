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


# Kubernetes Pods Issues and Troubleshooting Guide

## Table of Contents
- [Introduction](#introduction)
- [Common Pod Issues](#common-pod-issues)
  - [1. CrashLoopBackOff](#1-crashloopbackoff)
  - [2. ImagePullBackOff](#2-imagepullbackoff)
  - [3. Pending Pods](#3-pending-pods)
  - [4. Terminated Pods](#4-terminated-pods)
  - [5. Resource Quota Exceeded](#5-resource-quota-exceeded)
- [Troubleshooting Steps](#troubleshooting-steps)
  - [1. Inspect Pod Status](#1-inspect-pod-status)
  - [2. Check Logs](#2-check-logs)
  - [3. Describe Pod](#3-describe-pod)
  - [4. Check Events](#4-check-events)
  - [5. Review Resource Configurations](#5-review-resource-configurations)
- [Best Practices](#best-practices)
- [Conclusion](#conclusion)

## Introduction
This guide provides an overview of common issues encountered with Kubernetes pods and troubleshooting steps to diagnose and resolve these issues. It is intended for DevOps engineers and Kubernetes administrators.

## Common Pod Issues

### 1. CrashLoopBackOff
- **Description**: A pod is crashing and restarting repeatedly.
- **Causes**: Application errors, misconfigurations, or insufficient resources.

### 2. ImagePullBackOff
- **Description**: Kubernetes is unable to pull the container image.
- **Causes**: Incorrect image name, missing image in the repository, or authentication issues.

### 3. Pending Pods
- **Description**: Pods are in the 'Pending' state and not starting.
- **Causes**: Insufficient resources, unsatisfied node selectors, or taints and tolerations issues.

### 4. Terminated Pods
- **Description**: Pods have terminated but are still listed.
- **Causes**: Successful completion, failure, or preemption.

### 5. Resource Quota Exceeded
- **Description**: Pods cannot be scheduled due to exceeded resource quotas.
- **Causes**: High resource usage in the namespace.

## Troubleshooting Steps

Use the following commands to check the issues of the pod:

```bash
1. Check Pod Status
kubectl get pods

2. Describe the Pod
kubectl describe pod <pod-name>

3. Check Pod Logs
kubectl logs <pod-name>

4. If the pod has multiple containers, specify the container:
kubectl logs <pod-name> -c <container-name>

4. Check Resource Usage
kubectl top pod <pod-name>

5. Check Events
kubectl get events --sort-by=.metadata.creationTimestamp

6. Review Resource Configurations
kubectl get pod <pod-name> -n <namespace> -o yaml

7. Validate Image Availability
If facing ImagePullBackOff issues, verify that the image name is correct and that the image is available in the specified container registry. Check authentication settings if using private registries.

8.  Check Network Policies and Security Groups
If the pod cannot connect to other services or databases, ensure that network policies, security groups, or firewall rules are correctly configured to allow traffic.

9. Examine Node Conditions

    If a pod is stuck in Pending, it may be due to insufficient resources on the node. Check the node status:
kubectl get nodes
kubectl describe node <node-name>

10. Restart the Pod
kubectl delete pod <pod-name> -n <namespace>

```

## Imperative Commands with Kubectl: -

* Create an NGINX Pod
```bash
kubectl run nginx --image=nginx
```
* Generate POD Manifest YAML file (-o yaml). Don’t create it(–dry-run)
```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml
```