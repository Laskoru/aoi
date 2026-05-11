import 'package:flutter/material.dart';

class AddKoiScreen extends StatefulWidget {
  @override
  _AddKoiScreenState createState() => _AddKoiScreenState();
}

class _AddKoiScreenState extends State<AddKoiScreen> {
  final _nameCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _breederCtrl = TextEditingController();
  final _lineageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle acquisition")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("Nom du Koï", _nameCtrl, "ex: Kohaku Royal"),
            _buildField("Variété", _varietyCtrl, "ex: Kohaku, Sanke..."),
            _buildField("Éleveur", _breederCtrl, "ex: Sakai Fish Farm"),
            _buildField(
              "Généalogie / Lignée",
              _lineageCtrl,
              "ex: Sang de Rose",
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 55),
                backgroundColor: Colors.blue,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ENREGISTRER LE POISSON",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
