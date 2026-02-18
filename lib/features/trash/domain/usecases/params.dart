sealed class TrashUseCaseParams {}

final class NoParams extends TrashUseCaseParams {
  const NoParams();
}

final class GetTrashByTypeParams extends TrashUseCaseParams {
  final String type;

  const GetTrashByTypeParams(this.type);
}

final class RestoreItemParams extends TrashUseCaseParams {
  final String itemId;
  final String itemType;

  const RestoreItemParams({
    required this.itemId,
    required this.itemType,
  });
}

final class HardDeleteItemParams extends TrashUseCaseParams {
  final String itemId;
  final String itemType;

  const HardDeleteItemParams({
    required this.itemId,
    required this.itemType,
  });
}

final class EmptyTrashParams extends TrashUseCaseParams {
  const EmptyTrashParams();
}
