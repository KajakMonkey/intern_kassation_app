import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';

class DiscardReasonResponse {
  DiscardReasonResponse({required this.reasons, this.failure});
  final List<DiscardReason> reasons;
  final AppFailure? failure;

  @override
  String toString() {
    return 'DiscardReasonResponse(reasons: $reasons, failure: $failure)';
  }
}
