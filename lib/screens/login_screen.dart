import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Ajouté pour utiliser debugPrint
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      debugPrint("=== 🔍 DÉBUT DE LA CONNEXION GOOGLE ===");

      // N'OUBLIE PAS DE REMETTRE TON CLIENT ID FIREBASE ICI
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '144445288274-m1tccaibpjgj3dtrq6hobeh9qocag4pr.apps.googleusercontent.com',
      );

      debugPrint("ÉTAPE 1 : Ouverture de la popup Google...");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("❌ Opération annulée : L'utilisateur a fermé la popup.");
        return;
      }
      debugPrint(
        "✅ ÉTAPE 1 RÉUSSIE : Utilisateur Google sélectionné (${googleUser.email})",
      );

      debugPrint("ÉTAPE 2 : Récupération des jetons de sécurité...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint(
        "✅ ÉTAPE 2 RÉUSSIE : Jetons récupérés (AccessToken existe: ${googleAuth.accessToken != null}, IdToken existe: ${googleAuth.idToken != null})",
      );

      debugPrint("ÉTAPE 3 : Création des identifiants pour Firebase...");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint("✅ ÉTAPE 3 RÉUSSIE : Identifiants créés.");

      debugPrint(
        "ÉTAPE 4 : Envoi des identifiants à Firebase Auth (Connexion)...",
      );
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      debugPrint(
        "✅ ÉTAPE 4 RÉUSSIE : Connecté à Firebase ! (UID: ${userCredential.user?.uid})",
      );

      if (context.mounted) {
        debugPrint("ÉTAPE 5 : Navigation vers le Dashboard.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Cette partie attrape spécifiquement les erreurs liées à Firebase
      debugPrint("🚨 ERREUR FIREBASE AUTH 🚨");
      debugPrint("-> Code d'erreur : ${e.code}");
      debugPrint("-> Message : ${e.message}");
      debugPrint("-> Détails complets : $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur Firebase : ${e.message}")),
        );
      }
    } catch (e, stacktrace) {
      // Cette partie attrape toutes les autres erreurs
      debugPrint("🚨 ERREUR GÉNÉRALE 🚨");
      debugPrint("-> Type d'erreur : ${e.runtimeType}");
      debugPrint("-> Message : $e");
      debugPrint("-> Stacktrace : $stacktrace");

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.waves, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "AOI KOI",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Se connecter avec Google"),
              onPressed: () => _signInWithGoogle(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
