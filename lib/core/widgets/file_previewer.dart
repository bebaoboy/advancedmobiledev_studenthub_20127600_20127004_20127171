import 'dart:async';
import 'dart:io';

import 'package:boilerplate/presentation/profile/profile_student_step3.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' show extension;
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:validators/validators.dart';

class FilePreview {
  static const MethodChannel _channel = MethodChannel('file_preview');

  // static ImageProvider getProvider(String uri) {
  //   return NetworkImage(uri);
  // }

  /// Create a preview [Image] of a file from a given [filePath]. In case it's an image extension it will invoke the default flutter Image providers,
  /// in case its a pdf it will invoke the native pdf renderer. For iOS it will try to use the native previewer,
  /// which is the same preview you would see in the files app on iOS.
  static Future<Widget?> getThumbnail(
    String filePath, {
    double? height,
    double? width,
    Widget? defaultImage,
    required bool isCV,
  }) async {
    // if (filePath.startsWith('http') ||
    //     filePath.startsWith('blob') ||
    //     filePath.startsWith('www')) {

    // }
    if (isURL(filePath)) {
      try {
        return CachedNetworkImage(
          width: width,
          height: height,
          imageUrl: filePath,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.scaleDown,
                // colorFilter:
                //     ColorFilter.mode(Colors.red, BlendMode.colorBurn)
              ),
            ),
          ),
          placeholder: (context, url) => Center(
            child: Lottie.asset(
              'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
              fit: BoxFit.cover,
              width: 80, // Adjust the width and height as needed
              height: 80,
              repeat: true, // Set to true if you want the animation to loop
            ),
          ),
          errorWidget: (context, url, error) {
            changeValue(true, isCV);
            return Padding(
              padding: const EdgeInsets.all(13.0),
              child: Center(child: Text(filePath,)),
            );
          },
          errorListener: (value) {
            //print("error");
          },
        );
      } catch (e) {
        return null;
      }
    } else {
      switch (extension(filePath.toLowerCase())) {
        case ".pdf":
          return await generatePDFPreview(
            filePath,
            height: height ?? 400,
            width: width ?? 200,
            defaultImage: defaultImage,
          );
        case ".jpg":
        case ".jpeg":
        case ".png":
        case ".gif":
          return Image.file(
            File(filePath),
            width: width,
            height: height,
          );
        default:
          if (Platform.isIOS) {
            final Uint8List byteList =
                await _channel.invokeMethod('getThumbnail', filePath);
            return Image.memory(byteList);
          } else {
            try {
              return CachedNetworkImage(
                width: width,
                height: height,
                imageUrl: filePath,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.scaleDown,
                      // colorFilter:
                      //     ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(
                  child: Lottie.asset(
                    'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                    fit: BoxFit.cover,
                    width: 80, // Adjust the width and height as needed
                    height: 80,
                    repeat:
                        true, // Set to true if you want the animation to loop
                  ),
                ),
                errorWidget: (context, url, error) {
                  changeValue(true, isCV);
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(filePath),
                    ),
                  );
                },
                errorListener: (value) {
                  //print("error");
                },
              );
            } catch (e) {
              return null;
            }
            // return null;
          }
      }
    }
  }

  /// Creates a file preview of a .pdf file of the given [filePath]. In case it cannot be properly rendered, invoke [_defaultImage] instead.
  static Future generatePDFPreview(
    String filePath, {
    double height = 100,
    double width = 80,
    Widget? defaultImage,
  }) async {
    try {
      // Initialize the renderer
      final pdf = PdfImageRendererPdf(path: filePath);

      // open the pdf document
      await pdf.open();

      // open a page from the pdf document using the page index
      await pdf.openPage(pageIndex: 0);

      // get the actual image of the page
      final image = await pdf.renderPage(
        pageIndex: 0,
        x: 0,
        y: 0,
        //  width: width.toInt(),
        // height: height.toInt(),
        scale: 1, // increase the scale for better quality (e.g. for zooming)
        background: Colors.white,
      );

      // close the page again
      await pdf.closePage(pageIndex: 0);

      // close the PDF after rendering the page
      pdf.close();
      // final page = await document.params.layoutPages().getPage(1);

      return image != null
          ? Image.memory(image)
          : defaultImage ?? _defaultImage;
    } catch (e) {
      return defaultImage ?? _defaultImage;
    }
  }

  /// In case a file preview cannot be properly rendered, and no default image is provided show a placeholder image
  static Image get _defaultImage => const Image(
        image: AssetImage(
          'assets/images/img_login.png',
        ),
      );
}
