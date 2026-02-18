import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:primeos/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:primeos/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:primeos/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:primeos/core/providers/database_provider.dart';
import 'package:primeos/core/types/app_result.dart';
import 'package:primeos/features/dashboard/domain/usecases/params.dart';

/// Repository provider for dependency injection
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final database = ref.watch(databaseProvider).valueOrNull;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  final dataSource = DashboardLocalDatasource(database);
  return DashboardRepositoryImpl(dataSource);
});

/// Main dashboard AsyncNotifierProvider for state management
class DashboardNotifier extends AsyncNotifier<DashboardSummary> {
  late DashboardRepository _repository;

  @override
  Future<DashboardSummary> build() async {
    _repository = ref.read(dashboardRepositoryProvider);
    final result = await _repository.getDashboardSummary();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load dashboard summary',
    };
  }

  /// Manually refresh dashboard data from database
  Future<void> refreshDashboard() async {
    state = const AsyncValue.loading();
    final result = await _repository.getDashboardSummary();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }

  /// Clear entries within a date range and refresh dashboard
  Future<void> clearDateRange(DateTime start, DateTime end) async {
    try {
      final result = await _repository.clearDateRange(start, end);
      switch (result) {
        case AppSuccess():
          // Refresh dashboard after successful clear
          await refreshDashboard();
          break;
        case AppError(:final failure):
          throw Exception(_getFailureMessage(failure));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Export all data as CSV bytes
  Future<void> exportAllData() async {
    try {
      final result = await _repository.exportAllData();
      switch (result) {
        case AppSuccess():
          // Export successful, data can be handled in UI
          break;
        case AppError(:final failure):
          throw Exception(_getFailureMessage(failure));
      }
    } catch (e) {
      rethrow;
    }
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardSummary>(
  DashboardNotifier.new,
);
