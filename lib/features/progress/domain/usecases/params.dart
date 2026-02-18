sealed class ProgressUseCaseParams {}

final class NoParams extends ProgressUseCaseParams {
  const NoParams();
}

final class GetProgressForGoalParams extends ProgressUseCaseParams {
  final String goalId;
  const GetProgressForGoalParams(this.goalId);
}

final class GetProgressByPeriodParams extends ProgressUseCaseParams {
  final DateTime startDate;
  final DateTime endDate;
  final String? categoryId;

  const GetProgressByPeriodParams({
    required this.startDate,
    required this.endDate,
    this.categoryId,
  });
}

final class GetProgressByTrackingPeriodParams extends ProgressUseCaseParams {
  final String trackingPeriod;
  final String? categoryId;

  const GetProgressByTrackingPeriodParams({
    required this.trackingPeriod,
    this.categoryId,
  });
}

final class GetProgressByIdParams extends ProgressUseCaseParams {
  final String progressId;
  const GetProgressByIdParams(this.progressId);
}

final class CreateProgressEntryParams extends ProgressUseCaseParams {
  final String goalId;
  final String categoryId;
  final double value;
  final String? unit;
  final String? note;
  final String trackingPeriod;
  final DateTime loggedDate;

  const CreateProgressEntryParams({
    required this.goalId,
    required this.categoryId,
    required this.value,
    this.unit,
    this.note,
    required this.trackingPeriod,
    required this.loggedDate,
  });
}

final class UpdateProgressEntryParams extends ProgressUseCaseParams {
  final String progressId;
  final double? value;
  final String? note;
  final String? unit;
  final DateTime? loggedDate;

  const UpdateProgressEntryParams({
    required this.progressId,
    this.value,
    this.note,
    this.unit,
    this.loggedDate,
  });
}

final class SoftDeleteProgressEntryParams extends ProgressUseCaseParams {
  final String progressId;
  const SoftDeleteProgressEntryParams(this.progressId);
}

final class ExportProgressCsvParams extends ProgressUseCaseParams {
  final String? categoryId;
  const ExportProgressCsvParams({this.categoryId});
}
