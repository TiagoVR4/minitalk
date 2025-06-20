#!/bin/bash

echo "=== MINITALK TESTER ==="

# Start the server in background
./server > server_output.txt & 
SERVER_PID=$!

# Wait a bit to ensure the server has initialized
sleep 1

# Get the PID from the output file
DISPLAYED_PID=$(head -n1 server_output.txt | awk '{print $NF}')
echo "Server started with PID: $DISPLAYED_PID"

# Test with small message
MSG_SMALL="Hello World"
echo -e "\n=== SENDING SMALL MESSAGE ==="
echo "Message: '$MSG_SMALL'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$MSG_SMALL"
end_time=$(date +%s.%N)
sleep 1  # Wait after timing for output to appear
echo "Server output:"
tail -1 server_output.txt
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with medium message
MSG_MEDIUM=$(cat /etc/passwd | head -10)
echo -e "\n=== SENDING MEDIUM MESSAGE ==="
echo "Message (first 50 chars): '${MSG_MEDIUM:0:50}...'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$MSG_MEDIUM"
end_time=$(date +%s.%N)
sleep 1  # Wait after timing for output to appear
echo "Server output (first 50 chars):"
tail -1 server_output.txt | head -c 50
echo "..."
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with large message (10KB) using repeated text
echo -e "\n=== SENDING LARGE MESSAGE (10KB) ==="
yes "Lorem ipsum dolor sit amet consectetur adipiscing elit " | head -c 10240 > large_test.txt
echo "Message size: $(wc -c < large_test.txt) bytes"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$(cat large_test.txt)"
end_time=$(date +%s.%N)
sleep 2  # Wait after timing for output to appear
echo "Server output size: $(tail -1 server_output.txt | wc -c) bytes"
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with special characters
echo -e "\n=== SENDING SPECIAL CHARACTERS ==="
SPECIAL_CHARS='!@#$%^&*()_+=-{}[]|\:;"<>,.?/~` '
echo "Message: '$SPECIAL_CHARS'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$SPECIAL_CHARS"
end_time=$(date +%s.%N)
sleep 1  # Wait after timing for output to appear
echo "Server output:"
tail -1 server_output.txt
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with control characters
echo -e "\n=== SENDING CONTROL CHARACTERS ==="
CONTROL_CHARS=$(printf "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F")
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "Control chars: $CONTROL_CHARS"
end_time=$(date +%s.%N)
sleep 1  # Wait after timing for output to appear
echo "Server output (length): $(tail -1 server_output.txt | wc -c) bytes"
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with Unicode characters
echo -e "\n=== SENDING UNICODE CHARACTERS ==="
UNICODE_CHARS="áéíóúÁÉÍÓÚçÇãõÃÕ€£¥₩♠♣♥♦★✓😀😎🚀"
echo "Message: '$UNICODE_CHARS'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$UNICODE_CHARS"
end_time=$(date +%s.%N)
sleep 1  # Wait after timing for output to appear
echo "Server output:"
tail -1 server_output.txt
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

echo -e "\n=== TEST COMPLETE ==="

# Terminate the server
kill $SERVER_PID
echo "Server stopped"
rm server_output.txt large_test.txt