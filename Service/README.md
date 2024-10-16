# Kubernetes Services

In Kubernetes, a **Service** is an abstraction that defines a logical set of Pods and a policy by which to access them. Services enable communication between different components of an application, whether they are internal to the cluster or external to clients outside of the cluster. They provide a stable network endpoint for accessing the Pods, even if the underlying Pods are dynamically created or destroyed.

## Key Concepts of Kubernetes Services

### 1. Service Types
- **ClusterIP (default)**: Exposes the service on a cluster-internal IP. The service is only accessible from within the cluster.
- **NodePort**: Exposes the service on each node's IP at a static port. It's accessible from outside the cluster using `<NodeIP>:<NodePort>`.
- **LoadBalancer**: Creates an external load balancer that routes traffic to the service. It works in environments that support external load balancers (e.g., cloud providers like AWS, GCP).
- **ExternalName**: Maps the service to the contents of the externalName field (e.g., a DNS name). It does not create any proxying.

### 2. Service Discovery
Kubernetes supports two primary modes of service discovery:
- **DNS**: The built-in Kubernetes DNS server automatically resolves the service name to the corresponding IP address.
- **Environment Variables**: Services can also be discovered using environment variables.

### 3. Selectors
Services use **selectors** to determine which Pods will handle the traffic. The selector defines the labels that identify the target Pods for the service.

### 4. Endpoints
**Endpoints** are dynamically updated lists of IP addresses that map to the Pods matching the service's selector. They are used to route traffic to the appropriate Pods.

## Example YAML for a Kubernetes Service

Below is an example of a **ClusterIP** service for a web application:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-web-service
spec:
  selector:
    app: my-web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

Below is an example of a **NodePort** service for a web application:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30007
  type: NodePort
```
Below is an example of a **LoadBalancer** service for a web application:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: loadbalancer-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```
Below is an example of a **ExternalName Service** service for a web application:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: externalname-service
spec:
  type: ExternalName
  externalName: lvm-service.lvm-app.svc.cluster.local
```
*  Note: externalName: <service>.<namespace>.svc.cluster.local


* selector: Specifies which Pods the service will route to.
* port: The port that the service exposes.
* targetPort: The port on the Pod that receives the traffic.

### Use Cases for Different Service Types

**ClusterIP** : For communication within the cluster (e.g., microservices talking to each other).
**NodePort** : For exposing services directly to external clients, useful for development and testing.
**LoadBalancer** : Best for production use in cloud environments where a managed load balancer is needed.
**ExternalName** : For linking external services that are outside the Kubernetes cluster.**