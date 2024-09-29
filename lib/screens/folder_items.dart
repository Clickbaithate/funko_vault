// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/models/folder.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/services/database.dart';

class FolderItems extends StatefulWidget {

  final Folder folder;
  const FolderItems({required this.folder, super.key});

  @override
  State<FolderItems> createState() => _FolderItemsState();

}

class _FolderItemsState extends State<FolderItems> {

  List<Funko> allFunkos = [];
  List<Funko> filteredFunkos = [];
  TextEditingController searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    fetchCollectedFunkos();
  }

  // filtering funkos
  void filterCollections() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredFunkos = List.from(allFunkos);
      } else {
        filteredFunkos = allFunkos.where((funko) {
          return funko.name.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }

  // fetching all funkos that belong in this folder
  Future<void> fetchCollectedFunkos() async {
    try {
      List<Funko> collectedFunkos = await _databaseService.getSavedFunkos(widget.folder.name);
      print("Funko Collected: ${widget.folder.name}");
      setState(() {
        allFunkos = collectedFunkos;
        filteredFunkos = List.from(allFunkos);
      });
    } catch (e) {
      print("Error fetching liked Funkos: $e");
    }
  }

  // Meant to update state based on these actions but unsure if these work
  void handleLiked() {
    fetchCollectedFunkos();
  }
  void handleDeleted() {
    fetchCollectedFunkos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: AppBar(
          title: Text(
            widget.folder.name,
            style: TextStyle(
              color: blackColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          scrolledUnderElevation: 0,
          backgroundColor: whiteColor,
          elevation: 0,
          flexibleSpace: Column(
            children: [
              SizedBox(height: 80), // Adjust height to give more space
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 54,
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterCollections();
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: grayColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // if no funkos then message saying that, otherwise build gridview showing them all
      body: filteredFunkos.isEmpty ? Container(color: whiteColor, child: Center(child: Text("This list is empty!"))) : Container(
        color: whiteColor,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 7 / 10),
          itemCount: filteredFunkos.length,
          itemBuilder: (context, index) {
            return FunkoCard(funko: filteredFunkos[index]);
          },
        ),
      ),
    );
  }
}
