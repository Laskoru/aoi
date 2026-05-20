import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart'; // Requis pour Uint8List

class KoiDetailsScreen extends StatelessWidget {
  final String koiId;
  final Map<String, dynamic> koiData;

  const KoiDetailsScreen({
    super.key,
    required this.koiId,
    required this.koiData,
  });

  // Fonction universelle (Web + Mobile) pour uploader la photo
  Future<void> _pickAndUploadImage(BuildContext context, String docId) async {
    final ImagePicker picker = ImagePicker();

    // Sélection de l'image depuis le smartphone ou le navigateur
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60, // Compresse pour le réseau
    );

    if (pickedFile == null) return; // Annulé par l'utilisateur

    try {
      // Affichage de la barre de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 15),
              Text("Mise à jour de la photo de ton Koï..."),
            ],
          ),
          duration: Duration(days: 1),
        ),
      );

      // Récupération des données brutes (les bytes), obligatoire pour le Web et parfait pour le mobile
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      // Métadonnées pour indiquer au navigateur qu'il s'agit d'une image JPEG
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // Création de l'emplacement unique sur Firebase
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('kois_photos')
          .child('$docId.jpg');

      // SOLUTION : Utilisation de putData au lieu de putFile !
      await storageRef.putData(imageBytes, metadata);

      // Récupération du lien de téléchargement
      final String downloadUrl = await storageRef.getDownloadURL();

      // Enregistrement dans le profil de la carpe sur Firestore
      await FirebaseFirestore.instance.collection('kois').doc(docId).update({
        'imageUrl': downloadUrl,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Magnifique ! La photo a été ajoutée. 🎉"),
          ),
        );
      }
    } catch (e) {
      debugPrint("🚨 Erreur Firebase Storage : $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du transfert : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController sizeController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('kois')
              .doc(koiId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text("Chargement...");
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            return Text(
              data?['name'] ?? 'Détails du Koï',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kois')
            .doc(koiId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Ce Koï n'existe plus."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String name = data['name'] ?? 'Inconnu';
          final String variety = data['variety'] ?? 'Inconnue';
          final double size = (data['size'] as num? ?? 0).toDouble();
          final int age = (data['age'] as num? ?? 0).toInt();
          final String? imageUrl =
              data['imageUrl']; // On récupère l'image si elle existe

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // En-tête visuel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 35),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[900]!, Colors.blue[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar interactif cliquable pour l'upload
                      GestureDetector(
                        onTap: () => _pickAndUploadImage(context, koiId),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              backgroundImage: imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl == null
                                  ? const Icon(
                                      Icons.pets_rounded,
                                      size: 45,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue[900],
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        variety,
                        style: TextStyle(fontSize: 15, color: Colors.blue[100]),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Caractéristiques Fixes"),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStaticInfo(
                              "Variété",
                              variety,
                              Icons.fingerprint_rounded,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _buildStaticInfo(
                              "Âge Actuel",
                              "$age ans",
                              Icons.cake_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      _buildSectionTitle("Suivi de la Croissance"),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dernière taille mesurée",
                                  style: TextStyle(
                                    color: Colors.blueGrey[300],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$size cm",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showUpdateSizeSheet(
                                context,
                                koiId,
                                size,
                                sizeController,
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text(
                                "Modifier",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      _buildSectionTitle("Courbe de croissance"),
                      const SizedBox(height: 12),

                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: _buildGrowthChart(koiId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF334155),
      ),
    );
  }

  Widget _buildStaticInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[800], size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthChart(String koiId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .doc(koiId)
          .collection('growth')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erreur : ${snapshot.error}",
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Modifiez la taille pour commencer à tracer le graphique !",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }

        final docs = snapshot.data!.docs.reversed.toList();
        List<FlSpot> spots = [];

        for (int i = 0; i < docs.length; i++) {
          final d = docs[i].data() as Map<String, dynamic>;
          double val = (d['size'] as num).toDouble();
          spots.add(FlSpot(i.toDouble(), val));
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: spots.length > 1,
                color: Colors.blue[900],
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue[900]!.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateSizeSheet(
    BuildContext context,
    String docId,
    double currentSize,
    TextEditingController controller,
  ) {
    controller.text = currentSize.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mettre à jour la taille",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Indiquez la nouvelle longueur mesurée pour votre carpe Koï.",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Nouvelle taille",
                  suffixText: "cm",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue[900]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final String text = controller.text.trim();
                    final double? newSize = double.tryParse(text);
                    if (newSize != null && newSize > 0) {
                      await FirebaseFirestore.instance
                          .collection('kois')
                          .doc(docId)
                          .update({'size': newSize});

                      await FirebaseFirestore.instance
                          .collection('kois')
                          .doc(docId)
                          .collection('growth')
                          .add({
                            'size': newSize,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Veuillez entrer une taille numérique valide.",
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Confirmer la mesure",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
