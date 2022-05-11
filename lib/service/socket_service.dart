import 'dart:async';

import 'package:quick_chat_app/model/chat.dart';
import 'package:quick_chat_app/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static late StreamController<Chat> _socketResponse;
  static late StreamController<List<String>> _userResponse;
  static late StreamController<String> _typing;
  static late io.Socket _socket;
  static String _userName = '';

  static String? get userId => _socket.id;

  static Stream<Chat> get getResponse =>
      _socketResponse.stream.asBroadcastStream();

  static Stream<List<String>> get userResponse =>
      _userResponse.stream.asBroadcastStream();

  static Stream<String> get typing => _typing.stream.asBroadcastStream();

  static void setUserName(String name) {
    _userName = name;
  }

  static void setUserIsTyping() {
    _socket.emit('typing', {'userId': userId});
  }

  static void sendMessage(String message) {
    _socket.emit(
      'new_message',
      {'userId': userId, 'username': _userName, 'message': message},
    );
  }

  static void connectAndListen() {
    _socketResponse = StreamController<Chat>();
    _userResponse = StreamController<List<String>>();
    _typing = StreamController<String>();
    _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .build());

    _socket.connect();
    _socket.emit('change_username', {'nickName': _userName});

    //When an event recieved from server, data is added to the stream
    _socket.on('new_message', (data) {
      _socketResponse.sink.add(Chat.fromRawJson(data));
      _typing.sink.add('');
    });

    //when users are connected or disconnected
    _socket.on('get users', (data) {
      var users =
          (data as List<dynamic>).map((e) => e['username'].toString()).toList();
      _userResponse.sink.add(users);
    });

    _socket.on('typing', (data) {
      if (data['username'] != _userName) {
        _typing.sink.add('${data['username']} is typing...');
      }
    });

    // _socket.onDisconnect((_) => print('disconnect'));
  }

  static void dispose() {
    _socket.dispose();
    _socket.destroy();
    _socket.close();
    _socket.disconnect();
    _socketResponse.close();
    _typing.close();
    _userResponse.close();
  }
}
