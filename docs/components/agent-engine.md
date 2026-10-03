# Component: agent-engine

- **Status:** Skeleton
- **Source:** `agent-engine/`

## Responsibility
Receive Linear webhooks, run a LangGraph loop backed by Claude, and push small atomic commits to `main`.

## Files
| File | Description |
|------|-------------|
| `Dockerfile` | python:3.11-slim + git, curl; `uvicorn main:app` on port 8000 |
| `requirements.txt` | fastapi, uvicorn, pydantic, requests, GitPython, langgraph, langchain-anthropic |
| `main.py` | FastAPI app: `GET /health`, `POST /webhook/ticket` (placeholder) |
| `agent/` | LangGraph graph and tools (empty) |

## Interfaces
- `GET /health` → `{"status": "healthy"}`
- `POST /webhook/ticket` ← Linear webhook (headers `Linear-Event`, `Linear-Signature`)

## Known limitations / TODO
- No signature verification, no priority/state filter, agent not wired (F-03..F-05).
- Webhook should return quickly and run the agent in the background (Linear retries slow responses).
- `langgraph` / `langchain-anthropic` are unpinned: pin once versions are validated.
