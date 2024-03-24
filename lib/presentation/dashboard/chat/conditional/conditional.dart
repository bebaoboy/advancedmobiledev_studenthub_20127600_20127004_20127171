import 'package:flutter/material.dart';
import 'dart:io';

/// The abstract base class for a conditional import feature.
abstract class BaseConditional implements Conditional {}

/// Create a [BrowserConditional].
///
/// Used from conditional imports, matches the definition in `conditional_stub.dart`.
/// Create a [IOConditional].
///
/// Used from conditional imports, matches the definition in `conditional_stub.dart`.

/// A conditional for anything but browser.
class IOConditional extends BaseConditional {
  /// Returns [NetworkImage] if URI starts with http
  /// otherwise uses IO to create File.
  @override
  ImageProvider getProvider(String uri, {Map<String, String>? headers}) {
    if (uri.startsWith('http') || uri.startsWith('blob')) {
      return NetworkImage(uri, headers: headers);
    } else {
      return FileImage(File(uri));
    }
  }

  BaseConditional createConditional() => IOConditional();
}

/// The abstract class for a conditional import feature.
abstract class Conditional {
  /// Creates a new platform appropriate conditional.
  ///
  /// Creates an `IOConditional` if `dart:io` is available and a `BrowserConditional` if
  /// `dart:html` is available, otherwise it will throw an unsupported error.
  factory Conditional() {
    return IOConditional();
  }

  /// Implemented in `browser_conditional.dart` and `io_conditional.dart`.

  /// Returns an appropriate platform ImageProvider for specified URI.
  ImageProvider getProvider(String uri, {Map<String, String>? headers});
}
