// import 'package:boilerplate/core/widgets/pip/picture_in_picture.dart';
// import 'package:boilerplate/core/widgets/pip/pip_widget.dart';
// import 'package:flutter/material.dart';

// class PiPCapableWidget extends StatefulWidget {
//   final Widget whileNotInPip;
//   final Widget whileInPip;
//   final Function onPipClose;

//   const PiPCapableWidget(
//       {super.key,
//       required this.whileInPip,
//       required this.whileNotInPip,
//       required this.onPipClose});

//   @override
//   State<PiPCapableWidget> createState() => _PiPCapableWidgetState();
// }

// class _PiPCapableWidgetState extends State<PiPCapableWidget> {
//   // Widget _defaultWhileInPiPWidget() {
//   //   return Builder(builder: (context) {
//   //     return AspectRatio(
//   //       aspectRatio: 16 / 9,
//   //       child: Container(
//   //         color: Colors.black,
//   //         alignment: Alignment.center,
//   //         width: MediaQuery.of(context).size.width,
//   //         child: const Text(
//   //           'Playing in PiP',
//   //           style: TextStyle(color: Colors.white),
//   //         ),
//   //       ),
//   //     );
//   //   });
//   // }

//   @override
//   void initState() {
//     PictureInPicture.isActive.addListener(
//       () {
//         if (PictureInPicture.isActive.value) {
//           PictureInPicture.startPiP(
//               pipWidget: PiPWidget(
//             onPiPClose: () {
//               //Handle closing events e.g. dispose controllers.
//               widget.onPipClose();
//             },
//             elevation: 10, //Optional
//             pipBorderRadius: 10,
//             child: widget.whileInPip, //Optional
//           ));
//         } else {}
//       },
//     );

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return !PictureInPicture.isActive.value
//         ? widget.whileNotInPip
//         : Container();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
