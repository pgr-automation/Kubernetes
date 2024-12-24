# Kubernetes
Kubernetes is a powerful container orchestration platform made up of several key components that work together to manage containerized applications. Below are the primary components of Kubernetes:

# Kubernetes Components

## 1. Master Node
- **API Server**: The central management entity that exposes the Kubernetes API. It handles all REST commands used to control the cluster.
- **Controller Manager**: Manages controllers that handle routine tasks in the cluster, such as replication, endpoint management, and namespace management.
- **Scheduler**: Assigns work to the worker nodes by scheduling pods based on resource availability, constraints, and policies.
- **etcd**: A distributed key-value store used for storing all cluster data, including configuration data and state information.

## 2. Worker Nodes
- **Kubelet**: An agent that runs on each worker node, ensuring that containers are running in pods as specified by the Kubernetes API.
- **Kube Proxy**: Manages network communication to and from pods, handling load balancing and routing of traffic.
- **Container Runtime**: The software responsible for running containers. Common options include Docker, containerd, and CRI-O.

## 3. Pods
The smallest deployable units in Kubernetes, which can contain one or more containers. Pods share the same network namespace and storage.

## 4. Services
Abstractions that define a logical set of pods and a policy to access them, enabling load balancing and service discovery.

## 5. Namespaces
Virtual clusters within a Kubernetes cluster, allowing for isolation and organization of resources.

## 6. Volumes
Storage resources that can be used by pods. They persist beyond the lifecycle of individual containers, making data available to applications running in the pods.

## 7. Deployments
Manage the deployment and scaling of pods, providing declarative updates for applications.

## 8. ReplicaSets
Ensures that a specified number of pod replicas are running at all times. If a pod fails, the ReplicaSet will start a new one to maintain the desired state.

## 9. StatefulSets
Manages stateful applications, ensuring that pods maintain their identity and storage even when they are rescheduled.

## 10. DaemonSets
Ensures that a copy of a specific pod runs on all or a subset of nodes in the cluster.

## 11. ConfigMaps and Secrets
- **ConfigMaps**: Store configuration data in key-value pairs, allowing you to separate configuration from application code.
- **Secrets**: Similar to ConfigMaps but designed to hold sensitive information, such as passwords and tokens.

## 12. Ingress
Manages external access to services, typically HTTP. It provides load balancing, SSL termination, and name-based virtual hosting.

## 13. Network Policies
Define rules for controlling the communication between pods and/or services.

These components work together to provide a robust and scalable platform for deploying and managing containerized applications in production environments.


| Resource Type  | Description                                                                 | Use Case                                                   | Scaling       | Pod Identity                          | Network Identity             |
|----------------|-----------------------------------------------------------------------------|------------------------------------------------------------|---------------|---------------------------------------|------------------------------|
| **Pod**        | The smallest deployable unit in Kubernetes, representing a single instance of a running process. | Running a single instance of an application or service.    | Manual scaling | No persistent identity, new IP on restart | Unique IP per Pod.            |
| **Deployment** | Manages a ReplicaSet, allowing you to declaratively update Pods.           | Rollouts and rollbacks of applications.                     | Scales Pods up and down automatically. | Maintains the same Pod identity over updates. | Stable endpoint via Service. |
| **ReplicaSet** | Ensures that a specified number of Pod replicas are running at all times.  | Maintaining a stable set of replica Pods.                   | Automatically scales Pods based on defined replicas. | No persistent identity, manages Pods by label selector. | Unique IP per Pod.            |
| **DaemonSet**  | Ensures that all (or some) Nodes run a copy of a Pod.                      | Running a service on all nodes, like monitoring or logging. | Automatically scales based on Nodes. | Unique Pod per Node, maintains identity. | Unique IP per Pod.            |
| **StatefulSet**| Manages the deployment and scaling of a set of Pods, providing guarantees about the ordering and uniqueness of these Pods. | Stateful applications, like databases, requiring stable identity and storage. | Manual scaling; Pods are created in order. | Stable identity across restarts, unique ordinal index. | Stable network identity; DNS for each Pod. |



## Usefull commands 

**update release image**
```bash
sed -i "s|image: .*|image: nginx:1.14.3|" deployment.yaml
```