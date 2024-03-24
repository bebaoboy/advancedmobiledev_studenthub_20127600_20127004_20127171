import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/file_previewer.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/custom_page_route.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../di/service_locator.dart';

ValueNotifier<bool> isLinkCv = ValueNotifier<bool>(false);
ValueNotifier<bool> isLinkTranscript = ValueNotifier<bool>(false);

changeValue(value, isCV) async {
  await Future.delayed(Duration(seconds: 1));
  if (isCV)
    isLinkCv.value = value;
  else
    isLinkTranscript.value = value;
}

class ProfileStudentStep3Screen extends StatefulWidget {
  const ProfileStudentStep3Screen({super.key});

  @override
  _ProfileStudentStep3ScreenState createState() =>
      _ProfileStudentStep3ScreenState();
}

class _ProfileStudentStep3ScreenState extends State<ProfileStudentStep3Screen> {
  //text controllers:-----------------------------------------------------------

  //stores:---------------------------------------------------------------------
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  bool loading = false;
  Widget? _cvImage;
  Widget? _transcriptImage;
  bool cvEnable = true, transcriptEnable = true;

  TextEditingController cvController = TextEditingController();
  TextEditingController transcriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLinkCv = ValueNotifier<bool>(false);
    isLinkTranscript = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildRightSide(),
                    ),
                  ],
                )
              : Container(child: _buildRightSide()),
          Observer(
            builder: (context) {
              return _userStore.success
                  ? navigate(context)
                  : _showErrorMessage(_formStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _userStore.isLoading || loading,
                // child: CustomProgressIndicatorWidget(),
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        loading = false;
                      });
                    },
                    child: const LoadingScreen()),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Assets.carBackground,
        fit: BoxFit.cover,
      ),
    );
  }

  PlatformFile? _cv;
  PlatformFile? _transcript;
  Map<String, PreviewData?> pd = {};

  Widget _buildRightSide() {
    print(isLinkCv.value);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const EmptyAppBar(),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  AutoSizeText(
                    Lang.get('profile_welcome_cv'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    minFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AutoSizeText(
                    Lang.get('profile_welcome_text2'),
                    style: const TextStyle(fontSize: 13),
                    minFontSize: 10,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Image.asset(
                  //   'assets/images/img_login.png',
                  //   scale: 1.2,
                  // ),
                  const SizedBox(height: 34.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      "${Lang.get('profile_cv')}:\n${_cv != null ? _cv!.name : ""}",
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      minFontSize: 10,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Container(
                            height: 30,
                            child: TextFormField(
                              enabled: cvEnable,
                              controller: cvController,
                              onTapOutside: (value) async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  isLinkCv.value = false;
                                });
                                _cvImage = await FilePreview.getThumbnail(
                                    isCV: true, cvController.text);
                              },
                              onFieldSubmitted: (value) async {
                                setState(() {
                                  isLinkCv.value = false;
                                });
                                FocusManager.instance.primaryFocus?.unfocus();
                                await FilePreview.getThumbnail(
                                        isCV: true, cvController.text)
                                    .then((value) {
                                  _cvImage = value;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 10),
                                hintText: Lang.get("profile_project_link"),
                              ),
                              style: TextStyle(fontSize: 13),
                            )),
                      ),
                      if (_cv != null || _cvImage != null)
                        Container(
                          width: 40,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            color: Theme.of(context).colorScheme.primary,
                            iconSize: 20,
                            onPressed: () {
                              setState(() {
                                _cv = null;
                                cvEnable = true;
                                cvController.clear();
                                _cvImage = null;
                              });
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_cv != null) {
                        await OpenFilex.open(_cv!.path);
                        return;
                      } else if (_cvImage != null) {
                        final uri = Uri.parse(cvController.text);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                        return;
                      }
                      setState(() {
                        cvEnable = false;
                      });

                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['png', 'jpg', 'pdf', 'doc', 'docx'],
                      );

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        setState(() {
                          _cv = result.files.single;
                        });
                        final image = await FilePreview.getThumbnail(
                          isCV: true,
                          result.files.single.path!,
                        );
                        setState(() {
                          _cvImage = image;
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                    child: Container(
                        height: _cvImage != null ? 500 : 200,
                        decoration: const BoxDecoration(
                            color: Colors.white70,
                            borderRadius:
                                BorderRadius.all(Radius.circular(13))),
                        child: ValueListenableBuilder(
                          valueListenable: isLinkCv,
                          builder: (context, value, child) => isLinkCv.value ==
                                      true &&
                                  cvController.text.isNotEmpty
                              ? LinkPreview(
                                  enableAnimation: true,
                                  textWidget: const SizedBox(),
                                  onPreviewDataFetched: (p0) async {
                                    setState(() {
                                      if (p0.link != null) {
                                        pd[p0.link!] = p0;
                                        isLinkCv.value = true;
                                      }
                                    });
                                  },
                                  previewData: pd[cvController.text],
                                  text: cvController.text,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                )
                              : _cvImage ??
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: const Icon(
                                                Icons.add_a_photo,
                                              )),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(Lang.get('profile_cv_add'))
                                        ]),
                                  ),
                        )),
                  ),
                  const SizedBox(height: 34.0),

