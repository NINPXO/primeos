import '../../../core/types/app_result.dart';
import '../../progress/domain/entities/progress_entry.dart';
import '../../progress/domain/repositories/progress_repository.dart';
import 'params.dart';

abstract interface class GetActiveProgress {
  Future<AppResult<List<ProgressEntry>>> call(NoParams params);
}

final class GetActiveProgressImpl implements GetActiveProgress {
  final ProgressRepository _progressRepository;

  GetActiveProgressImpl(this._progressRepository);

  @override
  Future<AppResult<List<ProgressEntry>>> call(NoParams params) {
    // Fetch progress entries from the last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return _progressRepository.getProgressByPeriod(
      sevenDaysAgo,
      now,
      null, // No specific category filter
    );
  }
}
