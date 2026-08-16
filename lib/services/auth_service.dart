import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config.dart';

/// Connexion Google, par le chemin adapté à chaque plateforme.
///
/// Sur le web, on passe par Firebase Auth directement. Le détour par le paquet
/// `google_sign_in` imposait d'enregistrer à la main chaque origine JavaScript
/// dans Google Cloud Console, et ouvrait une seconde fenêtre pour demander des
/// autorisations dont Firebase n'a pas besoin — deux sources de panne évitées
/// ici. Firebase mène le flux sur son propre domaine, autorisé d'office.
///
/// Sur mobile natif, `google_sign_in` reste le bon outil : il s'appuie sur le
/// compte Google déjà présent sur l'appareil.
class AuthService {
  const AuthService._();

  /// Ouvre la connexion Google et ouvre une session Firebase.
  ///
  /// Ne renvoie rien : c'est `authStateChanges` qui prévient l'interface, via
  /// l'`AuthGate` de `main.dart`.
  static Future<void> signInWithGoogle() {
    return kIsWeb ? _signInOnWeb() : _signInOnMobile();
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  // --- Web ---

  static Future<void> _signInOnWeb() async {
    final provider = GoogleAuthProvider();

    try {
      await FirebaseAuth.instance.signInWithPopup(provider);
    } on FirebaseAuthException catch (e) {
      // Une application installée sur l'écran d'accueil d'un iPhone ne peut
      // pas ouvrir de popup : on repasse alors par une redirection de page
      // entière, que Firebase reprend au retour.
      if (_popupUnavailable(e.code)) {
        debugPrint('[AOI] Popup indisponible (${e.code}), bascule en redirection.');
        await FirebaseAuth.instance.signInWithRedirect(provider);
        return;
      }
      rethrow;
    }
  }

  static bool _popupUnavailable(String code) {
    return code == 'popup-blocked' ||
        code == 'operation-not-supported-in-this-environment' ||
        code == 'web-storage-unsupported';
  }

  // --- Mobile natif ---

  static bool _googleSignInReady = false;

  static Future<void> _signInOnMobile() async {
    if (!_googleSignInReady) {
      // Sur Android, l'identifiant du client Android est lu depuis
      // google-services.json ; `serverClientId` désigne le client web, seul
      // capable de délivrer l'idToken que Firebase attend.
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConfig.googleServerClientId,
      );
      _googleSignInReady = true;
    }

    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: "Google n'a pas fourni de jeton d'identité.",
      );
    }

    // Firebase se contente de l'idToken : pas besoin de demander en plus un
    // jeton d'accès, ce qui déclencherait une autorisation supplémentaire.
    await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }
}