////////////////////////////////////////////////////////////////////////////

                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      "${Lang.get('profile_transcript')}:\n${_transcript != null ? _transcript!.name : ""}",
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      minFontSize: 10,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Container(
                            height: 30,
                            child: TextFormField(
                              enabled: transcriptEnable,
                              controller: transcriptController,
                              onTapOutside: (value) async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  isLinkTranscript.value = false;
                                });
                                _transcriptImage =
                                    await FilePreview.getThumbnail(
                                        isCV: false, transcriptController.text);
                              },
                              onFieldSubmitted: (value) async {
                                setState(() {
                                  isLinkTranscript.value = false;
                                });
                                FocusManager.instance.primaryFocus?.unfocus();
                                await FilePreview.getThumbnail(
                                        isCV: false, transcriptController.text)
                                    .then((value) {
                                  _transcriptImage = value;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 10),
                                hintText: Lang.get("profile_project_link"),
                              ),
                              style: TextStyle(fontSize: 13),
                            )),
                      ),
                      if (_transcript != null || _transcriptImage != null)
                        Container(
                          width: 40,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            color: Theme.of(context).colorScheme.primary,
                            iconSize: 20,
                            onPressed: () {
                              setState(() {
                                _transcript = null;
                                transcriptEnable = true;
                                transcriptController.clear();
                                _transcriptImage = null;
                              });
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_transcript != null) {
                        await OpenFilex.open(_transcript!.path);
                        return;
                      } else if (_transcriptImage != null) {
                        final uri = Uri.parse(transcriptController.text);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                        return;
                      }
                      setState(() {
                        transcriptEnable = false;
                      });

                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['png', 'jpg', 'pdf', 'doc', 'docx'],
                      );

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        setState(() {
                          _transcript = result.files.single;
                        });
                        final image = await FilePreview.getThumbnail(
                          isCV: false,
                          result.files.single.path!,
                        );
                        setState(() {
                          _transcriptImage = image;
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                    child: Container(
                      height: _transcriptImage != null ? 500 : 200,
                      decoration: const BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(13))),
                      child: ValueListenableBuilder(
                          valueListenable: isLinkTranscript,
                          builder: (context, value, child) => isLinkTranscript
                                          .value ==
                                      true &&
                                  transcriptController.text.isNotEmpty
                              ? LinkPreview(
                                  enableAnimation: true,
                                  textWidget: const SizedBox(),
                                  onPreviewDataFetched: (p0) async {
                                    setState(() {
                                      if (p0.link != null) {
                                        pd[p0.link!] = p0;
                                        isLinkTranscript.value = true;
                                      }
                                    });
                                  },
                                  previewData: pd[transcriptController.text],
                                  text: transcriptController.text,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                )
                              : _transcriptImage ??
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: const Icon(
                                                Icons.add_a_photo,
                                              )),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(Lang.get(
                                              'profile_transcript_add'))
                                        ]),
                                  )),
                    ),
                  ),
                  const SizedBox(height: 34.0),
                  _buildSignInButton(),
                ],
              ),
            ),
          ),
          //_buildFooterText(),
          const SizedBox(
            height: 14,
          ),
          //_buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 200,
        child: RoundedButtonWidget(
          buttonText: Lang.get('next'),
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          onPressed: () async {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute2(routeName: Routes.home),
                (Route<dynamic> route) => false);
            // if (_formStore.canProfileStudent) {
            //   DeviceUtils.hideKeyboard(context);
            //   _userStore.login(
            //       _userEmailController.text, _passwordController.text);
            // } else {
            //   _showErrorMessage(AppLocalizations.of(context)
            //       .get('login_error_missing_fields'));
            // }
          },
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(const Duration(milliseconds: 0), () {
      print("LOADING = $loading");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute2(routeName: Routes.home),
          (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: Lang.get('error'),
            duration: const Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    isLinkCv.dispose();
    isLinkTranscript.dispose();
    super.dispose();
  }
}
