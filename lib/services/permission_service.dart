import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
 /// Android 13+ -> Permission.audio (READ_MEDIA_AUDIO)
 /// Android 12-  -> Permission.storage (READ_EXTERNAL_STORAGE)
 Future<bool> requestMusicPermission() async {
  if (!Platform.isAndroid) return true;

  // Nếu đã có 1 trong 2 quyền thì OK
  if (await Permission.audio.isGranted || await Permission.storage.isGranted) {
   return true;
  }

  // Xin audio trước (Android 13+)
  final audio = await Permission.audio.request();
  if (audio.isGranted) return true;

  // Xin storage (Android 12-)
  final storage = await Permission.storage.request();
  return storage.isGranted;
 }

 Future<bool> isPermanentlyDenied() async {
  final a = await Permission.audio.status;
  final s = await Permission.storage.status;
  return a.isPermanentlyDenied || s.isPermanentlyDenied;
 }
}
