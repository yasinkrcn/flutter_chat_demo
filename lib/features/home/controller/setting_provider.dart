import '../../../core/_core_exports.dart';

class SettingProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  SettingProvider({
    required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  String? getPref(String key) {
    return prefs.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }
}
