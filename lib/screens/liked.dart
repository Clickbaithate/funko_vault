// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:funko_vault/services/provider.dart'; 

class LikedPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the list of liked Funkos from the provider
    final likedFunkos = ref.watch(likedFunkosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Liked Funkos"),
      ),
      body: likedFunkos.isEmpty
          ? Center(
              child: Text("No liked Funkos yet"),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 7 / 10
              ),
              itemCount: likedFunkos.length,
              itemBuilder: (context, index) {
                final funko = likedFunkos[index];
                return FunkoCard(funko: funko);
              },
            ),
    );
  }
}
