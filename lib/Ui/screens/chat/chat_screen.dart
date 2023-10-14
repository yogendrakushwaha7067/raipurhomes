import 'dart:developer';

import '../widgets/AnimatedRoutes/transparant_route.dart';
import 'chatAudio/widgets/record_button.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../../../data/Repositories/property_repository.dart';
import '../../../data/cubits/chatCubits/load_chat_messages.dart';
import '../../../data/cubits/chatCubits/send_message.dart';
import '../../../data/helper/widgets.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/Notification/chat_message_handler.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/routes.dart';
import '../../../data/model/data_output.dart';
import '../../../data/model/property_model.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Notification/notification_service.dart';
import '../../../utils/constant.dart';
import '../../../utils/helper_utils.dart';
import 'chatAudio/widgets/chat_widget.dart';

int totalMessageCount = 0;

class ChatScreen extends StatefulWidget {
  final String? from;
  final String profilePicture;
  final String userName;
  final String propertyImage;
  final String proeprtyTitle;
  final String userId; //for which we are messageing
  final String propertyId;
  const ChatScreen(
      {super.key,
      required this.profilePicture,
      required this.userName,
      required this.propertyImage,
      required this.proeprtyTitle,
      required this.userId,
      required this.propertyId,
      this.from});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _recordButtonAnimation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  TextEditingController controller = TextEditingController();
  PlatformFile? messageAttachment;
  bool isFetchedFirstTime = false;
  double scrollPositionWhenLoadMore = 0;

  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(
      () {
        if (_pageScrollController.offset >=
            _pageScrollController.position.maxScrollExtent) {
          if (context.read<LoadChatMessagesCubit>().hasMoreChat()) {
            setState(() {});
            context.read<LoadChatMessagesCubit>().loadMore();
          }
        }
      },
    );
  @override
  void initState() {
    context.read<LoadChatMessagesCubit>().load(
        userId: int.parse(widget.userId),
        propertyId: int.parse(widget.propertyId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        currentlyChatingWith = "";
        ChatMessageHandler.flushMessages();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (messageAttachment != null) ...[
                  Container(
                    color: context.color.secondaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AttachmentMessage(url: messageAttachment!.path!),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
                BottomAppBar(
                  height: 60,
                  padding: const EdgeInsetsDirectional.all(10),
                  elevation: 5,
                  color: context.color.secondaryColor,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (messageAttachment == null) {
                                FilePickerResult? pickedAttachment =
                                    await FilePicker.platform.pickFiles(
                                  allowMultiple: false,
                                );

                                messageAttachment =
                                    pickedAttachment?.files.first;
                                setState(() {});
                              } else {
                                messageAttachment = null;
                                setState(() {});
                              }
                            },
                            icon: messageAttachment != null
                                ? const Icon(Icons.close)
                                : const Icon(Icons.add)),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            cursorColor: context.color.teritoryColor,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: context.color.teritoryColor)),
                              hintText: UiUtils.getTranslatedLabel(
                                context,
                                "writeSomething",
                              ),
                            ),
                          ),
                        ),
                        RecordButton(
                          controller: _recordButtonAnimation,
                          callback: (path) {
                            if (Constant.isDemoModeOn) {
                              HelperUtils.showSnackBarMessage(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "thisActionNotValidDemo"));
                              return;
                            }

                            //This is adding Chat widget in stream with BlocProvider , because we will need to do api process to store chat message to server, when it will be added to list it's initState method will be called
                            ChatMessageHandler.add(BlocProvider(
                              create: (context) => SendMessageCubit(),
                              child: ChatMessage(
                                key: ValueKey(
                                    DateTime.now().toString().toString()),
                                message: "[AUDIO]",
                                senderId: HiveUtils.getUserId().toString(),
                                propertyId: widget.propertyId,
                                reciverId: widget.userId,
                                time: DateTime.now().toString(),
                                hasAttachment: false,
                                isSentByMe: true,
                                isChatAudio: true,
                                isSentNow: true,
                                audioFile: path,
                              ),
                            ));
                            totalMessageCount++;

                            setState(() {});
                          },
                          isSending: false,
                        ),
                        GestureDetector(
                          onTap: () {
                            //if file is selected then user can send message without text
                            if (controller.text.trim().isEmpty &&
                                messageAttachment == null) return;
                            //This is adding Chat widget in stream with BlocProvider , because we will need to do api process to store chat message to server, when it will be added to list it's initState method will be called
                            if (Constant.isDemoModeOn) {
                              HelperUtils.showSnackBarMessage(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "thisActionNotValidDemo"));
                              return;
                            }
                            ChatMessageHandler.add(
                              BlocProvider(
                                key: ValueKey(
                                    DateTime.now().toString().toString()),
                                create: (context) => SendMessageCubit(),
                                child: ChatMessage(
                                  key: ValueKey(
                                      DateTime.now().toString().toString()),
                                  message: controller.text,
                                  hasAttachment: messageAttachment != null,
                                  senderId: HiveUtils.getUserId().toString(),
                                  propertyId: widget.propertyId,
                                  reciverId: widget.userId,
                                  time: DateTime.now().toString(),
                                  isSentByMe: true,
                                  isChatAudio: false,
                                  isSentNow: true,
                                  attachment: messageAttachment?.path,
                                ),
                              ),
                            );
                            totalMessageCount++;

                            controller.text = "";
                            messageAttachment = null;
                            setState(() {});
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: context.color.teritoryColor,
                            child: Icon(
                              Icons.send,
                              color: context.color.buttonColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            centerTitle: false,
            automaticallyImplyLeading: true,
            backgroundColor: context.color.secondaryColor,
            elevation: 0,
            iconTheme: IconThemeData(color: context.color.teritoryColor),
            actions: [
              if (widget.from != "property")
                IconButton(
                    onPressed: () {
                      Navigator.push(context, BlurredRouter(
                        builder: (context) {
                          return ChatInfoWidget(
                            propertyId: widget.propertyId,
                            propertyTitle: widget.proeprtyTitle,
                            propertyTitleImage: widget.propertyImage,
                          );
                        },
                      ));
                    },
                    icon: Icon(
                      Icons.info,
                      color: context.color.textColorDark.withOpacity(0.7),
                    ))
            ],
            title: FittedBox(
              fit: BoxFit.none,
              child: Row(
                children: [
                  widget.profilePicture == ""
                      ? CircleAvatar(
                          backgroundColor: context.color.teritoryColor,
                          child: SvgPicture.asset(
                            AppIcons.placeHolder,
                            color: context.color.buttonColor,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              TransparantRoute(
                                barrierDismiss: true,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      color: const Color.fromARGB(69, 0, 0, 0),
                                      child: Hero(
                                        tag: "RR",
                                        transitionOnUserGestures: true,
                                        flightShuttleBuilder: (flightContext,
                                            animation,
                                            flightDirection,
                                            fromHeroContext,
                                            toHeroContext) {
                                          return CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              widget.profilePicture,
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            widget.profilePicture,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: Hero(
                            tag: "RR",
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                widget.profilePicture,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.userName)
                          .color(context.color.textColorDark)
                          .size(context.font.normal),
                      Text(widget.proeprtyTitle)
                          .size(context.font.small)
                          .color(context.color.textColorDark),
                    ],
                  )
                ],
              ),
            ),
          ),
          body: BlocConsumer<LoadChatMessagesCubit, LoadChatMessagesState>(
            listener: (context, state) {
              if (state is LoadChatMessagesSuccess) {
                ChatMessageHandler.loadMessages(state.messages, context);
                totalMessageCount = state.messages.length;

                // if (isFetchedFirstTime == false) {
                //   Future.delayed(
                //     const Duration(milliseconds: 100),
                //     () {
                //       _pageScrollController.jumpTo(
                //         _pageScrollController.position.maxScrollExtent + 200,
                //       );
                //     },
                //   );
                // } else {
                //   log(scrollPositionWhenLoadMore.toString(),
                //       name: "@scrollpostion");

                //   Future.delayed(const Duration(milliseconds: 1000), () {
                //     _pageScrollController.animateTo(scrollPositionWhenLoadMore,
                //         duration: const Duration(milliseconds: 300),
                //         curve: Curves.linear);
                //   });
                // }

                isFetchedFirstTime = true;

                setState(() {});
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  StreamBuilder(
                      stream: ChatMessageHandler.getChatStream(),
                      builder: (context, AsyncSnapshot snapshot) {
                        Widget? loadingMoreWidget;
                        if (state is LoadChatMessagesSuccess) {
                          if (state.isLoadingMore) {
                            loadingMoreWidget = Text(
                                UiUtils.getTranslatedLabel(context, "loading"));
                          }
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.active ||
                            snapshot.connectionState == ConnectionState.done) {
                          return Column(
                            children: [
                              loadingMoreWidget ?? const SizedBox.shrink(),
                              Expanded(
                                child: ListView.builder(
                                  reverse: true,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  addAutomaticKeepAlives: true,
                                  controller: _pageScrollController,
                                  itemCount: snapshot.data.length,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  itemBuilder: (context, index) {
                                    dynamic chat = (snapshot.data as List)
                                        .elementAt(index);
                                    return chat;
                                  },
                                ),
                              ),
                            ],
                          );
                        }

                        return Container();
                      }),
                  if ((state is LoadChatMessagesInProgress))
                    Center(
                      child: UiUtils.progress(),
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ChatInfoWidget extends StatelessWidget {
  final String propertyTitleImage;
  final String propertyTitle;
  final String propertyId;
  const ChatInfoWidget(
      {super.key,
      required this.propertyTitleImage,
      required this.propertyTitle,
      required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.color.teritoryColor),
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: context.screenHeight * 0.46,
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              width: context.screenWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(context,
                            provider:
                                CachedNetworkImageProvider(propertyTitleImage));
                      },
                      child: CachedNetworkImage(
                        imageUrl: propertyTitleImage,
                        width: context.screenWidth,
                        fit: BoxFit.cover,
                        height: context.screenHeight * 0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(propertyTitle)
                          .setMaxLines(
                            lines: 2,
                          )
                          .size(
                            context.font.larger.rf(
                              context,
                            ),
                          ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: UiUtils.buildButton(context, onPressed: () async {
                        try {
                          Widgets.showLoader(context);
                          PropertyRepository fetch = PropertyRepository();
                          DataOutput<PropertyModel> dataOutput = await fetch
                              .fetchPropertyFromPropertyId(propertyId);
                          log("data ${dataOutput.modelList}");
                          Future.delayed(
                            Duration.zero,
                            () {
                              Widgets.hideLoder(context);

                              HelperUtils.goToNextPage(
                                  Routes.propertyDetails, context, false,
                                  args: {
                                    'propertyData': dataOutput.modelList[0],
                                    'propertiesList': dataOutput.modelList,
                                    'fromMyProperty': false,
                                  });
                            },
                          );
                        } catch (e) {
                          Widgets.hideLoder(context);
                        }
                      },
                          buttonTitle: UiUtils.getTranslatedLabel(
                              context, "viewProperty"),
                          width: context.screenWidth * 0.5,
                          fontSize: context.font.normal,
                          height: 40),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
