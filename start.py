import os
import uvicorn

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    # Исправлено: правильный путь к LightRAG серверу
    uvicorn.run("lightrag.api.lightrag_server:app", host="0.0.0.0", port=port)
