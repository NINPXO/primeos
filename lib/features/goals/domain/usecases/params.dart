sealed class GoalsUseCaseParams {}

final class NoParams extends GoalsUseCaseParams {
  const NoParams();
}

final class GetGoalsByCategoryParams extends GoalsUseCaseParams {
  final String categoryId;
  const GetGoalsByCategoryParams(this.categoryId);
}

final class GetGoalByIdParams extends GoalsUseCaseParams {
  final String goalId;
  const GetGoalByIdParams(this.goalId);
}

final class CreateGoalParams extends GoalsUseCaseParams {
  final String categoryId;
  final String title;
  final String? description;
  final String status;
  final double? targetValue;
  final String? targetUnit;
  final DateTime? targetDate;

  const CreateGoalParams({
    required this.categoryId,
    required this.title,
    this.description,
    required this.status,
    this.targetValue,
    this.targetUnit,
    this.targetDate,
  });
}

final class UpdateGoalParams extends GoalsUseCaseParams {
  final String goalId;
  final String? title;
  final String? description;
  final String? status;
  final double? targetValue;
  final String? targetUnit;
  final DateTime? targetDate;

  const UpdateGoalParams({
    required this.goalId,
    this.title,
    this.description,
    this.status,
    this.targetValue,
    this.targetUnit,
    this.targetDate,
  });
}

final class SoftDeleteGoalParams extends GoalsUseCaseParams {
  final String goalId;
  const SoftDeleteGoalParams(this.goalId);
}

final class CreateGoalCategoryParams extends GoalsUseCaseParams {
  final String name;
  final bool isSystem;
  final String? colorHex;

  const CreateGoalCategoryParams({
    required this.name,
    this.isSystem = false,
    this.colorHex,
  });
}

final class ExportGoalsCsvParams extends GoalsUseCaseParams {
  final String? categoryId;
  const ExportGoalsCsvParams({this.categoryId});
}
