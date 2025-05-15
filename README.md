# minitalk

## Description
Minitalk is a 42 school project that demonstrates inter-process communication in Unix using only signals. The project consists of a server and a client program. The client sends a string message to the server, bit by bit, using SIGUSR1 and SIGUSR2 signals. The server reconstructs the message and prints it to the standard output.

## How it works
- The server displays its PID and waits for signals from the client.
- The client takes the server PID and a message as arguments, then sends each character bit by bit using signals.
- SIGUSR1 represents a bit value of 1, SIGUSR2 represents a bit value of 0.
- The server reconstructs each character from the received bits and prints the message.

## Usage
1. Compile the project:
   ```sh
   make
   ```
2. Run the server in one terminal:
   ```sh
   ./server
   ```
   The server will display its PID.
3. In another terminal, run the client with the server PID and your message:
   ```sh
   ./client <server_pid> "Your message here"
   ```

## Example
```
$ ./server
Server PID: 12345

$ ./client 12345 "Hello, 42!"

# Output on server terminal:
Hello, 42!
```

## Notes
- The communication is limited by the speed of signal processing. For large messages, increase the delay in the client if needed.
- Only standard Unix signals are used (no sockets, pipes, or shared memory).