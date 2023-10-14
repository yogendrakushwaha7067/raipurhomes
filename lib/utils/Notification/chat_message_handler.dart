import 'dart:async';

import '../../Ui/screens/chat/chatAudio/widgets/chat_widget.dart';
import '../Extensions/extensions.dart';
import '../ui_utils.dart';
import 'package:flutter/material.dart';

int sentMessages = 0;

class ChatMessageHandler {
  static List<Widget> messages = [];
  static final List<Widget> _chat = [];
  static final StreamController<List<Widget>> _chatMessageStream =
      StreamController<List<Widget>>.broadcast();

  static void add(chat) {
    List<Widget> msgs = (messages);

    _chat.insert(0, chat);

    ///don't change this line
    msgs = [..._chat, ...msgs];

    // msgs.insert(0, chat);
    _chatMessageStream.sink.add(msgs);
    // messages.clear();
  }

  static void loadMessages(List<Widget> chats, BuildContext context) {
    List<Widget> messagesWithDate = [];
    String previousDate = "";
    // Get the current date and time
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    for (int i = chats.length - 1; i >= 0; i--) {
      DateTime date = DateTime.parse((chats[i] as ChatMessage).time).toLocal();
      String formattedDate;

      if (date.isAfter(today)) {
        formattedDate = UiUtils.getTranslatedLabel(context, "today");
      } else if (date.isAfter(yesterday)) {
        formattedDate = UiUtils.getTranslatedLabel(context, "yesterday");
      } else {
        formattedDate = (date.toString()).formatDate();
      }

      // Add date widget if date has changed
      if (formattedDate != previousDate) {
        messagesWithDate.insert(0, messageDateChip(context, formattedDate));
        previousDate = formattedDate;
      }

      // Add message widget
      messagesWithDate.insert(0, chats[i]);
    }

    // Update the messages list and sink the new messages to the stream
    messages = messagesWithDate;
    // messages = chats; //uncomment and comment above code if problem in chat
    _chatMessageStream.sink.add(messages);
  }

  static Widget messageDateChip(BuildContext context, String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
          child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: context.color.teritoryColor.withOpacity(0.3)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(formattedDate),
        ),
      )),
    );
  }

  static void flushMessages() {
    messages.clear();
    _chat.clear();
  }

  static Stream<List> getChatStream() {
    return _chatMessageStream.stream;
  }

  static attachListener(void Function(dynamic)? onData) {
    _chatMessageStream.stream.listen(onData);
  }
}
