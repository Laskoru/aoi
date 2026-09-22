import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pond_service.dart';

/// Expose l'état de session au routeur.
///
/// GoRouter réévalue ses redirections à chaque notification : c'est ce qui
/// ramène à l'écran de connexion après une déconnexion, et au bassin après
/// une connexion, sans qu'aucun écran n'ait à naviguer lui-même.
class AuthListenable extends ChangeNotifier {
  User? _user;
  bool _ready = false;
  late final StreamSubscription<User?> _subscription;

  AuthListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      _ready = true;
      if (user != null) {
        // Le bassin par défaut se crée en arrière-plan : son absence
        // momentanée n'empêche rien, les écrans savent attendre.
        PondService.ensureDefault(user.uid).catchError((Object e) {
          debugPrint('[AOI] Bassin par défaut non créé : $e');
        });
      }
      notifyListeners();
    });
  }

  /// Faux tant que Firebase n'a pas restauré la session : rediriger avant
  /// enverrait un utilisateur connecté vers l'écran de connexion.
  bool get isReady => _ready;
  User? get user => _user;
  bool get isSignedIn => _user != null;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
