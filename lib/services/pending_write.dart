/// Écritures Firestore vues depuis un écran.
///
/// Firestore n'achève une écriture qu'à l'accusé de réception du serveur.
/// Hors réseau, elle est pourtant déjà appliquée sur l'appareil et partira
/// d'elle-même au retour de la connexion : un écran qui l'attendrait
/// tournerait indéfiniment, au bord du bassin, là où le réseau manque.
extension PendingWrite on Future<Object?> {
  /// Attend la confirmation du serveur un court instant. Rend `true` si elle
  /// est venue, `false` si l'écriture attend encore le réseau : l'écran le
  /// dit alors avec `AppLocalizations.pendingWrite`. Un refus reçu dans le
  /// délai remonte comme une erreur ordinaire.
  Future<bool> confirmedWithin([
    Duration patience = const Duration(seconds: 5),
  ]) => then((_) => true).timeout(patience, onTimeout: () => false);
}

