import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

/// Lien vers la politique de confidentialité publiée.
///
/// Google Play exige qu'elle soit accessible depuis l'appli elle-même, pas
/// seulement depuis la fiche du store : le lien figure sur l'écran de
/// connexion, avant tout envoi de données, et dans le profil.
class PrivacyPolicyLink extends StatelessWidget {
  final Color? color;

  const PrivacyPolicyLink({super.key, this.color});

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    var opened = false;
    try {
      opened = await launchUrl(
        AppConfig.privacyPolicyUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Aucun navigateur disponible : traité comme un échec ordinaire.
    }
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.privacyOpenError('${AppConfig.privacyPolicyUrl}'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _open(context),
      icon: Icon(Icons.privacy_tip_outlined, size: 18, color: color),
      label: Text(
        context.l10n.privacyPolicy,
        style: TextStyle(color: color),
      ),
    );
  }
}
