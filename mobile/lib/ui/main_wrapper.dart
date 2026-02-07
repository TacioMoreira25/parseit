import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'cvs/cv_list_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/view_models/dashboard_view_model.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const DashboardScreen(), const CVListScreen()];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.read<DashboardViewModel>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              // CORREÇÃO: Adicionada uma tag única para o Hero.
              heroTag: 'add_job_fab',
              onPressed: () {
                context.push('/add_job').then((_) {
                  dashboardViewModel.fetchJobs();
                });
              },
              backgroundColor: const Color(0xFF1A1A1A),
              shape: const CircleBorder(),
              child: const Icon(CupertinoIcons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00695C),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.briefcase),
            activeIcon: Icon(CupertinoIcons.briefcase_fill),
            label: 'Vagas',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            activeIcon: Icon(CupertinoIcons.doc_text_fill),
            label: 'Currículos',
          ),
        ],
      ),
    );
  }
}
