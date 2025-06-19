#!/bin/bash

echo "=== MINITALK TESTER ==="

# Inicia o servidor em background
./server > server_output.txt & 
SERVER_PID=$!

# Espera um pouco para garantir que o servidor inicializou
sleep 1

# Pega o PID do arquivo de saída
DISPLAYED_PID=$(head -n1 server_output.txt | awk '{print $NF}')
echo "Server started with PID: $DISPLAYED_PID"

# Teste com mensagem pequena
MSG_SMALL="Hello World"
echo -e "\n=== SENDING SMALL MESSAGE ==="
echo "Message: '$MSG_SMALL'"
./client $DISPLAYED_PID "$MSG_SMALL"
sleep 1
echo "Server output:"
tail -1 server_output.txt

# Teste com mensagem média
MSG_MEDIUM=$(cat /etc/passwd | head -10)
echo -e "\n=== SENDING MEDIUM MESSAGE ==="
echo "Message (first 50 chars): '${MSG_MEDIUM:0:50}...'"
./client $DISPLAYED_PID "$MSG_MEDIUM"
sleep 1
echo "Server output (first 50 chars):"
tail -1 server_output.txt | head -c 50
echo "..."

# Teste com mensagem grande (10KB)
echo -e "\n=== SENDING LARGE MESSAGE (10KB) ==="
dd if=/dev/urandom bs=1024 count=10 2>/dev/null | base64 > large_test.txt
echo "Message size: $(wc -c < large_test.txt) bytes"
./client $DISPLAYED_PID "$(cat large_test.txt)"
sleep 2
echo "Server output size: $(tail -1 server_output.txt | wc -c) bytes"

echo -e "\n=== TEST COMPLETE ==="

# Encerra o servidor
kill $SERVER_PID
echo "Server stopped"
rm server_output.txt large_test.txt