import 'package:flutter_chat_demo/core/_core_exports.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(
    String pathCollection,
    int limit,
  ) {
    return firebaseFirestore.collection(pathCollection).limit(limit).snapshots();
  }
}
