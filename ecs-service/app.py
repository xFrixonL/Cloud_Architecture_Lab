import os
import socket
from fastapi import FastAPI

app = FastAPI(title="ECS Containerized Microservice")

# Devuelve el hostname/ID del contenedor para evidenciar el Load Balancing Round-Robin
INSTANCE_ID = socket.gethostname()
ENV_NAME = os.getenv("DEPLOY_TARGET", "AWS-ECS-Fargate-Simulated")


@app.get("/api/reports")
def get_reports():
    return {
        "service": "report-service",
        "runtime": ENV_NAME,
        "container_instance": INSTANCE_ID,
        "status": "200 OK - Served from ECS Task",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy", "instance": INSTANCE_ID}