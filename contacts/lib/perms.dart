import 'package:permission_handler/permission_handler.dart';

export 'package:permission_handler/permission_handler.dart' show PermissionStatus;

Future<Map<PermissionGroup, PermissionStatus>> requestPerm(List<PermissionGroup> perms) async {
  return PermissionHandler().requestPermissions(perms);
}

Future<PermissionStatus> requestExtStoragePerm() async {
  final Map<PermissionGroup, PermissionStatus> map = await requestPerm([PermissionGroup.storage]);
  assert(map.length == 1);
  final PermissionStatus perm = map[PermissionGroup.storage];
  return perm;
}
