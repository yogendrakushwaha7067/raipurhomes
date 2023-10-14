import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import '../../../../../utils/Extensions/extensions.dart';
import '../../../../../utils/helper_utils.dart';
import '../../../../../utils/ui_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../data/cubits/chatCubits/send_message.dart';
import '../../../../../utils/hive_utils.dart';

Set sentMessages = {};

class ChatMessage extends StatefulWidget {
  final String message;
  final String senderId;
  final bool isSentByMe;
  final bool? isSentNow;
  final String propertyId;
  final String reciverId;
  final bool isChatAudio;
  final bool hasAttachment;
  final dynamic audioFile;
  final String time;
  final dynamic attachment;
  const ChatMessage({
    super.key,
    this.isSentNow,
    required this.message,
    required this.isSentByMe,
    required this.isChatAudio,
    this.audioFile,
    this.attachment,
    required this.senderId,
    required this.time,
    required this.hasAttachment,
    required this.propertyId,
    required this.reciverId,
  });

  @override
  State<ChatMessage> createState() => ChatMessageState();

  toMap() {
    Map data = {};
    data['key'] = key;
    data['message'] = message;
    data['isSentNow'] = isSentNow;
    data['isSentByMe'] = isSentByMe;
    data['isChatAudio'] = isChatAudio;
    data['senderId'] = senderId;
    data['propertyId'] = propertyId;
    data['reciverId'] = reciverId;
    data['hasAttachment'] = hasAttachment;
    data['audioFile'] = audioFile;
    data['time'] = time;
    data['attachment'] = attachment;
    return data;
  }

  factory ChatMessage.fromMap(Map json) {
    return ChatMessage(
        key: json['key'],
        message: json['message'],
        isSentByMe: json['isSentByMe'],
        isChatAudio: json['isChatAudio'],
        senderId: json['senderId'],
        time: json['time'],
        hasAttachment: json['hasAttachment'],
        propertyId: json['propertyId'],
        reciverId: json['reciverId']);
  }
}

