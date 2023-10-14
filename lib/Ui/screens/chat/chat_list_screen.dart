import 'dart:developer';

import 'chat_screen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../../../data/cubits/chatCubits/load_chat_messages.dart';
import '../../../data/model/chat/chated_user_model.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/Notification/notification_service.dart';
import '../../../utils/ui_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../data/cubits/chatCubits/get_chat_users.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ChatListScreen();
      },
    );
  }

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<GetChatListCubit>().hasMoreData()) {
          context.read<GetChatListCubit>().loadMore();
        }
      }
    });
  @override
  void initState() {
    context.read<GetChatListCubit>().fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.getTranslatedLabel(context, "message"),
      ),
      body: BlocBuilder<GetChatListCubit, GetChatListState>(
        builder: (context, state) {
          if (state is GetChatListFailed) {
            log(state.error.toString(), name: "hehe");
            return const SomethingWentWrong();
          }

          if (state is GetChatListInProgress) {
            return Center(
              child: UiUtils.progress(
                  normalProgressColor: context.color.teritoryColor),
            );
          }
          if (state is GetChatListSuccess) {
            if (state.chatedUserList.isEmpty) {
              return Center(
                child: Text(UiUtils.getTranslatedLabel(context, "noChats")),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(

                      controller: _pageScrollController,
                      shrinkWrap: true,
                      itemCount: state.chatedUserList.length,
                      padding: const EdgeInsetsDirectional.all(16),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        ChatedUser chatedUser = state.chatedUserList[index];

                        return Padding(
                          padding: const EdgeInsets.only(top: 9.0),
                          child: ChatTile(
                            id: chatedUser.userId.toString(),
                            propertyId: chatedUser.propertyId.toString(),
                            profilePicture: chatedUser.profile ?? "",
                            userName: chatedUser.name ?? "",
                            propertyPicture: chatedUser.titleImage ?? "",
                            propertyName: chatedUser.title ?? "",
                            pendingMessageCount: "5",
                          ),
                        );
                      }),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }

          return Container();
        },
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String profilePicture;
  final String userName;
  final String propertyPicture;
  final String propertyName;
  final String propertyId;
  final String pendingMessageCount;
  final String id;
  const ChatTile(
      {super.key,
      required this.profilePicture,
      required this.userName,
      required this.propertyPicture,
      required this.propertyName,
      required this.pendingMessageCount,
      required this.id,
      required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, BlurredRouter(
          builder: (context) {
            currentlyChatingWith = id;
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => LoadChatMessagesCubit(),
                ),
              ],
              child: Builder(builder: (context) {
                return ChatScreen(
                  profilePicture: profilePicture,
                  proeprtyTitle: propertyName,
                  userId: id,
                  propertyImage: propertyPicture,
                  userName: userName,
                  propertyId: propertyId,
                );
              }),
            );
          },
        ));
      },
      child: AbsorbPointer(
        absorbing: true,
        child: SizedBox(
          height: 55,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Stack(
                children: [
                  const SizedBox(
                    width: 58,
                    height: 58,
                  ),
                  GestureDetector(
                    onTap: () {
                      UiUtils.showFullScreenImage(context,
                          provider:
                              CachedNetworkImageProvider(propertyPicture));
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: propertyPicture,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(context,
                            provider:
                                CachedNetworkImageProvider(profilePicture));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)),
                        child: profilePicture == ""
                            ? CircleAvatar(
                                radius: 15,
                                backgroundColor: context.color.teritoryColor,
                                child: SvgPicture.asset(
                                  AppIcons.placeHolder,
                                  color: context.color.buttonColor,
                                ),
                              )
                            : CircleAvatar(
                                radius: 15,
                                backgroundColor: context.color.teritoryColor,
                                backgroundImage: NetworkImage(profilePicture),
                              ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                  ).bold().color(context.color.textColorDark),
                  Text(
                    propertyName,
                  ).color(context.color.textColorDark),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
