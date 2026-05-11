#!/bin/bash

TEST_PATH=""
ARGS=()

BASE_URL="http://127.0.0.1:8080"

while [[ $# -gt 0 ]]; do
    case $1 in
        --health-check)
            TEST_PATH="$2"
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

SERVER_BIN="/app/llama-server"
[ ! -f "$SERVER_BIN" ] && SERVER_BIN="llama-server"

if [ -n "$TEST_PATH" ]; then
    start_ms=$(date +%s%3N)

    echo -n "Launching server...  "
    $SERVER_BIN "${ARGS[@]}" > /dev/null 2>&1 &
    SERVER_PID=$!

    until curl -s "$BASE_URL/health" | grep -q 'ok'; do
        if ! kill -0 $SERVER_PID 2>/dev/null; then exit 1; fi
        sleep 2
    done

    end_ms=$(date +%s%3N)
    diff_ms=$((end_ms - start_ms))
    printf -v TIME_STR "%d.%03d s" $((diff_ms / 1000)) $((diff_ms % 1000))
    echo "done in $TIME_STR"

    /app/benchmark.sh "$TEST_PATH" "$BASE_URL/completion"
    echo "End of testing. You may stop server via Ctrl+C"
    wait $SERVER_PID
else
    exec $SERVER_BIN "${ARGS[@]}"
fi