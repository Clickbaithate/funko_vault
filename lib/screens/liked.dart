// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/services/provider.dart';

class LikedPage extends ConsumerWidget {
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: Text("FunkoVault"),
      ),
      body: Center(
        child: Text("Liked Page"),
      ),
    );

  }

}