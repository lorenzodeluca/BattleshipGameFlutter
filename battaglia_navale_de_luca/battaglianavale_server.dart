import 'dart:io';

ServerSocket server;
List<ChatClient> clients = [];

void main() {
  print("Server ready");
  ServerSocket.bind(InternetAddress.anyIPv4, 1010).then((ServerSocket socket) {
    server = socket;
    server.listen((client) {
      handleConnection(client);
    });
    ChatClient globalClient = ChatClient.fromId("Global");
    clients.add(globalClient);
  });
}

void handleConnection(Socket client) {
  print('Connection from ${client.remoteAddress.address}:${client.remotePort}');

  clients.add(ChatClient(client));

  // client.write("Welcome to dart-chat! "
  //     "There are ${clients.length - 1} other clients\n");
}

void removeClient(ChatClient client) {
  clients.remove(client);
}

void distributeMessage(ChatClient client, String message) {
  for (ChatClient c in clients) {
    if (c != client) {
      c.write(message + "\n");
    }
  }
}

// ChatClient class for server

class ChatClient {
  Socket _socket;
  String get _address => _socket.remoteAddress.address;
  int get _port => _socket.remotePort;
  String clientId="anon";

  ChatClient(Socket s) {
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }
  ChatClient.fromId(this.clientId) {}

  int findSeparator(String s) {
    int sepIndex = -1;
    for (int i = 0; i < s.length && sepIndex == -1; i++) {
      if (s[i] == ':') sepIndex = i;
    }
    return sepIndex;
  }
  bool lock=false;
  void messageHandler(data) {
    String message = new String.fromCharCodes(data).trim(), destination, msg;
    //message handling
    int separator =
        findSeparator(message); //separator between cmd and param index
    destination = message.substring(0, separator);
    msg = message.substring(separator + 1);
    print(clientId + " sending msg " + message); //debug
    while(lock);
    forwardMessage(message);
    //distributeMessage(this, '${_address}:${_port} Message: $message');
  }

  void forwardMessage(String msg) {
    lock=true;
    for (ChatClient c in clients) {
      //print(c.clientId+"^^^"); //debug
      if (c != null && clients.contains(c) && c.clientId != "global")
        c.write(msg);
    }
    lock=false;
  }



  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    try {
      removeClient(this);
      _socket.close();
    } catch (e) {}
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    removeClient(this);
    _socket.close();
  }

  void write(String message) {
    try {
      _socket.write(message);
    } catch (e) {}
  }
}

