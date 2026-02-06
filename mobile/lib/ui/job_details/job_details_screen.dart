import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/job.dart';

/// A screen that displays job details and a study mode for its technologies.
class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          // CORRECTED: Add a fallback to home if there's nothing to pop.
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Fallback to the dashboard screen.
            }
          },
        ),
        title: Column(
          children: [
            Text(
              job.title,
              style: GoogleFonts.inter(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Modo Estudo',
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: job.tags.isEmpty ? _buildNoTagsView() : _buildFlashcardsView(),
    );
  }

  Widget _buildNoTagsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Sem tags para estudar',
            style: GoogleFonts.inter(fontSize: 16.0, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsView() {
    return PageView.builder(
      itemCount: job.tags.length,
      itemBuilder: (context, index) {
        final tag = job.tags[index];
        final pageNumber = index + 1;
        final totalPages = job.tags.length;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
          child: Card(
            elevation: 8.0,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CARD $pageNumber/$totalPages',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    tag.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00695C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
