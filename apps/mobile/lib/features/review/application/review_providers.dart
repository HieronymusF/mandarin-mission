import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_core/learning_core.dart';

final reviewSchedulerProvider = Provider<ReviewScheduler>(
  (ref) => const ReviewScheduler(),
);
