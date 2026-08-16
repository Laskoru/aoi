/// Configuration de l'application.
///
/// Surchargeable au build sans toucher au code :
///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
class AppConfig {
  const AppConfig._();

  /// Client OAuth « web » du projet Firebase, utilisé par Google Sign-In sur
  /// **mobile natif uniquement** : c'est lui qui délivre l'idToken attendu par
  /// Firebase. Sur le web, rien de tout cela n'est nécessaire, Firebase Auth
  /// gère son propre client.
  ///
  /// Il doit appartenir au projet `aoi-koi`, dont le numéro est 144445288274 —
  /// un identifiant commençant par un autre numéro vient d'un autre projet
  /// Google Cloud et sera rejeté.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '144445288274-m1tccaibpjgj3dtrq6hobeh9qocag4pr.apps.googleusercontent.com',
  );
}
