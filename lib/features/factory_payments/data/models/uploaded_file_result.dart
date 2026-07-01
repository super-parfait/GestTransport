class UploadedFileResult {
  final String url;
  final String path;
  final String filename;

  const UploadedFileResult({
    required this.url,
    required this.path,
    required this.filename,
  });

  factory UploadedFileResult.fromJson(Map<String, dynamic> json) {
    return UploadedFileResult(
      url: (json['url'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      filename: (json['filename'] ?? '').toString(),
    );
  }
}
