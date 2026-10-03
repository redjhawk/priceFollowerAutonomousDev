from fastapi import FastAPI, Request

app = FastAPI(title="Autonomous Agent Engine")


@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.post("/webhook/ticket")
async def handle_ticket_webhook(request: Request):
    payload = await request.json()

    # Placeholder: verify Linear-Signature, filter high priority + "In Progress",
    # then start the LangGraph agent loop (F-03, F-04, F-05).
    event_type = request.headers.get("Linear-Event", "unknown")
    print(f"Received webhook event: {event_type}")

    return {"status": "success", "message": "Webhook processed and agent triggered."}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
