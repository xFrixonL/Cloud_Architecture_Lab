# Cloud Architecture & Design Patterns Lab

Practical implementations of distributed cloud architecture and resilience patterns using Python, Docker, NGINX, and AWS Infrastructure-as-Code templates.

## Repository Branch Structure

| Branch | Covered Patterns & Technologies | Stack |
| :--- | :--- | :--- |
| [`feat/01-resilience-patterns`] | 1. Circuit Breaker<br>2. Retry Pattern<br>3. Timeout Pattern | Python (FastAPI, PyBreaker, Tenacity) |
| [`feat/02-traffic-and-compute`] | 4. Serverless (Lambda) & Containers (ECS)<br>5. API Gateway, Load Balancer & Reverse Proxy | Docker Compose, NGINX, Python |
| [`feat/03-hub-spoke-and-bastion`] | 6. Hub-and-Spoke Architecture<br>8. Bastion Host (Jump Box) | Docker Networks, OpenSSH, Terraform (AWS) |
| [`feat/04-lift-and-shift-migration`] | 7. Lift-and-Shift Migration (On-Premise $\rightarrow$ AWS) | Docker Compose, PostgreSQL, Bash, Terraform |