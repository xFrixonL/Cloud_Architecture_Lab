import logging
import httpx
import pybreaker
from fastapi import FastAPI
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("ResilientClient")

app = FastAPI(title="Resilient Microservice Client")

# 1. CIRCUIT BREAKER: Abre el circuito tras 3 fallos consecutivos; espera 15s antes de pasar a Half-Open
breaker = pybreaker.CircuitBreaker(fail_max=3, reset_timeout=15)


# 2. RETRY + 3. TIMEOUT: Reintenta hasta 3 veces con backoff exponencial (0.5s, 1s, 2s) y timeout de 1.5s
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=0.5, min=0.5, max=2),
    retry=retry_if_exception_type((httpx.TimeoutException, httpx.HTTPStatusError)),
    reraise=True,
)
def fetch_with_timeout_and_retry():
    logger.info("Sending request to external service (timeout=1.5s)...")
    # Timeout estricto de 1.5 segundos
    with httpx.Client(timeout=1.5) as client:
        response = client.get("http://127.0.0.1:8001/analyze")
        response.raise_for_status()
        return response.json()


def call_protected_service():
    # Envuelve la llamada con el Circuit Breaker
    return breaker.call(fetch_with_timeout_and_retry)


@app.get("/process")
def process_request():
    try:
        data = call_protected_service()
        return {
            "status": "SUCCESS",
            "circuit_state": breaker.current_state,
            "data": data,
        }
    except pybreaker.CircuitBreakerError:
        logger.warning("CIRCUIT OPEN! Fast-failing and returning fallback immediately.")
        return {
            "status": "FALLBACK (Circuit Open)",
            "circuit_state": breaker.current_state,
            "data": {"result": "Default cached/fallback classification"},
        }
    except Exception as exc:
        logger.error(f"Request failed after retries: {exc}")
        return {
            "status": "FALLBACK (Retries Exhausted / Timeout)",
            "circuit_state": breaker.current_state,
            "error": str(exc),
            "data": {"result": "Default cached/fallback classification"},
        }