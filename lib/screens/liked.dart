// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/data/series.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LikedPage extends ConsumerStatefulWidget {
  const LikedPage({super.key});

  @override
  ConsumerState<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends ConsumerState<LikedPage> {
  List<String> series = seriesList;
  List<String> filters = [];
  List<Color> pillColors = List.generate(seriesList.length, (index) => grayColor);
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    // Get the list of liked Funkos from the provider
    final likedFunkos = ref.watch(likedFunkosProvider);

    // Filtered Funkos based on search and filters
    List<Funko> filteredFunkos = likedFunkos.where((funko) {
      String searchQuery = searchController.text.toLowerCase();
      List<String> funkoSeries = funko.series.split(',').map((s) => s.trim()).toList();
      bool matchesFilters = filters.isEmpty || filters.every((filter) => funkoSeries.contains(filter));
      bool matchesSearch = funko.name.toLowerCase().contains(searchQuery);
      return matchesFilters && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250),
        child: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: whiteColor,
          elevation: 0,
          title: Center(
            child: Text(
              "iFunko",
              style: GoogleFonts.fredoka(fontSize: 36, color: blackColor, fontWeight: FontWeight.bold),
            ),
          ),
          flexibleSpace: Column(
            children: [
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 54,
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search by name...",
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
              SizedBox(height: 10),
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(index == 0 ? 16 : 2, 8, 4, 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            pillColors[index] = pillColors[index] == grayColor ? blueColor : grayColor;
                            if (!filters.contains(series[index])) {
                              filters.add(series[index]);
                            } else {
                              filters.remove(series[index]);
                            }
                          });
                        },
                        child: Container(
                          width: 160,
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(color: pillColors[index], width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Text(series[index])),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Liked Funkos",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredFunkos.isEmpty ? Container(color: whiteColor, child: Center(child: Text("No liked Funkos found!"))) : Container (
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
