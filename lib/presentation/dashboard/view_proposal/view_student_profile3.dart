import "package:universal_html/html.dart" show AnchorElement;

import 'package:boilerplate/core/widgets/auto_size_text.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/file_previewer.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/account/profile_entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/link_previewer/widgets/link_preview.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/preview_data.dart';
import 'package:boilerplate/presentation/profile/store/form/profile_student_form_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

ValueNotifier<bool> isLinkCv = ValueNotifier<bool>(false);
ValueNotifier<bool> isLinkTranscript = ValueNotifier<bool>(false);

changeValue(value, isCV) async {
  await Future.delayed(const Duration(seconds: 1));
  if (isCV) {
    isLinkCv.value = value;
  } else {
    isLinkTranscript.value = value;
  }
}

class ViewStudentProfile3 extends StatefulWidget {
  final StudentProfile studentProfile;
  const ViewStudentProfile3({super.key, required this.studentProfile});

  @override
  State<ViewStudentProfile3> createState() => _ViewStudentProfile3State();
}

class _ViewStudentProfile3State extends State<ViewStudentProfile3> {
  bool loading = false;
  Widget? _cvImage;
  Widget? _transcriptImage;
  bool cvEnable = true, transcriptEnable = true;

  TextEditingController cvController = TextEditingController();
  TextEditingController transcriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var profileStore = getIt<ProfileStudentFormStore>();

    Future.delayed(Duration.zero, () async {
      var transcript = await profileStore.getStudentTranscript(
          widget.studentProfile.transcript ?? '',
          widget.studentProfile.objectId!,
          widget.studentProfile);
      transcriptController.text = transcript;
      if (mounted) {
        setState(() {
          isLinkTranscript.value = true;
        });
      }
      await FilePreview.getThumbnail(
              changeValue: changeValue, isCV: false, transcriptController.text)
          .then(
        (value) {
          if (value != null) {
            if (mounted) {
              setState(() {
                isLinkTranscript.value = false;
              });
            }
            _transcriptImage = value;
          }
        },
      );

      var cv = await profileStore.getStudentResume(
        widget.studentProfile.resume ?? '',
        widget.studentProfile.objectId!,
      );

      cvController.text = cv;
      if (mounted) {
        setState(() {
          isLinkCv.value = true;
        });
      }

      await FilePreview.getThumbnail(
              changeValue: changeValue, isCV: true, cvController.text)
          .then(
        (value) {
          if (value != null) {
            if (mounted) {
              setState(() {
                isLinkCv.value = false;
              });
            }
            _cvImage = value;
          }
        },
      );
    });

    isLinkCv = ValueNotifier<bool>(true);
    isLinkTranscript = ValueNotifier<bool>(true);
    Future.delayed(Duration.zero, () async {
      if (cvController.text.isNotEmpty) {
        if (kIsWeb) {
          AnchorElement anchorElement = AnchorElement(href: cvController.text);
          anchorElement.download = "Your CV";
          anchorElement.click();
        } else {
          _cvImage = await FilePreview.getThumbnail(cvController.text,
              isCV: true,
              changeValue: changeValue,
              retrieveFilePathAfterDownload: (s) =>
                  _cv = PlatformFile(path: s, name: s, size: 1));
        }
      }
      if (transcriptController.text.isNotEmpty) {
        if (kIsWeb) {
          Future.delayed(const Duration(seconds: 1), () {
            AnchorElement anchorElement =
                AnchorElement(href: transcriptController.text);
            anchorElement.download = "Your transcript";
            anchorElement.click();
          });
        } else {
          _transcriptImage = await FilePreview.getThumbnail(
              transcriptController.text,
              isCV: false,
              changeValue: changeValue,
              retrieveFilePathAfterDownload: (s) =>
                  _transcript = PlatformFile(path: s, name: s, size: 1));
        }
      }
      print(_cvImage.toString());
      if (mounted) {
        setState(() {
          isLinkCv.value = false;
          isLinkTranscript.value = false;
        });
      }
    });
  }

  PlatformFile? _cv;
  PlatformFile? _transcript;
  Map<String, PreviewData?> pd = {};

  Widget _buildBody() {
    //print(isLinkCv.value);
    return SingleChildScrollView(
      controller: ScrollController(),
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
                        child: SizedBox(
                            height: 30,
                            child: TextFormField(
                              readOnly: true,
                              controller: cvController,
                              onTapOutside: (value) async {},
                              onFieldSubmitted: (value) async {},
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 10),
                                hintText: Lang.get("profile_project_link"),
                              ),
                              style: const TextStyle(fontSize: 13),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_cvImage != null) {
                        final uri = Uri.parse(cvController.text);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                        return;
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      // height: _cvImage != null ? null : 200,
                      decoration: const BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(13))),
                      child: ValueListenableBuilder(
                          valueListenable: isLinkCv,
                          builder: (context, value, child) => isLinkCv.value ==
                                      true &&
                                  cvController.text.isNotEmpty
                              ? LinkPreview(
                                  loadingWidget: Lottie.asset(
                                    'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                                    fit: BoxFit.cover,
                                    width:
                                        80, // Adjust the width and height as needed
                                    height: 80,
                                    repeat:
                                        true, // Set to true if you want the animation to loop
                                  ),
                                  forceMaximize: true,
                                  enableAnimation: true,
                                  textWidget: const SizedBox(),
                                  onPreviewDataFetched: (p0) async {
                                    print("fetch");
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
                                              child: Lottie.asset(
                                                'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                                                fit: BoxFit.cover,
                                                width:
                                                    80, // Adjust the width and height as needed
                                                height: 80,
                                                repeat:
                                                    true, // Set to true if you want the animation to loop
                                              )),
                                        ]),
                                  )),
                    ),
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
                        child: SizedBox(
                            height: 30,
                            child: TextFormField(
                              readOnly: true,
                              controller: transcriptController,
                              onTapOutside: (value) async {},
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 10),
                                hintText: Lang.get("profile_project_link"),
                              ),
                              style: const TextStyle(fontSize: 13),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_transcriptImage != null) {
                        final uri = Uri.parse(transcriptController.text);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                        return;
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      // height: _transcriptImage != null ? null : 200,
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
                                  loadingWidget: Lottie.asset(
                                    'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                                    fit: BoxFit.cover,
                                    width:
                                        80, // Adjust the width and height as needed
                                    height: 80,
                                    repeat:
                                        true, // Set to true if you want the animation to loop
                                  ),
                                  forceMaximize: true,
                                  enableAnimation: true,
                                  textWidget: const SizedBox(),
                                  onPreviewDataFetched: (p0) async {
                                    setState(() {
                                      print("fetch");
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
                                              child: Lottie.asset(
                                                'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                                                fit: BoxFit.cover,
                                                width:
                                                    80, // Adjust the width and height as needed
                                                height: 80,
                                                repeat:
                                                    true, // Set to true if you want the animation to loop
                                              )),
                                        ]),
                                  )),
                    ),
                  ),
                  const SizedBox(height: 34.0),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 10, right: 30, bottom: 20, left: 30),
                alignment: Alignment.bottomLeft,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Back"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: _buildBody(),
    );
  }
}
