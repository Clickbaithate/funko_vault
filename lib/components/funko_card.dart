import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/services/provider.dart';

class FunkoCard extends ConsumerWidget {
  final Funko funko;

  const FunkoCard({Key? key, required this.funko}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(likedFunkosProvider.select((list) => list.any((f) => f.id == funko.id)));

    return Card(
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
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),
          // Like & Folder Button
          Positioned(
            top: 8,
            left: 8,
            child: Text("Id: ${funko.id}"),
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
          ) // Funko Name & Series Container
        ],
      ),
    );
  }
}
