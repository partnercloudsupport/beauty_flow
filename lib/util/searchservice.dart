import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  searchByName() {
    return Firestore.instance
        .collection('users')
        .getDocuments();
  }
}
