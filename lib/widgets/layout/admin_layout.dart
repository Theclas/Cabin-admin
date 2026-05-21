import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
