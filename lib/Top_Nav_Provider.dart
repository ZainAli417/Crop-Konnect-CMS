import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

/// UserProvider fetches the current user's name from Firestore (by email)
/// and exposes the first two letters as `initials`. Wrap MainLayout in this provider.
class TopNavProvider extends ChangeNotifier {
  String _initials = '';
  String get initials => _initials;

  TopNavProvider() {
    _fetchInitials();
  }
  Future<void> _fetchInitials() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // Correct path: Job_Seekers > [uid] > { name: "John Doe" }
      final doc = await FirebaseFirestore.instance.collection('user_info').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['name'] is String) {
          final fullName = (data['name'] as String).trim();
          if (fullName.isNotEmpty) {
            final letters = fullName.replaceAll(' ', '');
            _initials = letters.substring(0, letters.length >= 2 ? 2 : 1).toUpperCase();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _initials = '';
      notifyListeners();
    }
  }
}
