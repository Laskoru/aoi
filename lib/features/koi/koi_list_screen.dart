import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../models/koi.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../widgets/koi_card.dart';

/// La collection de koï, en grille.
class KoiListScreen extends StatelessWidget {
  const KoiListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text(context.l10n.sessionExpired)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              context.l10n.koiListTitle,
              style: context.texts.headlineMedium,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, size: 28),
                color: context.colors.secondary,
                tooltip: context.l10n.koiFormTitleAdd,
                onPressed: () => context.push('/koi/new'),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kois')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: ErrorState(error: snapshot.error),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.waves_rounded,
                      title: context.l10n.koiListEmptyTitle,
                      message: context.l10n.koiListEmptyMessage,
                      actionLabel: context.l10n.koiFormTitleAdd,
                      onAction: () => context.push('/koi/new'),
                    ),
                  );
                }

                final kois = docs.map(Koi.fromFirestore).toList();
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => StaggerIn(
                      key: ValueKey(kois[index].id),
                      index: index,
                      child: KoiCard(koi: kois[index]),
                    ),
                    childCount: kois.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
