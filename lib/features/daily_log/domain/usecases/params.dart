sealed class DailyLogUseCaseParams {}

final class NoParams extends DailyLogUseCaseParams {
  const NoParams();
}

final class GetEntriesByDateParams extends DailyLogUseCaseParams {
  final DateTime date;
  const GetEntriesByDateParams(this.date);
}

final class GetEntriesByDateRangeParams extends DailyLogUseCaseParams {
  final DateTime startDate;
  final DateTime endDate;
  final String? categoryId;

  const GetEntriesByDateRangeParams({
    required this.startDate,
    required this.endDate,
    this.categoryId,
  });
}

final class GetEntriesByCategoryParams extends DailyLogUseCaseParams {
  final String categoryId;
  const GetEntriesByCategoryParams(this.categoryId);
}

final class GetEntryByIdParams extends DailyLogUseCaseParams {
  final String entryId;
  const GetEntryByIdParams(this.entryId);
}

final class CreateLogEntryParams extends DailyLogUseCaseParams {
  final DateTime logDate;
  final String categoryId;
  final String title;
  final String? detail;
  final int? durationMins;
  final String? linkedType;
  final String? linkedId;

  const CreateLogEntryParams({
    required this.logDate,
    required this.categoryId,
    required this.title,
    this.detail,
    this.durationMins,
    this.linkedType,
    this.linkedId,
  });
}

final class UpdateLogEntryParams extends DailyLogUseCaseParams {
  final String entryId;
  final String? title;
  final String? detail;
  final int? durationMins;
  final DateTime? logDate;

  const UpdateLogEntryParams({
    required this.entryId,
    this.title,
    this.detail,
    this.durationMins,
    this.logDate,
  });
}

final class SoftDeleteLogEntryParams extends DailyLogUseCaseParams {
  final String entryId;
  const SoftDeleteLogEntryParams(this.entryId);
}

final class ExportLogsCsvParams extends DailyLogUseCaseParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportLogsCsvParams({
    this.startDate,
    this.endDate,
  });
}
