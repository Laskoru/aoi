import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/koi/koi_list_screen.dart';
import '../features/plants/plant_detail_screen.dart';
import '../features/plants/plant_form_screen.dart';
import '../features/plants/plant_list_screen.dart';
import '../features/pond/fish_group_form_screen.dart';
import '../features/pond/pond_form_screen.dart';
import '../features/pond/pond_screen.dart';
import '../features/water/water_screen.dart';
import '../features/profile/profile_screen.dart';
import '../models/fish_group.dart';
import '../models/koi.dart';
import '../models/plant.dart';
import '../models/pond.dart';
import '../features/water/add_measurement_screen.dart';
import '../features/koi/koi_detail_screen.dart';
import '../features/koi/koi_form_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/water/measurements_screen.dart';
import '../theme/app_widgets.dart';
import 'app_shell.dart';
import 'auth_listenable.dart';

/// Toutes les routes de l'application.
///
/// Chaque écran a une URL : c'est ce qui rend les fiches partageables et le
/// bouton retour du navigateur fiable, la version web étant celle qu'on
/// teste sur téléphone.
GoRouter buildRouter(AuthListenable auth) {
  return GoRouter(
    initialLocation: '/bassin',
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;
      // Tant que Firebase n'a pas restauré la session, on n'aiguille pas :
      // rediriger un utilisateur connecté vers /login serait faux.
      if (!auth.isReady) return location == '/splash' ? null : '/splash';
      if (!auth.isSignedIn) return location == '/login' ? null : '/login';
      if (location == '/login' || location == '/splash') return '/bassin';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bassin',
                builder: (context, state) => const PondScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        _PondEditRoute(initial: state.extra as Pond?),
                  ),
                  GoRoute(
                    path: 'poissons/new',
                    builder: (context, state) => const FishGroupFormScreen(),
                  ),
                  GoRoute(
                    path: 'poissons/:id/edit',
                    builder: (context, state) => _FishGroupEditRoute(
                      groupId: state.pathParameters['id']!,
                      initial: state.extra as FishGroup?,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/koi',
                builder: (context, state) => const KoiListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const KoiFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => KoiDetailScreen(
                      koiId: state.pathParameters['id']!,
                      initialKoi: state.extra as Koi?,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => _KoiEditRoute(
                          koiId: state.pathParameters['id']!,
                          initial: state.extra as Koi?,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plantes',
                builder: (context, state) => const PlantListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const PlantFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => PlantDetailScreen(
                      plantId: state.pathParameters['id']!,
                      initialPlant: state.extra as Plant?,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => _PlantEditRoute(
                          plantId: state.pathParameters['id']!,
                          initial: state.extra as Plant?,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/eau',
                builder: (context, state) => const WaterScreen(),
                routes: [
                  GoRoute(
                    path: 'historique',
                    builder: (context, state) => const MeasurementsScreen(),
                  ),
                  GoRoute(
                    path: 'nouvelle',
                    builder: (context, state) => const AddMeasurementScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profil',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Ouvre le formulaire d'un koï. Depuis une carte, la fiche arrive en
/// `extra` ; depuis une URL tapée à la main, on la charge d'abord.
class _KoiEditRoute extends StatelessWidget {
  final String koiId;
  final Koi? initial;

  const _KoiEditRoute({required this.koiId, this.initial});

  @override
  Widget build(BuildContext context) {
    if (initial != null) return KoiFormScreen(existing: initial);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('kois').doc(koiId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorState(error: snapshot.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.koiNotFound)),
          );
        }
        return KoiFormScreen(existing: Koi.fromFirestore(snapshot.data!));
      },
    );
  }
}

/// Même principe pour le bassin.
class _PondEditRoute extends StatelessWidget {
  final Pond? initial;

  const _PondEditRoute({this.initial});

  @override
  Widget build(BuildContext context) {
    if (initial != null) return PondFormScreen(pond: initial!);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(body: Center(child: Text(context.l10n.sessionExpired)));
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('ponds')
          .doc(Pond.defaultIdFor(uid))
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.pondNotFound)),
          );
        }
        return PondFormScreen(pond: Pond.fromFirestore(snapshot.data!));
      },
    );
  }
}

/// Même principe pour une plante.
class _PlantEditRoute extends StatelessWidget {
  final String plantId;
  final Plant? initial;

  const _PlantEditRoute({required this.plantId, this.initial});

  @override
  Widget build(BuildContext context) {
    if (initial != null) return PlantFormScreen(existing: initial);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('plants').doc(plantId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorState(error: snapshot.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.plantNotFound)),
          );
        }
        return PlantFormScreen(existing: Plant.fromFirestore(snapshot.data!));
      },
    );
  }
}

/// Même principe pour un groupe de poissons.
class _FishGroupEditRoute extends StatelessWidget {
  final String groupId;
  final FishGroup? initial;

  const _FishGroupEditRoute({required this.groupId, this.initial});

  @override
  Widget build(BuildContext context) {
    if (initial != null) return FishGroupFormScreen(existing: initial);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('fish_groups')
          .doc(groupId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorState(error: snapshot.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.fishNotFound)),
          );
        }
        return FishGroupFormScreen(
          existing: FishGroup.fromFirestore(snapshot.data!),
        );
      },
    );
  }
}
