#  QS1

Swift test using QUIC protocol


# Swift Quic Server
QServer is a server written in swift to listen for QUIC connection. Open a new connection for each client and listen for text, the server act as as a hub, reading text from a client and sending to the all other clients connected.

Use: qswiftserver -l <port>
Example: ./qswiftserver -l 30000

Start a quic server to listen into the specified port, default port is 30000
 
 

# Swift Quic Client
QClient is a client written un swift to connect to a server using QUIC. 
The client send text to the server and receive from the server text from all others clients connected to the server.

Use: qswiftclient <ip_server> <port_server>
Example: ./qswiftclient 192.168.2.70 30000


# CA Certificate
You must change the CA certificate and use your own. You can follow this link to read whow to do it: https://developer.apple.com/documentation/network/creating_an_identity_for_local_network_tls




#L4S
L4S
to decrease latency time, activate L4S in macOS or iphone

macos:
% sudo defaults write -g network_enable_l4s -bool true
% sudo defaults read network_enable_l4s 


iphone:
Activade in settings --> Development --> L4S

Here you can find how to test L4S with apple devices
https://developer.apple.com/documentation/network/testing_and_debugging_l4s_in_your_app
