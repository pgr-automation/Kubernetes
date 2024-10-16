# Kubernetes Deployments

## What are Deployments?
Deployments in Kubernetes are a higher-level abstraction that manages ReplicaSets to ensure that a specified number of identical Pods are running. They provide a way to declaratively update applications, allowing users to perform rollouts and rollbacks seamlessly.

## Features of Deployments
- **Declarative Updates**: You can define the desired state of your application, and Kubernetes will work to maintain that state.
- **Rolling Updates**: Deployments support rolling updates, allowing you to update applications without downtime by incrementally replacing Pods.
- **Rollbacks**: If a new version of an application is causing issues, you can easily revert to a previous version.
- **Scaling**: You can easily scale your application up or down by adjusting the number of replicas.
- **Self-Healing**: Deployments automatically replace Pods that fail or become unresponsive, maintaining the desired number of replicas.
- **Label Selectors**: Use labels to select which Pods belong to the Deployment, enabling better organization and management.

## Common Issues with Deployments
1. **Pods Not Starting**: Pods may fail to start due to issues with the image, configuration, or resource limits.
2. **Failed Rollout**: Updates may not apply correctly, leading to a failed rollout.
3. **Replica Count Mismatch**: The number of running Pods may not match the desired count specified in the Deployment.
4. **CrashLoopBackOff**: Pods may repeatedly crash due to application errors or misconfigurations.
5. **Outdated Pods**: Some Pods may not update to the latest version due to rollout strategy issues.

## Troubleshooting Steps
1. **Check Deployment Status**:
```bash
   kubectl rollout status deployment <deployment-name>
```
2. **Describe the Deployment***:
```bash
kubectl describe deployment <deployment-name>
```
3. **Inspect Pods**:
```bash
kubectl get pods -l app=<deployment-label>
kubectl describe pod <pod-name>
```
4. **Check Events: Look for events related to the Deployment or Pods**:
```bash
kubectl get events --sort-by='.metadata.creationTimestamp'
```
5. **Check Logs: Inspect the logs of the Pods for errors or issues**:
```bash
kubectl logs <pod-name>
```
6. **Verify Container Image: Ensure that the specified container image is available and correctly tagged**:
```bash
kubectl get deployment <deployment-name> -o=jsonpath='{.spec.template.spec.containers[*].image}'
```
7. **Rollback to Previous Version: If the rollout has failed, you can rollback**:
```bash
kubectl rollout undo deployment <deployment-name>
```
8. **Adjust Resource Limits: If Pods are being evicted or crashing, consider adjusting resource requests and limits in the Deployment configuration.**

9. **Check Node Status: Ensure that the nodes where Pods are scheduled are in a healthy state**:
```bash
kubectl get nodes
```
10. **Use kubectl describe on ReplicaSet: If Pods managed by a Deployment are failing, it may be helpful to look at the ReplicaSet**:
```bash
kubectl describe rs <replicaset-name>
```

## Imperative Commands with Kubectl:-

* Create a deployment

```bash
kubectl create deployment --image=nginx nginx
```
* Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run)

```bash
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
```

* Generate Deployment with 4 Replicas

```bash
kubectl create deployment nginx --image=nginx --replicas=4
``` 

* You can also scale a deployment using the kubectl scale command.

```bash
kubectl scale deployment nginx --replicas=4 
```

* Another way to do this is to save the YAML definition to a file and modify

```bash
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml
```