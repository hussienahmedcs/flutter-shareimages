import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info/device_info.dart';

class DataRepository {
  // 1
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  final FirebaseStorage fsStorage = FirebaseStorage.instance;

  String createId() {
    return const Uuid().v1();
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.androidId;
  }

// 2
// Stream<QuerySnapshot> getCatsStream() {
//   return collection.snapshots();
// }

// // 3
// Future<DocumentReference> addPet(Pet pet) {
//   return collection.add(pet.toJson());
// }
//
// // 4
// void updatePet(Pet pet) async {
//   await collection.doc(pet.referenceId).update(pet.toJson());
// }
//
// // 5
// void deletePet(Pet pet) async {
//   await collection.doc(pet.referenceId).delete();
// }
}
