// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:funko_vault/components/folder_card.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/models/folder.dart';
import 'package:funko_vault/services/database.dart';
import 'package:google_fonts/google_fonts.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {

  List<String> filters = [];
  List<Folder> allCollections = [];
  List<Folder> filteredCollections = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController collectionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    getCollections();
  }

  // filtering folders
  void filterCollections() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredCollections = List.from(allCollections);
      } else {
        filteredCollections = allCollections.where((collection) {
          bool matchesSearch = collection.name.toLowerCase().contains(searchQuery);
          return matchesSearch;
        }).toList();
      }
    });
  }

  // fetching all the folders in the database
  void getCollections() async {
    try {
      List<Folder> collections = await _databaseService.getFolders();
      setState(() {
        allCollections = collections;
        filteredCollections = List.from(allCollections);
      });
    } catch (e) {
      print("Error fetching collections: $e");
    }
  }

  // refresh state by fetching updated folders
  void handleDelete() {
    getCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "iFunko",
          style: GoogleFonts.fredoka(fontSize: 36, color: blackColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: whiteColor,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: IconButton(
              onPressed: () async {
                print("New Collection!");
                String? collectionName = await openDialog(context, collectionController);
                if (collectionName != null && collectionName.isNotEmpty) {
                  await _databaseService.addFolder(collectionName);
                  getCollections();
                }
              },
              icon: Icon(Icons.add, color: blackColor, size: 32),
            ),
          ),
        ],
      ),
      body: Container(
        color: whiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Collections",
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredCollections.isEmpty ? Center(child: Text("No Collections Found!")) : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemCount: filteredCollections.length,
                itemBuilder: (context, index) {
                  return FolderCard(folder: filteredCollections[index], onDelete: handleDelete);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> openDialog(BuildContext context, TextEditingController collectionController) => showDialog<String>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text("Collection Name..."),
    content: TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Enter The Name of Your Collection...",
      ),
      controller: collectionController,
    ),
    actions: [
      TextButton(
        child: Text("SUBMIT"),
        onPressed: () {
          submit(context, collectionController);
          collectionController.clear();
        },
      ),
    ],
  ),
);

void submit(BuildContext context, TextEditingController collectionController) {
  Navigator.of(context).pop(collectionController.text);
}
