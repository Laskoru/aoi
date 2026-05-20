import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_koi_screen.dart';
import 'add_measurement_screen.dart';
import 'koi_details_screen.dart';
import '../widgets/metric_card.dart';
import '../utils/water_logic.dart';
import '../widgets/water_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Fond ultra-propre style iOS/Android
      body: user == null
          ? const Center(child: Text("Session expirée"))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // AppBar moderne et épurée
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  elevation: 0,
                  backgroundColor: const Color(0xFFF8FAFC),
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    'AOI BASIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 16,
                      color: Colors.blue[900],
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout_rounded, color: Colors.blue[900]),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),

                // Contenu Principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Bienvenue
                        _buildHeader(user),
                        const SizedBox(height: 30),

                        // 2. SECTION PRINCIPALE : LES KOÏ EN PREMIER
                        _buildSectionHeader(
                          "Ma Collection",
                          Icons.auto_awesome_mosaic_rounded,
                          trailing: IconButton(
                            icon: Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.blue[900],
                              size: 26,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddKoiScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildKoiGrid(user.uid),

                        const SizedBox(height: 35),

                        // 3. Section Environnement & Eau
                        _buildSectionHeader(
                          "Paramètres du Bassin",
                          Icons.water_drop_rounded,
                        ),
                        const SizedBox(height: 15),
                        _buildWaterMonitor(user.uid),

                        const SizedBox(height: 30),

                        // 4. Graphiques d'analyses
                        _buildSectionHeader(
                          "Analyses pH",
                          Icons.analytics_rounded,
                        ),
                        const SizedBox(height: 15),
                        _buildChartCard(
                          user.uid,
                          "ph",
                          const Color(0xFF10B981),
                        ), // Vert Émeraude corrigé

                        const SizedBox(height: 25),

                        _buildSectionHeader(
                          "Suivi Température",
                          Icons.thermostat_rounded,
                        ),
                        const SizedBox(height: 15),
                        _buildChartCard(user.uid, "temperature", Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMeasurementScreen()),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.speed_rounded, color: Colors.white),
        label: const Text(
          "Nouvelle Mesure",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- COMPOSANTS DE STYLE ---

  Widget _buildHeader(User user) {
    final String firstName = (user.displayName ?? "Passionné").split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bienvenue dans ton écosystème,",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          firstName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: Colors.blue[900]),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildKoiGrid(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        final kois = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                0.85, // Maintient une belle proportion rectangulaire
          ),
          itemCount: kois.length,
          itemBuilder: (context, index) {
            final koiData = kois[index].data() as Map<String, dynamic>;
            final String name = koiData['name'] ?? 'Inconnu';
            final String variety = koiData['variety'] ?? 'Variété';
            final double size = (koiData['size'] as num? ?? 0).toDouble();
            final String? imageUrl = koiData['imageUrl'];

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      KoiDetailsScreen(koiId: kois[index].id, koiData: koiData),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit
                              .cover, // L'image remplit proprement toute la carte
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                ),
                child: Container(
                  // Un dégradé noir transparent est appliqué par-dessus l'image pour que le texte blanc reste lisible
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(
                          alpha: 0.75,
                        ), // Plus sombre en bas pour le contraste du texte
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge de taille en haut à droite
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: imageUrl != null
                                ? Colors.black.withValues(
                                    alpha: 0.4,
                                  ) // Sombre si fond image
                                : Colors.blue[900]!.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "$size cm",
                            style: TextStyle(
                              color: imageUrl != null
                                  ? Colors.white
                                  : Colors.blue[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),

                      // Si pas d'image, on affiche une icône discrète au centre
                      if (imageUrl == null)
                        Center(
                          child: Icon(
                            Icons.pets_rounded,
                            color: Colors.blue[200],
                            size: 32,
                          ),
                        ),

                      // Textes en bas de la carte
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: imageUrl != null
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            variety,
                            style: TextStyle(
                              color: imageUrl != null
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaterMonitor(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('measurements')
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildInfoCard(
            "Aucune mesure d'eau. Enregistrez votre première analyse.",
          );
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final double ph = (data['ph'] as num).toDouble();
        final double temp = (data['temperature'] as num).toDouble();

        return Row(
          children: [
            Expanded(
              child: MetricCard(
                title: "pH",
                value: ph.toStringAsFixed(1),
                unit: "",
                icon: Icons.science_rounded,
                color: _getStatusColor(WaterLogic.checkPhLevel(ph)),
                statusText: _getStatusLabel(WaterLogic.checkPhLevel(ph)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: "Temp",
                value: temp.toStringAsFixed(1),
                unit: "°C",
                icon: Icons.device_thermostat_rounded,
                color: _getStatusColor(WaterLogic.checkTemperature(temp)),
                statusText: _getStatusLabel(WaterLogic.checkTemperature(temp)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartCard(String userId, String field, Color color) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: WaterChart(userId: userId, field: field, color: color),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.waves_rounded, size: 40, color: Colors.blue[200]),
          const SizedBox(height: 12),
          const Text(
            "Votre collection est vide",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ajoutez vos premières carpes Koï pour commencer le suivi.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddKoiScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text("Ajouter un Koï"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
    );
  }

  Color _getStatusColor(WaterCondition condition) {
    if (condition == WaterCondition.ideal) {
      return const Color(0xFF10B981); // Émeraude
    }
    if (condition == WaterCondition.warning) {
      return const Color(0xFFF59E0B); // Ambre
    }
    return const Color(0xFFEF4444); // Corail
  }

  String _getStatusLabel(WaterCondition condition) {
    if (condition == WaterCondition.ideal) return "SAIN";
    if (condition == WaterCondition.warning) return "ALERTE";
    return "DANGER";
  }
}
