import 'package:flutter/material.dart';

class TenantLoadingPage extends StatelessWidget {
  const TenantLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
