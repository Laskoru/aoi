import 'package:aoi/services/photo_store.dart';
import 'package:aoi/widgets/photo_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('références', () {
    test('une photo Firestore se reconnaît à son préfixe', () {
      final ref = PhotoStore.refFor('abc123');
      expect(ref, 'photo:abc123');
      expect(PhotoStore.isStored(ref), isTrue);
      expect(PhotoStore.idOf(ref), 'abc123');
    });

    test('les anciennes adresses web restent des adresses web', () {
      const url = 'https://firebasestorage.googleapis.com/v0/b/x/o/y.jpg';
      expect(PhotoStore.isStored(url), isFalse);
      expect(PhotoStore.isStored(null), isFalse);
      expect(photoImage(url), isA<NetworkImage>());
    });

    test('deux références à la même photo partagent le cache', () {
      expect(photoImage('photo:abc'), const StoredPhotoImage('abc'));
      expect(photoImage('photo:abc'), isNot(const StoredPhotoImage('def')));
    });
  });

  group('compression', () {
    test('un JPEG déjà léger passe tel quel', () async {
      final jpeg = img.encodeJpg(img.Image(width: 400, height: 300));
      expect(await PhotoStore.compress(jpeg), same(jpeg));
    });

    test('une grande image est réduite et convertie en JPEG', () async {
      final big = img.Image(width: 3000, height: 2000);
      for (final pixel in big) {
        pixel
          ..r = pixel.x % 256
          ..g = pixel.y % 256
          ..b = (pixel.x * pixel.y) % 256;
      }
      final png = img.encodePng(big);

      final Uint8List out = await PhotoStore.compress(png);

      expect(out.length, lessThanOrEqualTo(PhotoStore.maxBytes));
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, PhotoStore.maxSide);
      expect(decoded.height, closeTo(2000 * PhotoStore.maxSide / 3000, 1));
    });

    test("un fichier qui n'est pas une image est refusé", () {
      expect(
        PhotoStore.compress(Uint8List.fromList(List.filled(64, 7))),
        throwsA(anything),
      );
    });
  });
}
