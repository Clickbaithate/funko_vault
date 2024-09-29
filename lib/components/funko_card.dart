// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:like_button/like_button.dart';
import 'package:funko_vault/services/database.dart';
import 'package:funko_vault/models/folder.dart';

class FunkoCard extends ConsumerWidget {
  final Funko funko;
  const FunkoCard({super.key, required this.funko});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // if liked or unliked, state should change
    final isFunkoLiked = ref.watch(likedFunkosProvider.select((list) => list.any((f) => f.id == funko.id)));

    // Call this to like or unlike a funko
    Future<bool> onLike(bool isLiked) async {
      if (isLiked) {
        ref.read(likedFunkosProvider.notifier).removeFunko(funko.id);
        return false;
      } else {
        ref.read(likedFunkosProvider.notifier).addFunko(funko);
        return true;
      }
    }

    // call to add/unadd funko to folder
    void _handleFolderAction(String folderName) async {
      
      // for some reason clicking the folder icon would open the keyboard, this fixed it
      FocusScope.of(context).unfocus();

      final dbService = DatabaseService.instance;

      // we check is funko is in the folder already
      bool isInCollection = await dbService.isInFolder(folderName, funko);
      
      if (isInCollection) {
        // delete it from the folder if it is
        await dbService.deleteFromFolder(folderName, funko.image);
      } else {
        // add it otherwise
        await dbService.addToFolder(folderName, funko);
      }

      // Refresh the UI or state if needed
      // I am pretty sure this doesn't work as intended
      ref.refresh(likedFunkosProvider);
    }

    return GestureDetector(
      onDoubleTap: () async => await onLike(isFunkoLiked),
      onTap: () {
        Fluttertoast.showToast(
          msg: "Folder Name: ${funko.name}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: grayColor,
          textColor: Colors.black,
          fontSize: 16,
        );
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
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 40, 
                    height: 40, 
                    child: CircularProgressIndicator(color: grayColor)
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
              ),
            ),
            // Like and Folder Buttons
            Positioned(
              right: 8,
              top: 8,
              child: Column(
                children: [
                  LikeButton(
                    isLiked: isFunkoLiked,
                    onTap: onLike,
                    likeBuilder: (isLiked) {
                      var icon = isLiked ? Icon(Icons.favorite, color: redColor) : Icon(Icons.favorite_outline, color: grayColor);
                      return icon;
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      // Close keyboard if it is open
                      FocusScope.of(context).unfocus();

                      // Fetch the folders
                      List<Folder> folders = await DatabaseService.instance.getFolders();

                      if (folders.isNotEmpty) {
                        // Opening the folder menu to the left of the button
                        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                        final RenderBox button = context.findRenderObject() as RenderBox;
                        final offset = button.localToGlobal(Offset.zero, ancestor: overlay);
                        
                        // Show a popup menu with folder options
                        showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(offset.dx + 50, offset.dy + 50, offset.dx + 200, offset.dy),
                          items: folders.map((Folder folder) {
                            return PopupMenuItem<String>(
                              value: folder.name,
                              child: Text(folder.name),
                            );
                          }).toList(),
                        ).then((value) {
                          if (value != null) {
                            _handleFolderAction(value);
                          }
                        });
                      }
                    },
                    icon: Icon(Icons.folder, color: biegeColor),
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
                    borderRadius: BorderRadius.circular(10),
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
