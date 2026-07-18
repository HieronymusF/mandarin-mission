import 'package:flutter/material.dart';

void showLessonAudioUnavailable(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Course audio will be added in the audio module.'),
    ),
  );
}
