import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../app/preferences.dart';
import '../../models/pond.dart';
import '../../services/auth_service.dart';
import '../../services/pond_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import 'delete_account_flow.dart';
import 'demo_data.dart';

/// Compte, affichage et bassin. La déconnexion est reléguée tout en bas,
/// isolée : une action destructrice ne se mélange pas à la navigation.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = PreferencesScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil", style: context.texts.headlineMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (user != null) _buildAccount(context, user),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: "Affichage", icon: Icons.palette_rounded),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thème", style: context.texts.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text("Système"),
                      icon: Icon(Icons.brightness_auto_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text("Clair"),
                      icon: Icon(Icons.light_mode_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text("Sombre"),
                      icon: Icon(Icons.dark_mode_rounded),
                    ),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (set) => prefs.setThemeMode(set.first),
                ),
                const Divider(height: AppSpacing.xl),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Animations réduites"),
                  subtitle: Text(
                    "Fige la scène du bassin et les transitions. Utile sur un appareil modeste.",
                    style: context.texts.bodyMedium,
                  ),
                  value: prefs.reducedMotion,
                  onChanged: prefs.setReducedMotion,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: "Mon bassin", icon: Icons.water_rounded),
          const SizedBox(height: AppSpacing.md),
          if (user != null) _buildPond(context, user.uid),

          // Outil de développement : jamais compilé dans la version du store.
          if (kDebugMode && user != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _DemoDataCard(uid: user.uid),
          ],

          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: AuthService.signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Se déconnecter"),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.pond.danger,
              side: BorderSide(
                color: context.pond.danger.withValues(alpha: 0.4),
              ),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: () => startAccountDeletion(context),
              icon: Icon(
                Icons.delete_forever_rounded,
                color: context.pond.danger,
                size: 18,
              ),
              label: Text(
                "Supprimer mon compte et mes données",
                style: TextStyle(color: context.pond.danger),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildAccount(BuildContext context, User user) {
    final photo = user.photoURL;
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.colors.primaryContainer,
            backgroundImage: photo != null ? NetworkImage(photo) : null,
            child: photo == null
                ? Icon(Icons.person_rounded, color: context.colors.primary)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? "Passionné",
                  style: context.texts.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.email != null)
                  Text(
                    user.email!,
                    style: context.texts.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPond(BuildContext context, String uid) {
    return StreamBuilder<Pond?>(
      stream: PondService.defaultOf(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        final pond = snapshot.data;
        if (pond == null) {
          return const AppCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final details = [
          if (pond.volumeLiters != null)
            "${pond.volumeLiters!.toStringAsFixed(0)} L",
          if (pond.depthCm != null)
            "${pond.depthCm!.toStringAsFixed(0)} cm de profondeur",
        ];

        return AppCard(
          onTap: () => context.push('/bassin/edit', extra: pond),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pond.name, style: context.texts.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      details.isEmpty
                          ? "Volume et profondeur à renseigner"
                          : details.join(" · "),
                      style: context.texts.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Remplit ou vide le compte avec des données de démonstration. Visible
/// seulement en mode développement.
class _DemoDataCard extends StatefulWidget {
  final String uid;

  const _DemoDataCard({required this.uid});

  @override
  State<_DemoDataCard> createState() => _DemoDataCardState();
}

class _DemoDataCardState extends State<_DemoDataCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(String) action, String done) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action(widget.uid);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Échec : $e")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Données de démonstration", style: context.texts.titleMedium),
          const SizedBox(height: 2),
          Text(
            "Mode développement uniquement. Les données ajoutées sont marquées "
            "et se retirent sans toucher aux vraies fiches.",
            style: context.texts.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_busy)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _run(DemoData.seed, "Données de démonstration ajoutées."),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text("Ajouter"),
                ),
                OutlinedButton.icon(
                  onPressed: () => _run(DemoData.clear, "Données de démonstration retirées."),
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text("Retirer"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
