import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProfileImageStore {
  static final ValueNotifier<Uint8List?> imageBytes =
  ValueNotifier<Uint8List?>(null);
}