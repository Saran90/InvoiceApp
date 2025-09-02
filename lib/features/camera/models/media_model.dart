import 'dart:io';
import 'dart:typed_data';

class MediaModel {
  File file;
  String filePath;
  Uint8List blobImage;

  MediaModel.blob(this.file, this.filePath, this.blobImage);
}