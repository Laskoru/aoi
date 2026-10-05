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
      expect(photoImage(url, width: 200), isA<ResizeImage>());
    });

    test('deux références à la même photo, à la même taille, partagent le cache', () {
      expect(photoImage('photo:abc'), const StoredPhotoImage('abc'));
      expect(photoImage('photo:abc', width: 200), const StoredPhotoImage('abc', width: 200));
      expect(photoImage('photo:abc', width: 200), isNot(const StoredPhotoImage('abc')));
      expect(photoImage('photo:abc'), isNot(const StoredPhotoImage('def')));
    });
  });

  group('compression', () {
    test('la position GPS et les autres métadonnées disparaissent', () async {
      final source = img.Image(width: 400, height: 300);
      source.exif.gpsIfd.gpsLatitude = 48.11;
      source.exif.gpsIfd.gpsLongitude = -1.68;
      source.exif.imageIfd.make = 'Téléphone';
      final withExif = img.encodeJpg(source);
      expect(img.decodeJpg(withExif)!.exif.isEmpty, isFalse);

      final out = await PhotoStore.compress(withExif);

      final decoded = img.decodeJpg(out)!;
      expect(decoded.exif.isEmpty, isTrue);
      expect((decoded.width, decoded.height), (400, 300));
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

    test('la photo du bassin garde une plus grande définition', () async {
      final wide = img.encodeJpg(img.Image(width: 3000, height: 1500));

      final out = await PhotoStore.compress(wide, maxSide: PhotoStore.pondMaxSide);

      expect(img.decodeJpg(out)!.width, PhotoStore.pondMaxSide);
    });

    test("un fichier qui n'est pas une image est refusé", () {
      expect(
        PhotoStore.compress(Uint8List.fromList(List.filled(64, 7))),
        throwsA(anything),
      );
    });
  });
}
