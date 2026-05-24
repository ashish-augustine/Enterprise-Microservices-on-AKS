# Enterprise Microservices on AKS via GitOps

## Overview
This repository demonstrates a production-grade deployment of a polyglot microservices application (Microsoft's AKS Store Demo) utilizing a strict GitOps workflow. The infrastructure is provisioned via Terraform, and application lifecycle management is handled natively by ArgoCD.

## Key Engineering Achievements

### 1. GitOps Continuous Delivery (ArgoCD)
- Shifted from imperative `kubectl` deployments to declarative, Git-driven state management.
- Implemented automated, self-healing synchronization to prevent configuration drift and ensure the cluster state perfectly matches the Git repository.

### 2. Advanced Kustomize Overrides
Rather than forking the upstream repository, Kustomize was used to dynamically patch the remote manifests at deployment time:
- **StatefulSet Interception:** Overrode the upstream MongoDB StatefulSet to permanently strip out heavy, container-killing `mongo --eval` health probes. This stabilized the database tier and prevented persistent `CrashLoopBackOff` cycles.
- **Resource Tuning:** Injected custom resource requests and limits (CPU & Memory) into remote base manifests to enable accurate metrics gathering.
- **Networking & Security:** Patched internal cluster services to expose specific frontends via Azure Load Balancers, and injected Workload Identity service accounts across all deployments.

### 3. Autoscaling & Resilience
- Deployed a Horizontal Pod Autoscaler (HPA) to dynamically manage application replicas based on real-time compute utilization.

 









 <img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/76276142-c46c-46b9-b706-dfdcd7bbc08c" />

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/3bf836b7-0314-4a3e-84d1-878ad3dd03fa" />

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/b4a810e7-325b-4b7f-bf71-7431ecf99fb5" />


## Terminal output displaying the stability of the cluster after implementing resource patches.

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/1ee5655c-dd5e-4f73-a0fb-390322b6151f" />


##  The Contoso Admin Portal UI successfully fetching and displaying pending orders, validating the end-to-end connectivity between the frontend, API, and the stabilized MongoDB instance.
<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/669a39ad-d6c1-4328-81df-f65802c2c1ee" /> 

## The Contoso Admin Portal successfully retrieving and displaying order data. This shows that the internal microservices network (store-front -> makeline-service -> mongodb) being fully operational and that the resource optimizations applied to the database layer have resolved the previous connectivity bottlenecks.
<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/69ac487b-693f-42d8-b795-c9237e93b7e3" />



### Validation: Dynamic Scaling Under Load

To verify the resilience of the architecture, a synthetic load test was executed against the frontend service. The screenshot below demonstrates the Horizontal Pod Autoscaler (HPA) actively monitoring the cluster and reacting to the traffic spike.
 <img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/8962141a-69a8-4f5f-8f92-2915afc4d507" /> 
*Figure: Live terminal output during the stress test. As synthetic HTTP traffic pushed the `store-front` container's CPU utilization to 160% (exceeding the 50% target threshold), the HPA successfully intercepted the metrics and dynamically scaled the deployment from 1 up to 4 replicas to absorb the load.*
