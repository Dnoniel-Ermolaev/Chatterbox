FROM ghcr.io/ggml-org/llama.cpp:server

USER root
RUN apt-get update && apt-get install -y curl sed jq grep coreutils && rm -rf /var/lib/apt/lists/*

RUN find / -name "llama-server" -type f -executable 2>/dev/null || true

WORKDIR /app

COPY benchmark.sh /app/benchmark.sh
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/benchmark.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]