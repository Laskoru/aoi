import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Changement d'import : On utilise la bibliothèque web officielle pour le rendu du bouton
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
  bool _isInitializing = true;
  String _logMessage = "Initialisation du module de connexion...";

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _addLog(String message) {
    debugPrint("[AOI LOG] $message");
    if (mounted) {
      setState(() {
        _logMessage = "$_logMessage\n→ $message";
      });
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      _addLog("Étape A1 : Initialisation de GoogleSignIn.instance...");
      await GoogleSignIn.instance.initialize(
        clientId:
            '144445288274-m1tccaibpjgj3dtrq6hobeh9qocag4pr.apps.googleusercontent.com',
      );
      _addLog("Étape A2 : Singleton Google initialisé avec succès.");

      _addLog(
        "Étape A3 : Mise en place de l'écouteur d'événements (Stream)...",
      );
      _authSubscription = GoogleSignIn.instance.authenticationEvents.listen(
        (event) async {
          _addLog("Événement reçu du SDK Google : ${event.runtimeType}");
          if (event is GoogleSignInAuthenticationEventSignIn) {
            _addLog(
              "✅ Utilisateur détecté dans le flux ! Passage à Firebase...",
            );
            await _connectToFirebase(event.user);
          }
        },
        onError: (error) {
          _addLog("🚨 Erreur détectée dans le flux d'événements : $error");
        },
      );

      _addLog(
        "Étape A4 : Tentative de reconnexion transparente (Lightweight)...",
      );
      await GoogleSignIn.instance.attemptLightweightAuthentication();
      _addLog("Étape A5 : Phase d'initialisation terminée.");

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      _addLog("❌ ERREUR CRITIQUE D'INITIALISATION : $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _handleMobileSignInAction() async {
    try {
      _addLog("Action manuelle déclenchée (Mobile path).");
      _addLog("Vérification de la méthode d'authentification native...");

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser != null) {
        _addLog(
          "Utilisateur récupéré via authenticate() : ${googleUser.email}",
        );
        await _connectToFirebase(googleUser);
      } else {
        _addLog(
          "⚠️ authenticate() a renvoyé null (L'utilisateur a probablement annulé).",
        );
      }
    } catch (e) {
      _addLog("🚨 Échec lors de l'appel à authenticate() : $e");
    }
  }

  Future<void> _connectToFirebase(GoogleSignInAccount googleUser) async {
    try {
      _addLog("Échange : Récupération des données d'authentification...");
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      _addLog(
        "Échange : Demande d'accès aux autorisations complémentaires (Scopes)...",
      );
      final List<String> scopes = ['email', 'profile'];
      final authorizedClient = await googleUser.authorizationClient
          .authorizeScopes(scopes);
      final String? accessToken = authorizedClient.accessToken;

      _addLog(
        "Firebase : Préparation du credential (ID: ${idToken != null}, Access: ${accessToken != null})",
      );
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      _addLog(
        "Firebase : Tentative de connexion finale via signInWithCredential...",
      );
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      _addLog(
        "🏆 AUTHENTIFICATION REUSSIE ! UID unique : ${userCredential.user?.uid}",
      );

      if (mounted) {
        _addLog("Navigation : Redirection vers l'écran d'accueil.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      _addLog("🚨 ÉCHEC DE TRADUCTION FIREBASE : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de liaison Firebase : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.waves, size: 80, color: Colors.blue),
              const SizedBox(height: 15),
              const Text(
                "AOI KOI",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 40),

              if (_isInitializing)
                const CircularProgressIndicator()
              else if (GoogleSignIn.instance.supportsAuthenticate())
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone_android_rounded),
                  label: const Text("Se connecter (Mobile)"),
                  onPressed: _handleMobileSignInAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
              else if (kIsWeb)
                // Correction Erreur 1 : rendu de bouton simplifié via le package web_only
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: web.renderButton(),
                ),

              const SizedBox(height: 40),

              // Correction Erreur 2 : BoxConstraints utilisées correctement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logMessage,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
