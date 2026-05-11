#!/bin/bash

TEST_DIR="$1"
URL="${2:-http://127.0.0.1:8080/completion}"

if [ ! -d "$TEST_DIR" ]; then
    echo "❌ ERROR: Test location not found: $TEST_DIR"
    exit 1
fi

echo "--- Running tests from $TEST_DIR ---"

for in_file in "$TEST_DIR"/*.in; do
    [ -e "$in_file" ] || continue
    
    test_name=$(basename "$in_file" .in)
    gold_file="$TEST_DIR/$test_name.gold"
    out_file="$TEST_DIR/$test_name.out" 
    
    if [ ! -f "$gold_file" ]; then
        echo "ERROR on $test_name : no $gold_file"
        continue
    fi

    PROMPT=$(cat "$in_file" | awk 1 ORS='\\n' | sed 's/"/\\"/g')

    start_ms=$(date +%s%3N)
    RESPONSE=$(curl -s -X POST "$URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"$PROMPT\", 
            \"n_predict\": 128, 
            \"stream\": false,
            \"seed\": 42,
            \"temperature\": 0.0
            }")
    end_ms=$(date +%s%3N)

    RAW_CONTENT=$(echo "$RESPONSE" | jq -r '.content')

    printf "%b" "$RAW_CONTENT" > "$out_file"

    ACTUAL_HASH=$(sha256sum "$out_file" | awk '{print $1}')
    EXPECTED_HASH=$(sha256sum "$gold_file" | awk '{print $1}')

    diff_ms=$((end_ms - start_ms))
    printf -v TIME_STR "%d.%03d s" $((diff_ms / 1000)) $((diff_ms % 1000))

    if [ "$ACTUAL_HASH" == "$EXPECTED_HASH" ]; then
        echo "✅ PASS | $test_name | $TIME_STR"
    else
        echo "❌ FAIL | $test_name | $TIME_STR"
        echo "   Content: $RAW_CONTENT" 
    fi
done