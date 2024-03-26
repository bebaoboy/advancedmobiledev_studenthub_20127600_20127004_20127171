// ignore_for_file: provide_deprecation_message

import 'package:universal_io/io.dart';

import 'connectycube_core.dart';
import 'src/storage/models/cube_file.dart';
import 'src/storage/query/storage_queries.dart';

export 'connectycube_core.dart';

export 'src/storage/models/cube_file.dart';
export 'src/storage/query/storage_queries.dart';
export 'src/storage/utils/storage_utils.dart';

/// Uploads the [File] to the Connectycube storage.
/// Recommended file size should not exceed 100mb
///
/// [file] - the file which you want to upload
/// [isPublic] - will the file with public access or with private, default value `false`
/// [mimeType] - the `content type` of uploaded file,
///              if not specified SDK will try to generate it from the file extension
/// [onProgress] - the callback which fires when uploading progress changes
Future<CubeFile> uploadFile(File file,
    {bool? isPublic, String? mimeType, Function(int progress)? onProgress}) {
  return UploadFileQuery(file,
          isPublic: isPublic, mimeType: mimeType, onProgress: onProgress)
      .perform();
}

/// Uploads the raw file data to the Connectycube storage.
/// The same as [uploadFile] but receives raw data of file in bytes.
/// It is helpful for the Web platform where we don't have access to the storage.
///
/// [bytes] - the raw data of the file
/// [name] - the file's name
Future<CubeFile> uploadRawFile(List<int> bytes, String name,
    {bool? isPublic, String? mimeType, Function(int progress)? onProgress}) {
  return UploadFileQuery.fromBytes(bytes, name,
          isPublic: isPublic, mimeType: mimeType, onProgress: onProgress)
      .perform();
}

/// Returns the [CubeFile] which was uploaded before
///
/// [fileId] - the `id` of [CubeFile] which you want to get
Future<CubeFile> getCubeFile(int fileId) {
  return GetBlobByIdQuery(fileId).perform();
}

/// Returns the list of files created by the current user. The list of available
/// parameters provided by link https://developers.connectycube.com/server/storage?id=parameters-3
@deprecated
Future<PagedResult<CubeFile>> getCubeFiles([Map<String, dynamic>? params]) {
  return GetBlobsQuery(params).perform();
}

/// Updates one or more parameters of the file. Available for updating fields: `name` and `contentType`.
///
/// [file] - the instance of [CubeFile] with updated fields. Should contain the `id` of original file.
/// [isNew] - set to `true` if file content should be changed
@deprecated
Future<CubeFile> updateCubeFile(CubeFile file, [bool? isNew = false]) {
  return UpdateBlobQuery(file, isNew).perform();
}

/// Deletes the file with [fileId].
Future<void> deleteFile(int fileId) {
  return DeleteBlobByIdQuery(fileId).perform();
}
