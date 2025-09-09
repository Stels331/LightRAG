# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app

# Upgrade pip, setuptools and wheel to the latest version
RUN pip install --upgrade pip setuptools wheel

# Install Rust and required build dependencies for faster dependency builds
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set the Cargo environment
ENV PATH="/root/.cargo/bin:${PATH}"

# Copy project files
COPY pyproject.toml .
COPY setup.py .
COPY lightrag/ ./lightrag/

# Install the project and its "api" extras dependencies
# This single command should install all necessary Python packages
RUN pip install --user --no-cache-dir .[api]

# Final stage
FROM python:3.12-slim

WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# Copy installed packages from the builder stage
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY ./lightrag ./lightrag
COPY setup.py .
# start.py is no longer needed

# Add the local bin to the PATH to find the installed executables
ENV PATH=/root/.local/bin:$PATH

# Create necessary directories
RUN mkdir -p /app/data/rag_storage /app/data/inputs

# Set environment variables for data directories
ENV WORKING_DIR=/app/data/rag_storage
ENV INPUT_DIR=/app/data/inputs

# Expose the port Railway will connect to
EXPOSE 8000

# Set the default port for the lightrag-server
ENV PORT=8000

# Run the LightRAG server using its built-in command
CMD ["lightrag-server"]

