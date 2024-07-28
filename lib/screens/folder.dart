// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderPage extends ConsumerWidget {

  const FolderPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FunkoVault"),
      ),
      body: Center(child: Text("Folders Page"))
    );
  }
}