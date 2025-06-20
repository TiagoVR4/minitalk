#!/bin/bash

echo "=== MINITALK TESTER ==="

# First run functional tests (faster without valgrind)
echo "=== RUNNING FUNCTIONAL TESTS ==="

# Start the server normally
./server > server_output.txt 2>&1 &
SERVER_PID=$!

# Wait for server to initialize
sleep 3

# Check if server started correctly
if [ ! -s server_output.txt ]; then
    echo "ERROR: Server didn't start properly. Check server executable."
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# Get the PID from the output file
DISPLAYED_PID=$(head -n1 server_output.txt | awk '{print $NF}')
echo "Server started with PID: $DISPLAYED_PID"

# Record current position in output file
MARK=$(wc -l < server_output.txt)

# Test with small message
MSG_SMALL="Hello World"
echo -e "\n=== SENDING SMALL MESSAGE ==="
echo "Message: '$MSG_SMALL'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$MSG_SMALL"
end_time=$(date +%s.%N)
sleep 2  # Wait longer for server to process
echo "Server output:"
tail -n +$((MARK+1)) server_output.txt
MARK=$(wc -l < server_output.txt)
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with medium message
echo -e "\n=== SENDING MEDIUM MESSAGE ==="
MSG_MEDIUM="This is a medium length message with multiple lines.\nIt tests newline handling.\nLine 1\nLine 2\nLine 3\nLine 4\nLine 5\nEnd of message."
echo "Message preview: '${MSG_MEDIUM:0:50}...'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$MSG_MEDIUM"
end_time=$(date +%s.%N)
sleep 2
echo "Server output:"
tail -n +$((MARK+1)) server_output.txt
MARK=$(wc -l < server_output.txt)
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with large message (10KB) using repeated text
echo -e "\n=== SENDING LARGE MESSAGE (10KB) ==="
yes "Lorem ipsum dolor sit amet consectetur adipiscing elit " | head -c 10240 > large_test.txt
echo "Message size: $(wc -c < large_test.txt) bytes"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$(cat large_test.txt)"
end_time=$(date +%s.%N)
sleep 3  # Wait longer for large message
echo "Server output size: $(tail -n +$((MARK+1)) server_output.txt | wc -c) bytes"
echo "Server output (full):"
tail -n +$((MARK+1)) server_output.txt
MARK=$(wc -l < server_output.txt)
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with special characters
echo -e "\n=== SENDING SPECIAL CHARACTERS ==="
SPECIAL_CHARS='!@#$%^&*()_+=-{}[]|\:;"<>,.?/~ `'
echo "Message: '$SPECIAL_CHARS'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$SPECIAL_CHARS"
end_time=$(date +%s.%N)
sleep 2
echo "Server output:"
tail -n +$((MARK+1)) server_output.txt
MARK=$(wc -l < server_output.txt)
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with control characters
echo -e "\n=== SENDING CONTROL CHARACTERS ==="
CONTROL_CHARS=$(printf "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F")
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "Control chars: $CONTROL_CHARS"
end_time=$(date +%s.%N)
sleep 2
echo "Server output (length): $(tail -n +$((MARK+1)) server_output.txt | wc -c) bytes"
MARK=$(wc -l < server_output.txt)
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Test with Unicode characters
echo -e "\n=== SENDING UNICODE CHARACTERS ==="
UNICODE_CHARS="áéíóúÁÉÍÓÚçÇãõÃÕ€£¥₩♠♣♥♦★✓😀😎🚀"
echo "Message: '$UNICODE_CHARS'"
start_time=$(date +%s.%N)
./client $DISPLAYED_PID "$UNICODE_CHARS"
end_time=$(date +%s.%N)
sleep 2
echo "Server output:"
tail -n +$((MARK+1)) server_output.txt
MARK=$(wc -l < server_output.txt)
duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Time taken: ${duration}s"

# Stop the server
kill $SERVER_PID 2>/dev/null
sleep 1

# Now run valgrind tests for memory leaks
echo -e "\n=== MEMORY LEAK TESTS WITH VALGRIND ==="
echo "Running server with valgrind..."

# Start server with valgrind
valgrind --leak-check=full --show-leak-kinds=all ./server > valgrind_server_output.txt 2> server_valgrind.txt &
VALGRIND_SERVER_PID=$!
sleep 5  # Wait longer for initialization with valgrind

# Get the PID from valgrind output
VALGRIND_DISPLAYED_PID=$(head -n1 valgrind_server_output.txt | awk '{print $NF}')
if [ -n "$VALGRIND_DISPLAYED_PID" ]; then
    echo "Valgrind server started with PID: $VALGRIND_DISPLAYED_PID"
    
    # Run multiple tests with valgrind client
    echo "Testing small message with valgrind..."
    valgrind --leak-check=full --show-leak-kinds=all ./client $VALGRIND_DISPLAYED_PID "Test small message" 2> client_valgrind_small.txt
    sleep 3
    
    echo "Testing medium message with valgrind..."
    valgrind --leak-check=full --show-leak-kinds=all ./client $VALGRIND_DISPLAYED_PID "This is a medium test message with some more content to test memory allocation and deallocation properly" 2> client_valgrind_medium.txt
    sleep 3
    
    echo "Testing special characters with valgrind..."
    valgrind --leak-check=full --show-leak-kinds=all ./client $VALGRIND_DISPLAYED_PID "$SPECIAL_CHARS" 2> client_valgrind_special.txt
    sleep 3
    
    # Stop the valgrind server
    echo "Stopping valgrind server..."
    kill $VALGRIND_SERVER_PID 2>/dev/null
    sleep 3  # Give time for valgrind to finish writing
    
    echo -e "\n=== VALGRIND MALLOC/FREE SUMMARY ==="
    echo "SERVER:"
    grep "total heap usage" server_valgrind.txt || echo "No heap usage info available"
    echo "CLIENT (small message):"
    grep "total heap usage" client_valgrind_small.txt || echo "No heap usage info available"
    echo "CLIENT (medium message):"
    grep "total heap usage" client_valgrind_medium.txt || echo "No heap usage info available"
    echo "CLIENT (special characters):"
    grep "total heap usage" client_valgrind_special.txt || echo "No heap usage info available"
else
    echo "ERROR: Valgrind server didn't start properly"
fi

# Clean up
rm -f server_output.txt large_test.txt valgrind_server_output.txt server_valgrind.txt client_valgrind_*.txt