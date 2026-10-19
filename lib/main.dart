import 'package:flutter/material.dart';

import 'ui/screens/catalog_screen.dart';

void main() {
  runApp(const CatalogApp());
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CatalogScreen(),
    );
  }
}
