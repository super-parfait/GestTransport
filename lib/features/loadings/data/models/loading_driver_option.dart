import '../../../../core/utils/uuid_utils.dart';

class LoadingDriverOption {
  final String id;
  final String name;
  final String phone;
  final String truckId;
  final String truckRegistration;

  const LoadingDriverOption({
    required this.id,
    required this.name,
    required this.phone,
    required this.truckId,
    required this.truckRegistration,
  });

  bool get hasUsableId => isUuid(id);
}
