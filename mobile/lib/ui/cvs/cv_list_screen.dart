import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CVListScreen extends StatelessWidget {
  const CVListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Meus Currículos'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildDesktopNotice(),
            Expanded(
              child: ListView(
                children: [
                  _buildCVCard(context, title: 'Dev Go Pleno'),
                  _buildCVCard(context, title: 'Dev Rust Junior'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopNotice() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.device_laptop, color: Colors.blue[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gerencie e edite seus currículos na versão Desktop.',
              style: GoogleFonts.inter(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCVCard(BuildContext context, {required String title}) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.doc_text_fill,
              color: Color(0xFF00695C),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.share, color: Colors.grey),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade de compartilhar em breve!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
