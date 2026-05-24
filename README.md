
# Enterprise Microservices on AKS via GitOps

## Overview
This repository demonstrates a production-grade deployment of a polyglot microservices application (Microsoft's AKS Store Demo) utilizing a strict GitOps workflow. The infrastructure is provisioned via Infrastructure as Code (Terraform), and application lifecycle management is handled natively by ArgoCD. 

This architecture emphasizes high availability, self-healing configurations, identity-based security, and dynamic autoscaling—aligning with modern Platform Engineering and DevOps best practices.

## Application Interfaces
The deployed microservices architecture includes a customer-facing frontend and an internal administrative portal, both exposed securely via Azure Load Balancers.

### Store Frontend
<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/669a39ad-d6c1-4328-81df-f65802c2c1ee" />
*Figure 1: The Contoso Pet Store customer-facing web application.*

### Admin Portal
<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/69ac487b-693f-42d8-b795-c9237e93b7e3" />
*Figure 2: The internal Admin Portal for order management and tracking.*

---

## Key Engineering Achievements

### 1. GitOps Continuous Delivery (ArgoCD)
- Shifted from imperative `kubectl` deployments to declarative, Git-driven state management.
- Implemented automated, self-healing synchronization to prevent configuration drift and ensure the cluster state perfectly matches the Git repository.

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/76276142-c46c-46b9-b706-dfdcd7bbc08c" /> 
*Figure 3: ArgoCD dashboard demonstrating a 100% healthy, synchronized state across all microservices, secrets, and configurations.*

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/3bf836b7-0314-4a3e-84d1-878ad3dd03fa" />
*Figure 4: ArgoCD dashboard demonstrating a 100% healthy, synchronized state across all microservices, secrets, and configurations.*

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/b4a810e7-325b-4b7f-bf71-7431ecf99fb5" />
*Figure 5: ArgoCD dashboard demonstrating a 100% healthy, synchronized state across all microservices, secrets, and configurations.*




### 2. Advanced Kustomize Overrides & Resilience
Rather than maintaining a hard-fork of the upstream repository, Kustomize was utilized to dynamically patch the remote manifests at deployment time, ensuring upstream updates can still be pulled cleanly.

- **StatefulSet Interception (Database Stabilization):** Overrode the upstream MongoDB StatefulSet to permanently strip out heavy, container-killing `mongo --eval` health probes. This stabilized the database tier and prevented persistent `CrashLoopBackOff` cycles that often plague free-tier or cost-optimized compute nodes.

 
<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/388dbe9f-b966-41de-9e20-990e31b7c6f0" />
*Figure 6: Terminal output verifying the successful deployment of the standalone MongoDB override. The `RESTARTS` counter remains at `0`, proving the eradication of the crash loops.*

- **Resource Tuning & Security:** Injected custom resource requests and limits (CPU & Memory) into remote base manifests to enable accurate metrics gathering. Injected Workload Identity service accounts across all deployments to eliminate hardcoded credentials.

### 3. Autoscaling under Load (HPA)
- Deployed a Horizontal Pod Autoscaler (HPA) to dynamically manage application replicas based on real-time compute utilization.

#### Validation: Dynamic Scaling Under Stress Test
To verify the resilience of the architecture, a synthetic HTTP load test was executed against the frontend service. 

<img width="1923" height="1124" alt="Image" src="https://github.com/user-attachments/assets/e7c27be6-0334-436d-a9e0-555735154dd3" />
*Figure 7: Live terminal output during the stress test. As synthetic HTTP traffic pushed the `store-front` container's CPU utilization to 160% (exceeding the 50% target threshold), the HPA successfully intercepted the metrics and dynamically scaled the deployment from 1 up to 4 replicas to seamlessly absorb the load.*

---

## Technologies Used
* **Cloud Provider:** Microsoft Azure (AKS)
* **Infrastructure as Code:** Terraform, Bicep
* **GitOps / CI/CD:** ArgoCD
* **Configuration Management:** Kustomize
* **Orchestration:** Kubernetes
* **Monitoring & Scaling:** Kubernetes Metrics Server, Horizontal Pod Autoscaler (HPA) 
