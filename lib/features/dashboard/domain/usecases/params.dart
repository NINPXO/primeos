sealed class DashboardUseCaseParams {}

final class NoParams extends DashboardUseCaseParams {
  const NoParams();
}

final class ClearDateRangeParams extends DashboardUseCaseParams {
  final DateTime startDate;
  final DateTime endDate;

  const ClearDateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}

final class ExportAllDataParams extends DashboardUseCaseParams {
  const ExportAllDataParams();
}
