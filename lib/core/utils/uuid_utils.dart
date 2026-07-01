final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{12}$',
);

bool isUuid(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isNotEmpty && _uuidPattern.hasMatch(normalized);
}
