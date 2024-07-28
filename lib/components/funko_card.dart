// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/services/provider.dart';

class FunkoCard extends ConsumerWidget {

  final Funko funko;
  const FunkoCard({super.key, required this.funko});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Watches the likedFunkosProvider to determine if the current Funko is liked
    final isLiked = ref.watch(likedFunkosProvider.select((list) => list.any((f) => f.id == funko.id)));

    return GestureDetector(
      onDoubleTap: () {
        if (isLiked) {
          ref.read(likedFunkosProvider.notifier).removeFunko(funko.id);
        } else {
          ref.read(likedFunkosProvider.notifier).addFunko(funko);
        }
      },
      child: Card(
        elevation: 20,
        color: whiteColor,
        child: Stack(
          children: [
            // Funko Image
            Positioned(
              left: 8,
              top: 16,
              right: 8,
              child: CachedNetworkImage(
                imageUrl: funko.image,
                placeholder: (context, url) => Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: grayColor))),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (isLiked) {
                        ref.read(likedFunkosProvider.notifier).removeFunko(funko.id);
                      } else {
                        ref.read(likedFunkosProvider.notifier).addFunko(funko);
                      }
                    },
                    icon: Icon(Icons.favorite, color: isLiked ? redColor : Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {}, 
                    icon: Icon(Icons.folder, color: biegeColor)
                  )
                ],
              ),
            ),
            // Funko Name & Series Container
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Center(
                child: Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    color: grayColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Funko Name
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Text(
                          funko.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Text(
                          funko.series,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
