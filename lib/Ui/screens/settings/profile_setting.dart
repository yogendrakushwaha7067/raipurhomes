import '../../../data/cubits/profile_setting_cubit.dart';
import '../../../data/helper/widgets.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/AnimatedRoutes/blur_page_route.dart';

class ProfileSettings extends StatefulWidget {
  final String? title;
  final String? param;
  const ProfileSettings({Key? key, this.title, this.param}) : super(key: key);

  @override
  ProfileSettingsState createState() => ProfileSettingsState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => ProfileSettings(
        title: arguments?['title'] as String,
        param: arguments?['param'] as String,
      ),
    );
  }
}

class ProfileSettingsState extends State<ProfileSettings> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
          context,
          widget
              .param!); //pass value for title from here [to pass as a parameter]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          title: widget.title!, showBackButton: true),
      // appBar: Widgets.setAppbar(widget.title!, context, []),
      body: BlocBuilder<ProfileSettingCubit, ProfileSettingState>(
          builder: (context, state) {
        if (state is ProfileSettingFetchProgress) {
          return Center(
            child: UiUtils.progress(
                normalProgressColor: context.color.teritoryColor),
          );
        } else if (state is ProfileSettingFetchSuccess) {
          return contentWidget(state, context);
        } else if (state is ProfileSettingFetchFailure) {
          // return Center(child: Text(state.errmsg));
          return Widgets.noDataFound(state.errmsg);
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

Widget contentWidget(ProfileSettingFetchSuccess state, BuildContext context) {
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Html(
      data: state.data.toString(),
      onAnchorTap: (url, context, attributes, element) {
        launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
      },
      customRender: {
        "table": (context, child) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: (context.tree as TableLayoutElement).toWidget(context),
          );
        }
      },
      style: {
        "table": Style(
          backgroundColor: Colors.grey[50],
        ),
        "p": Style(color: context.color.textColorDark),
        "p strong": Style(
            color: context.color.teritoryColor, fontSize: FontSize.larger),
        "tr": Style(
            // border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
        "th": Style(
          padding: const EdgeInsets.all(6),
          backgroundColor: Colors.grey,
          border: const Border(bottom: BorderSide(color: Colors.black)),
        ),
        "td": Style(
            padding: const EdgeInsets.all(6),
            border: Border.all(color: Colors.grey, width: 0.5)),
        'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
      },
    ),
    /* child: WebView(
      backgroundColor: ColorPrefs.lightBtnBGColor,
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: Uri.dataFromString(profileSettingData!, mimeType: 'text/html')
          .toString(), //state.profileSettingData!
    ),*/
  );
}
