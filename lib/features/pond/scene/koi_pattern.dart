import 'dart:ui';

/// Comment se répartissent les couleurs sur le corps.
enum KoiPatternKind {
  /// Une seule couleur : chagoi, ogon, platinum.
  solid,

  /// Grandes plaques d'accent sur le fond : kohaku.
  patches,

  /// Plaques d'accent et points de la seconde couleur : sanke, showa.
  patchesAndSpots,

  /// Points seulement : bekko.
  spots,

  /// Un seul disque rouge sur la tête : tancho.
  tancho,

  /// Réseau d'écailles cerclées sur le dos : asagi, shusui, kujaku.
  reticulated,

  /// Larges bandes de la seconde couleur : utsuri.
  bands,
}

/// Les couleurs et le motif à peindre pour une variété.
///
/// On ne cherche pas à reproduire un koï en particulier — impossible depuis
/// un nom — mais à ce qu'un kohaku se distingue d'un showa au premier coup
/// d'œil, comme dans un bassin.
class KoiPattern {
  final Color base;
  final Color? accent;
  final Color? secondary;
  final KoiPatternKind kind;

  /// Reflet clair le long du dos : ogon, platinum, kujaku.
  final bool metallic;

  const KoiPattern({
    required this.base,
    required this.kind,
    this.accent,
    this.secondary,
    this.metallic = false,
  });

  // Palette des nishikigoi, en clair : shiroji, hi, sumi…
  static const Color shiroji = Color(0xFFF5F1EA);
  static const Color hi = Color(0xFFD4502E);
  static const Color sumi = Color(0xFF1C1B1A);
  static const Color chagoi = Color(0xFF7A6A3C);
  static const Color ogon = Color(0xFFE8B93A);
  static const Color platinum = Color(0xFFDCDDE0);
  static const Color asagi = Color(0xFF6E8BA3);
  static const Color belly = Color(0xFFFBF4E8);

  /// Motif déduit du nom de variété, insensible à la casse et aux accents
  /// courants. Un nom inconnu donne un koï orangé à ventre blanc : le koï
  /// « générique » que tout le monde reconnaît.
  static KoiPattern fromVariety(String variety) {
    final v = variety.toLowerCase().trim();
    bool has(String word) => v.contains(word);

    if (has('tancho')) {
      return const KoiPattern(base: shiroji, accent: hi, kind: KoiPatternKind.tancho);
    }
    if (has('kohaku')) {
      return const KoiPattern(base: shiroji, accent: hi, kind: KoiPatternKind.patches);
    }
    if (has('sanke') || has('sanshoku')) {
      return const KoiPattern(
        base: shiroji,
        accent: hi,
        secondary: sumi,
        kind: KoiPatternKind.patchesAndSpots,
      );
    }
    if (has('showa')) {
      return const KoiPattern(
        base: sumi,
        accent: hi,
        secondary: shiroji,
        kind: KoiPatternKind.patchesAndSpots,
      );
    }
    if (has('utsuri')) {
      return const KoiPattern(base: shiroji, accent: sumi, kind: KoiPatternKind.bands);
    }
    if (has('bekko')) {
      return const KoiPattern(base: shiroji, accent: sumi, kind: KoiPatternKind.spots);
    }
    if (has('kujaku')) {
      return const KoiPattern(
        base: platinum,
        accent: hi,
        secondary: asagi,
        kind: KoiPatternKind.reticulated,
        metallic: true,
      );
    }
    if (has('asagi') || has('shusui')) {
      return const KoiPattern(
        base: asagi,
        accent: hi,
        secondary: shiroji,
        kind: KoiPatternKind.reticulated,
      );
    }
    if (has('chagoi')) {
      return const KoiPattern(base: chagoi, kind: KoiPatternKind.solid);
    }
    if (has('ogon') || has('yamabuki')) {
      return const KoiPattern(base: ogon, kind: KoiPatternKind.solid, metallic: true);
    }
    if (has('platinum') || has('purachina')) {
      return const KoiPattern(base: platinum, kind: KoiPatternKind.solid, metallic: true);
    }
    return const KoiPattern(base: hi, secondary: belly, kind: KoiPatternKind.solid);
  }
}
