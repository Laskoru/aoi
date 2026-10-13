import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_widgets.dart';
import '../../widgets/privacy_policy_link.dart';

/// Les services de connexion proposés.
enum _Provider { apple, google }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Le service dont la fenêtre est ouverte, null au repos.
  _Provider? _signingIn;
  String? _errorMessage;

  Future<void> _signIn(_Provider provider) async {
    setState(() {
      _signingIn = provider;
      _errorMessage = null;
    });

    try {
      await switch (provider) {
        _Provider.apple => AuthService.signInWithApple(),
        _Provider.google => AuthService.signInWithGoogle(),
      };
      // Pas de navigation ici : l'AuthGate de main.dart écoute
      // authStateChanges et bascule seul sur le tableau de bord.
    } on FirebaseAuthException catch (e) {
      debugPrint('[AOI] Échec de connexion Firebase : ${e.code} — ${e.message}');
      // Refermer la fenêtre Google ou Apple est un choix de l'utilisateur,
      // pas une panne : inutile de lui afficher une erreur.
      if (!_isUserCancellation(e.code)) {
        setState(() => _errorMessage = _messageFor(e.code));
      }
    } catch (e) {
      debugPrint('[AOI] Échec de connexion : $e');
      setState(() => _errorMessage = "La connexion a échoué. Réessayez.");
    } finally {
      if (mounted) setState(() => _signingIn = null);
    }
  }

  bool _isUserCancellation(String code) {
    return code == 'popup-closed-by-user' ||
        code == 'cancelled-popup-request' ||
        code == 'user-cancelled' ||
        code == 'canceled';
  }

  String _messageFor(String code) {
    return switch (code) {
      'network-request-failed' =>
        "Connexion impossible : vérifiez votre accès à Internet.",
      'account-exists-with-different-credential' =>
        "Un compte existe déjà avec cette adresse : connectez-vous comme la "
            "première fois, avec Google ou avec Apple.",
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

                    // Apple d'abord, aussi visible que Google : c'est ce
                    // que l'App Store attend. Son style blanc, logo et texte
                    // noirs, est celui qu'il prévoit pour les fonds sombres.
                    if (AuthService.offersApple) ...[
                      _buildSignInButton(
                        provider: _Provider.apple,
                        icon: Icons.apple,
                        label: "Se connecter avec Apple",
                        color: Colors.black,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _buildSignInButton(
                      provider: _Provider.google,
                      icon: Icons.login_rounded,
                      label: "Se connecter avec Google",
                      color: AppPalette.mizuDeep,
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildErrorBanner(),
                    ],

                    const SizedBox(height: AppSpacing.lg),
                    PrivacyPolicyLink(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required _Provider provider,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final busy = _signingIn == provider;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: busy ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Text(label),
        onPressed: _signingIn != null ? null : () => _signIn(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          disabledBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      ),
    );
  }

  /// Un disque clair autour du koï kohaku de l'icône : la marque de l'appli.
  Widget _buildEmblem() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
      ),
      child: const Center(child: KoiEmblem(size: 64, color: Colors.white)),
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
