import json
from datetime import datetime, timezone


def handler(event, context):
    # Simula validación serverless de metadatos de imagen al subir un archivo
    body = event.get("body", "{}")
    if isinstance(body, str):
        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            payload = {"raw": body}
    else:
        payload = body

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "runtime": "AWS Lambda Python 3.12 (Local RIE)",
            "function_name": getattr(context, "function_name", "exif-validator-lambda"),
            "processed_at": datetime.now(timezone.utc).isoformat(),
            "received_event": payload,
            "validation": "PASSED",
        }),
    }