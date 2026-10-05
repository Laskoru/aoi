import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/account_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';

/// Suppression du compte et de toutes ses données, en trois temps :
/// confirmer l'intention, confirmer l'identité, puis effacer.
///
/// Les données partent avant le compte : une fois le compte supprimé, les
/// règles de sécurité ne reconnaissent plus personne pour les effacer.
Future<void> startAccountDeletion(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _ConfirmDeletionDialog(),
  );
  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);

  // 1. Identité : Firebase n'accepte de supprimer qu'un compte connecté
  //    depuis moins de cinq minutes.
  try {
    await AuthService.reauthenticate();
  } on FirebaseAuthException catch (e) {
    if (_isCancellation(e.code)) return;
    messenger.showSnackBar(SnackBar(content: Text(_identityMessage(e.code))));
    return;
  } catch (e) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          "La vérification d'identité a échoué. Rien n'a été supprimé.",
        ),
      ),
    );
    return;
  }

  // 2. Les données.
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeletionProgressDialog(),
  );
  try {
    // Lectures sur le serveur : sans réseau, l'échec est immédiat. Le délai
    // couvre une connexion qui tomberait en cours de route, pour que la
    // fenêtre de progression ne reste jamais bloquée.
    await AccountService.deleteAllData(user.uid)
        .timeout(const Duration(minutes: 3));
  } catch (e) {
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          e is TimeoutException ||
                  (e is FirebaseException && e.code == 'unavailable')
              ? "Connexion à Internet requise : la suppression n'a pas pu "
                    "aboutir. Relancez-la une fois connecté, elle reprendra là "
                    "où elle s'est arrêtée."
              : "La suppression s'est interrompue ($e). Relancez-la : elle "
                    "reprendra là où elle s'est arrêtée.",
        ),
      ),
    );
    return;
  }
  navigator.pop();

  // 3. Le compte. Sa disparition renvoie seule à l'écran de connexion.
  try {
    try {
      await AuthService.deleteCurrentUser();
    } on FirebaseAuthException catch (e) {
      // Une suppression très longue a pu dépasser les cinq minutes de
      // Firebase : une nouvelle confirmation d'identité, et on réessaie.
      if (e.code != 'requires-recent-login') rethrow;
      await AuthService.reauthenticate();
      await AuthService.deleteCurrentUser();
    }
    messenger.showSnackBar(
      const SnackBar(
        content: Text("Votre compte et toutes vos données ont été supprimés."),
      ),
    );
  } catch (e) {
    final code = e is FirebaseAuthException ? e.code : '$e';
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isCancellation(code)
              ? "Vos données sont effacées, mais le compte n'a pas pu l'être "
                    "sans confirmation. Relancez la suppression."
              : "Vos données sont effacées, mais le compte n'a pas pu l'être "
                    "($code). Relancez la suppression.",
        ),
      ),
    );
  }
}

bool _isCancellation(String code) {
  return code == 'popup-closed-by-user' ||
      code == 'cancelled-popup-request' ||
      code == 'user-cancelled';
}

String _identityMessage(String code) {
  return switch (code) {
    'user-mismatch' =>
      "Ce n'est pas le compte Google connecté. Choisissez le même compte. "
          "Rien n'a été supprimé.",
    'popup-blocked' || 'operation-not-supported-in-this-environment' =>
      "La fenêtre Google n'a pas pu s'ouvrir. Déconnectez-vous, "
          "reconnectez-vous, puis relancez la suppression dans les cinq minutes.",
    'network-request-failed' =>
      "Pas de connexion à Internet. Rien n'a été supprimé.",
    _ => "La vérification d'identité a échoué ($code). Rien n'a été supprimé.",
  };
}

/// Confirmation explicite : taper un mot, pour qu'un effacement total ne
/// puisse pas partir d'un geste distrait.
class _ConfirmDeletionDialog extends StatefulWidget {
  const _ConfirmDeletionDialog();

  @override
  State<_ConfirmDeletionDialog> createState() => _ConfirmDeletionDialogState();
}

class _ConfirmDeletionDialogState extends State<_ConfirmDeletionDialog> {
  static const _word = 'SUPPRIMER';
  final _controller = TextEditingController();

  bool get _armed => _controller.text.trim().toUpperCase() == _word;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danger = context.pond.danger;

    return AlertDialog(
      icon: Icon(Icons.delete_forever_rounded, color: danger, size: 32),
      title: const Text("Supprimer votre compte ?"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tout sera effacé définitivement : vos koï et leurs photos, "
              "leur croissance, vos relevés d'eau, vos plantes, vos autres "
              "poissons et votre bassin. Rien ne pourra être récupéré.",
              style: context.texts.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Google vous demandera peut-être de confirmer votre identité.",
              style: context.texts.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: "Tapez $_word pour confirmer",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _armed ? () => Navigator.pop(context, true) : null,
          style: TextButton.styleFrom(foregroundColor: danger),
          child: const Text('Supprimer définitivement'),
        ),
      ],
    );
  }
}

class _DeletionProgressDialog extends StatelessWidget {
  const _DeletionProgressDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                "Suppression de vos données…",
                style: context.texts.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
