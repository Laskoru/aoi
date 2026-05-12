import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_koi_screen.dart'; // Assure-toi que le chemin est correct

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. On récupère l'utilisateur actuellement connecté
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Bassin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // La redirection vers le login devrait être gérée par le main.dart (via AuthStateChanges)
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<QuerySnapshot>(
              // 2. Le filtre de sécurité pour limiter l'affichage
              stream: FirebaseFirestore.instance
                  .collection('kois')
                  .where('userId', isEqualTo: user.uid) // <-- LE FILTRE ICI
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Vous n'avez pas encore de carpes Koï dans votre bassin.",
                    ),
                  );
                }

                final kois = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: kois.length,
                  itemBuilder: (context, index) {
                    final data = kois[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.water)),
                        title: Text(
                          data['name'] ?? 'Sans nom',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${data['variety'] ?? 'Inconnue'} - Taille: ${data['size']} cm',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddKoiScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
