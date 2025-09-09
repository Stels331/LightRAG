import os
import uvicorn

if __name__ == "__main__":
    print("=== LightRAG Server Starting ===")
    
    # Railway автоматически устанавливает переменную PORT
    port = int(os.environ.get("PORT", 8000))
    print(f"Starting LightRAG server on port: {port}")
    
    # Запускаем LightRAG API сервер
    uvicorn.run(
        "lightrag.api.lightrag_server:app",
        host="0.0.0.0",
        port=port,
        log_level="info",
        access_log=True
    )
