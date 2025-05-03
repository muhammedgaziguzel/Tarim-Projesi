import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String email;
  final String? phone;
  final String? birthDate;
  final String? photoURL;

  UserProfile({
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.photoURL,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      birthDate: data['birthDate'],
      photoURL: data['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'photoURL': photoURL,
    };
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı durum değişikliklerini dinleme
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // E-posta/Şifre ile giriş
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Giriş hatası: ${e.code} - ${e.message}");
      return null;
    }
  }

  // Yeni kullanıcı kaydı
 Future<User?> createUserWithEmailPassword({
  required String email,
  required String password,
  required String name,
  String? phone,
  String? birthDate,
}) async {
  try {
    // 1. Kullanıcıyı Firebase Auth ile oluştur
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. UID'yi kontrol et (null ise hata fırlat)
    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw Exception("Kullanıcı UID'si alınamadı!");
    }

    // 3. Firestore'a veri yaz
    await _firestore.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "phone": phone ?? "", // Null ise boş string yaz
      "birthDate": birthDate ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    print("✅ Firestore'a veri yazıldı: users/$uid");
    return userCredential.user;

  } on FirebaseAuthException catch (e) {
    print("🔥 Auth Hatası: ${e.code} - ${e.message}");
    return null;
  } on FirebaseException catch (e) {
    print("🔥 Firestore Hatası: ${e.code} - ${e.message}");
    return null;
  } catch (e) {
    print("🔥 Genel Hata: $e");
    return null;
  }
}

  // Kullanıcı çıkışı
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Şifre sıfırlama
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Kullanıcı profil bilgilerini getir
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserProfile.fromFirestore(doc);
    } catch (e) {
      print("Profil getirme hatası: $e");
      return null;
    }
  }

  // Kullanıcı profilini güncelle
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? birthDate,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (birthDate != null) updateData['birthDate'] = birthDate;
      if (photoURL != null) updateData['photoURL'] = photoURL;

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      print("Profil güncelleme hatası: $e");
      rethrow;
    }
  }

  // Şifre değiştirme
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // Kullanıcı hesabını sil
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Önce Firestore'dan verileri sil
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Sonra auth'tan kullanıcıyı sil
      await user.delete();
    } catch (e) {
      print("Hesap silme hatası: $e");
      rethrow;
    }
  }
}