// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/models/funko.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:funko_vault/data/series.dart'; // Ensure you import your series list

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Funko> _searchResults = [];
  List<String> filters = []; 
  List<Color> pillColors = List.generate(seriesList.length, (index) => Colors.grey); 
  bool _isLoading = false; 

  void _searchFunkos() async {
    final searchTerm = _searchController.text;
    if (searchTerm.isNotEmpty) {
      setState(() {
        _isLoading = true; 
      });

      final results = await ref.read(funkoListProvider.notifier).searchFunkos(searchTerm);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // Filtered Funkos based on search and filters
    List<Funko> filteredFunkos = _searchResults.where((funko) {
      List<String> funkoSeries = funko.series.split(',').map((s) => s.trim()).toList();
      return filters.isEmpty || filters.every((filter) => funkoSeries.contains(filter)); // Changed to every
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(240),
        child: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Column(
            children: [
              SizedBox(height: 30), 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Expanded(
                      child: Container(), 
                    ),
                    Text(
                      "iFunko",
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 54,
                  child: Center(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _searchFunkos(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search by name...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: seriesList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(index == 0 ? 16 : 2, 8, 4, 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              pillColors[index] = pillColors[index] == Colors.grey ? Colors.blue : Colors.grey;
                              if (!filters.contains(seriesList[index])) {
                                filters.add(seriesList[index]);
                              } else {
                                filters.remove(seriesList[index]);
                              }
                            });
                          },
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: pillColors[index], width: 3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(child: Text(seriesList[index])),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchController.text.isEmpty 
                        ? "Search Funkos" 
                        : 'Searched for: "${_searchController.text}"',
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
      body: Container(
        color: whiteColor,
        child: _isLoading ? Center(child: CircularProgressIndicator()) : filteredFunkos.isEmpty ? const Center(child: Text("No results found!")) : Container(
          color: whiteColor,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 7 / 10,
            ),
            itemCount: filteredFunkos.length,
            itemBuilder: (context, index) {
              final funko = filteredFunkos[index];
              return FunkoCard(funko: funko);
            },
          ),
        ),
      ),
    );
  }
}