class ChatMessageState extends State<ChatMessage>
    with AutomaticKeepAliveClientMixin {
  bool isChatSent = false;
  bool selectedMessage = false;
  static bool isMounted = false;
  @override
  void initState() {
    ///isSentNow is for check if we are not appending messages multiple time
    if (widget.isSentByMe &&
        (widget.isSentNow == true) &&
        isChatSent == false) {
      if (!sentMessages.contains(widget.key)) {
        context.read<SendMessageCubit>().send(
              senderId: HiveUtils.getUserId().toString(),
              recieverId: widget.reciverId,
              attachment: widget.attachment,
              message: widget.message,
              proeprtyId: widget.propertyId,
              audio: widget.audioFile,
            );
      }
      sentMessages.add(widget.key);

      isMounted = true;
    }

    super.initState();
  }

  String _emptyTextIfAttachmentHasNoText() {
    if (widget.hasAttachment) {
      if (widget.message == "[File]") {
        return "";
      } else {
        return widget.message;
      }
    } else {
      return widget.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onLongPress: () {
        // selectedMessage = !selectedMessage;
        setState(() {});
        // log("pressing");
      },
      onTap: () {
        selectedMessage = false;
      },
      child: Container(
        alignment:
            widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.007,
          right: widget.isSentByMe ? 10 : 0,
          left: widget.isSentByMe ? 0 : 10,
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.8),
          decoration: BoxDecoration(
            color: selectedMessage == true
                ? (widget.isSentByMe == true
                    ? context.color.teritoryColor.darken(45)
                    : context.color.secondaryColor.darken(45))
                : (widget.isSentByMe
                    ? context.color.teritoryColor.withOpacity(0.9)
                    : context.color.secondaryColor),
            borderRadius: BorderRadius.only(
              topRight:
                  widget.isSentByMe ? Radius.zero : const Radius.circular(5),
              topLeft:
                  widget.isSentByMe ? const Radius.circular(5) : Radius.zero,
              bottomLeft: const Radius.circular(5),
              bottomRight: const Radius.circular(5),
            ),
          ),
          child: Wrap(
            runAlignment: WrapAlignment.end,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 6.0, right: 10, top: 5, bottom: 5),
                child: Container(
                  child: widget.isChatAudio
                      ? RecordMessage(
                          url: widget.audioFile!,
                          isSentByMe: widget.isSentByMe,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.hasAttachment)
                              AttachmentMessage(url: widget.attachment),
                            SelectableText(
                              _emptyTextIfAttachmentHasNoText(),
                              selectionControls:
                                  MaterialTextSelectionControls(),
                              style: TextStyle(
                                color: widget.isSentByMe
                                    ? context.color.secondaryColor
                                    : context.color.textColorDark,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Text(
                  (DateTime.parse(widget.time))
                      .toLocal()
                      .toIso8601String()
                      .toString()
                      .formatDate(format: "hh:mm aa"), //
                  style: TextStyle(
                      color: widget.isSentByMe
                          ? context.color.primaryColor
                          : context.color.textColorDark),
                ).size(context.font.smaller),
              ),
              if (widget.isSentByMe && widget.isSentNow == true) ...[
                BlocConsumer<SendMessageCubit, SendMessageState>(
                  listener: (context, state) {
                    if (state is SendMessageSuccess) {
                      isChatSent = true;

                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        setState(() {});
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state is SendMessageInProgress) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5.0, bottom: 2),
                        child: Icon(
                          Icons.watch_later_outlined,
                          size: context.font.smaller,
                          color: context.color.primaryColor,
                        ),
                      );
                    }

                    if (state is SendMessageFailed) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5.0, bottom: 2),
                        child: Icon(
                          Icons.error,
                          size: context.font.smaller,
                          color: context.color.primaryColor,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RecordMessage extends StatefulWidget {
  final String url;
  final bool isSentByMe;
  const RecordMessage({super.key, required this.url, required this.isSentByMe});

  @override
  State<RecordMessage> createState() => _RecordMessageState();
}

class _RecordMessageState extends State<RecordMessage> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int position = 0;
  int durationChanged = 0;

  @override
  void initState() {
    audioPlayer.onDurationChanged.listen((Duration event) {
      durationChanged = event.inSeconds;
      setState(() {});
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      isPlaying = event == PlayerState.playing;

      setState(() {});
    });
    audioPlayer.onPositionChanged.listen((Duration event) {
      position = event.inSeconds;
      setState(() {});
    });
    // audioPlayer.seek(const Duration(seconds: 1));

    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            onTap: () {
              if (!isPlaying) {
                if (widget.url.startsWith(("http")) ||
                    widget.url.startsWith("https")) {
                  audioPlayer.play(UrlSource(widget.url));
                } else {
                  audioPlayer.play(DeviceFileSource(widget.url));
                }
              } else {
                audioPlayer.stop();
              }
            },
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.isSentByMe
                  ? context.color.primaryColor
                  : context.color.teritoryColor,
            )),
        Slider(
          activeColor: widget.isSentByMe
              ? context.color.primaryColor
              : context.color.teritoryColor,
          inactiveColor: widget.isSentByMe
              ? context.color.primaryColor.withOpacity(0.3)
              : context.color.teritoryColor.withOpacity(0.3),
          value: position.toDouble(),
          onChanged: (v) {
            audioPlayer.seek(Duration(seconds: v.toInt()));
            setState(() {});
          },
          min: 0,
          max: durationChanged.toDouble(),
        ),
        if ((durationChanged - position) != 0)
          Text((durationChanged - position).toString()).color(widget.isSentByMe
              ? context.color.primaryColor
              : context.color.textColorDark)
      ],
    );
  }
}

class AttachmentMessage extends StatefulWidget {
  final String url;
  const AttachmentMessage({super.key, required this.url});

  @override
  State<AttachmentMessage> createState() => _AttachmentMessageState();
}

class _AttachmentMessageState extends State<AttachmentMessage> {
  bool isFileDownloading = false;
  double persontage = 0;

  getExtentionOfFile() {
    return widget.url.toString().split(".").last;
  }

  getFileName() {
    return widget.url.toString().split("/").last;
  }

  downloadFile() async {
    try {
      String? downloadPath = await getDownloadPath();
      await Dio().download(
        widget.url,
        "${downloadPath!}/${getFileName()}",
        onReceiveProgress: (int count, int total) async {
          persontage = (count) / total;

          if (persontage == 1) {
            HelperUtils.showSnackBarMessage(
                context, UiUtils.getTranslatedLabel(context, "fileSavedIn"),
                type: MessageType.success);

            await OpenFilex.open("$downloadPath/${getFileName()}");
          }
          setState(() {});
        },
      );
    } catch (e) {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(context, "errorFileSave"),
          type: MessageType.success);
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        HelperUtils.showSnackBarMessage(
            context, UiUtils.getTranslatedLabel(context, "fileNotSaved"),
            type: MessageType.success);
      }
    }
    return directory?.path;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await downloadFile();
          },
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            color: context.color.primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (persontage != 0 && persontage != 1) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 1.7,
                        color: context.color.teritoryColor,
                        value: persontage,
                      ),
                      const Icon(Icons.close)
                    ],
                  ),
                ] else ...[
                  Text(getExtentionOfFile().toString().toUpperCase()),
                  const Icon(
                    Icons.download,
                    size: 14,
                  )
                ]
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Container(
            height: 50,
            alignment: Alignment.centerLeft,
            color: context.color.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(getFileName().toString()).setMaxLines(
                lines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
