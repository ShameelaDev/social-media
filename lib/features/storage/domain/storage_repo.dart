import 'dart:typed_data';

abstract class StorageRepo {
  Future<String?> uploadProfileImagePhone(String path,String fileName);
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes,String fileName);
  Future<String?> uploadPostImagePhone(String path,String fileName);
  Future<String?> uploadPostImageWeb(Uint8List fileBytes,String fileName);



}