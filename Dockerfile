# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app

# Upgrade pip, setuptools and wheel to the latest version
RUN pip install --upgrade pip setuptools wheel

# Install build dependencies that might be needed for some packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Rust, as some Python libraries use it for performance
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# --- КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ ---
# Сначала копируем все файлы, необходимые для сборки
COPY pyproject.toml .
COPY setup.py .
COPY lightrag/ ./lightrag/

# Теперь, когда все файлы на месте, устанавливаем проект
# Устанавливаем в пользовательскую директорию, чтобы легко скопировать в финальный образ
RUN pip install --user --no-cache-dir .[api]

# Final stage
FROM python:3.12-slim

WORKDIR /app

# Копируем только установленные пакеты из builder-стадии
COPY --from=builder /root/.local /root/.local

# Добавляем установленные пакеты в PATH, чтобы можно было запустить lightrag-server
ENV PATH=/root/.local/bin:$PATH

# Создаем директории для данных
RUN mkdir -p /app/data/rag_storage /app/data/inputs

# Устанавливаем переменные окружения для этих директорий
ENV WORKING_DIR=/app/data/rag_storage
ENV INPUT_DIR=/app/data/inputs

# Railway требует, чтобы порт был прослушан внутри контейнера
# Lightrag по умолчанию использует 8000, но мы можем указать его явно
EXPOSE 8000
ENV PORT=8000

# Правильная команда для запуска сервера
CMD ["lightrag-server"]
