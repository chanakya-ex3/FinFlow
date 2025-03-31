import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();


Future<void>  setKey(String key,String value) async {
  await storage.write(key: key, value: value);
}

Future<String?> getKey(String key) async{
  return await storage.read(key: key);
}

Future<void> deleteKeys() async{
  await storage.deleteAll();
}