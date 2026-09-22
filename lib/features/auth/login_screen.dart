import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithGoogle();
      // Pas de navigation ici : l'AuthGate de main.dart écoute
      // authStateChanges et bascule seul sur le tableau de bord.
    } on FirebaseAuthException catch (e) {
      debugPrint('[AOI] Échec de connexion Firebase : ${e.code} — ${e.message}');
      // Refermer la fenêtre Google est un choix de l'utilisateur, pas une
      // panne : inutile de lui afficher une erreur.
      if (!_isUserCancellation(e.code)) {
        setState(() => _errorMessage = _messageFor(e.code));
      }
    } catch (e) {
      debugPrint('[AOI] Échec de connexion : $e');
      setState(() => _errorMessage = "La connexion a échoué. Réessayez.");
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  bool _isUserCancellation(String code) {
    return code == 'popup-closed-by-user' ||
        code == 'cancelled-popup-request' ||
        code == 'user-cancelled';
  }

  String _messageFor(String code) {
    return switch (code) {
      'network-request-failed' =>
        "Connexion impossible : vérifiez votre accès à Internet.",
      'account-exists-with-different-credential' =>
        "Un compte existe déjà avec cette adresse, via un autre mode de connexion.",
      'unauthorized-domain' =>
        "Ce domaine n'est pas autorisé dans la console Firebase.",
      _ => "La connexion a échoué. Réessayez.",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'écran d'accueil plonge dans l'eau du bassin : c'est le seul endroit
      // de l'appli qui occupe tout l'écran d'une seule couleur.
      body: Container(
        decoration: pondGradient(context),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEmblem(),
                    const SizedBox(height: AppSpacing.lg),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: "AOI "),
                          TextSpan(
                            text: "KOI",
                            style: TextStyle(color: AppPalette.hiBright),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Le carnet de votre bassin",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 56),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: _isSigningIn
                            ? const SizedBox.shrink()
                            : const Icon(Icons.login_rounded, size: 20),
                        label: _isSigningIn
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppPalette.mizuDeep,
                                ),
                              )
                            : const Text("Se connecter avec Google"),
                        onPressed: _isSigningIn ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppPalette.mizuDeep,
                          disabledBackgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.field),
                          ),
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildErrorBanner(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Un disque clair traversé d'une tache `hi` : la marque de l'appli, reprise
  /// de la plaque rouge d'un kohaku.
  Widget _buildEmblem() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
      ),
      child: const Center(child: KoiEmblem(size: 50, color: Colors.white)),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppPalette.dangerDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppPalette.dangerDark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
