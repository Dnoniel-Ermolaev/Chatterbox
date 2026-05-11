# Chatterbox

Проект для развёртывания [Gemma 2](https://doi.org/10.48550/arXiv.2408.00118) внутри контейнера.

- Веса модели (поместить в папку репозитория): [gemma-2-2b-it-Q6_K.gguf](https://drive.google.com/file/d/1zrdzqr0MCe2_6cgYEfAkmnN1YAgwN-y3/view?usp=sharing)

- Базовый docker-образ: ghcr.io/ggml-org/llama.cpp:server

**Собрать docker-образ:**

```bash
docker build -t chatterbox .
```

**Запуск локально внутри контейнера:**

Опциональный флаг --health-check указывает путь к папке с тестами.

В Windows консоли:

```powershell
docker run --rm -it `
    -p 8080:8080 `
    -v "${PWD}/tests:/tests" `
    -v "${PWD}:/models" `
    chatterbox `
    --model /models/gemma-2-2b-it-Q6_K.gguf `
    --host 0.0.0.0 `
    --port 8080 `
    --health-check /tests
# Server is running on http://localhost:8080
```

В Linux консоли:

```bash
docker run --rm -it \
    -p 8080:8080 \
    -v "${PWD}/tests:/tests" \
    -v "${PWD}:/models" \
    chatterbox \
    --model /models/gemma-2-2b-it-Q6_K.gguf \
    --host 0.0.0.0 \
    --port 8080 \
    --health-check /tests
# Server is running on http://localhost:8080
```
