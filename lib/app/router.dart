import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/koi/koi_list_screen.dart';
import '../features/plants/plant_list_screen.dart';
import '../features/pond/pond_form_screen.dart';
import '../features/profile/profile_screen.dart';
import '../models/koi.dart';
import '../models/pond.dart';
import '../screens/add_measurement_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/koi_details_screen.dart';
import '../screens/koi_form_screen.dart';
import '../screens/login_screen.dart';
import '../screens/measurements_screen.dart';
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
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        _PondEditRoute(initial: state.extra as Pond?),
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
                    builder: (context, state) => KoiDetailsScreen(
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/eau',
                builder: (context, state) => const MeasurementsScreen(),
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
            body: const Center(child: Text("Ce koï n'existe plus.")),
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
      return const Scaffold(body: Center(child: Text("Session expirée")));
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
            body: const Center(child: Text("Bassin introuvable.")),
          );
        }
        return PondFormScreen(pond: Pond.fromFirestore(snapshot.data!));
      },
    );
  }
}
