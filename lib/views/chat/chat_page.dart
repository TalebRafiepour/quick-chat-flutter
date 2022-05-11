import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_chat_app/model/chat.dart';
import 'package:quick_chat_app/service/socket_service.dart';
import 'package:quick_chat_app/utils/constants.dart';

import 'chat_text_input.dart';
import 'message_view.dart';
import 'user_list_view.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void dispose() {
    SocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: StreamBuilder(
            stream: SocketService.typing,
            builder: (context, AsyncSnapshot<String> snapShot) {
              if (snapShot.data == null || snapShot.data!.isEmpty) {
                return const Text(appName);
              } else {
                return Text(snapShot.data!);
              }
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: const [
            UserListView(),
            _ChatBody(),
            SizedBox(height: 6),
            ChatTextInput(),
          ],
        ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var chats = <Chat>[];
    ScrollController _scrollController = ScrollController();

    ///scrolls to the bottom of page
    void _scrollDown() {
      try {
        Future.delayed(
            const Duration(milliseconds: 300),
            () => _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent));
      } on Exception catch (_) {}
    }

    return Expanded(
      child: StreamBuilder(
        stream: SocketService.getResponse,
        builder: (BuildContext context, AsyncSnapshot<Chat> snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            chats.add(snapshot.data!);
          }
          _scrollDown();
          return ListView.builder(
            controller: _scrollController,
            itemCount: chats.length,
            itemBuilder: (BuildContext context, int index) =>
                MessageView(chat: chats[index]),
          );
        },
      ),
    );
  }
}
