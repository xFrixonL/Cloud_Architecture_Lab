import asyncio
import random
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Unstable External Service")

# Modos: "healthy", "slow" (dispara Timeout), "flaky" (dispara Retry), "down" (abre Circuit Breaker)
SERVICE_MODE = "healthy"


@app.post("/mode/{new_mode}")
async def set_mode(new_mode: str):
    global SERVICE_MODE
    if new_mode not in ["healthy", "slow", "flaky", "down"]:
        raise HTTPException(status_code=400, detail="Invalid mode")
    SERVICE_MODE = new_mode
    return {"status": f"Service mode changed to: {SERVICE_MODE}"}


@app.get("/analyze")
async def analyze_data():
    if SERVICE_MODE == "down":
        raise HTTPException(status_code=503, detail="Service Unavailable (Simulated Crash)")

    if SERVICE_MODE == "slow":
        await asyncio.sleep(4.0)  # Supera el timeout de 1.5s del cliente
        return {"result": "Completed after heavy delay"}

    if SERVICE_MODE == "flaky":
        if random.random() < 0.70:  # 70% de probabilidad de fallo transitorio
            raise HTTPException(status_code=500, detail="Transient Network Error")
        return {"result": "Success after transient hiccup!"}

    return {"result": "Analysis OK - Normal response"}