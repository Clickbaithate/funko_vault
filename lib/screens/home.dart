// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/screens/search_page.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  
  // Class Variables
  final ScrollController _scrollController = ScrollController();
  final formatter = NumberFormat('#,###');
  bool _isLoadingDelayed = true;
  bool _isContentVisible = false;

  // Override Methods
  @override
  void initState() {
    super.initState();
    _startDelay();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(homeFunkoListProvider.notifier).fetchFunkos();
      }
    });
  }

  void _startDelay() async {
    await Future.delayed(Duration(seconds: 0));
    setState(() {
      _isLoadingDelayed = false;
      _isContentVisible = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper Methods
  Future<void> refresh() async {
    await ref.read(homeFunkoListProvider.notifier).fetchFunkos(refresh: true);
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    // Fetching Funkos after delay
    final asyncFunkos = _isLoadingDelayed ? AsyncValue.loading() : ref.watch(homeFunkoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "iFunko",
          style: GoogleFonts.fredoka(fontSize: 36, color: blackColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: whiteColor,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              icon: Icon(Icons.search, size: 32, color: blackColor),
            ),
          ),
        ],
      ),
      body: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0,
        duration: Duration(seconds: 1),
        child: Container(
          color: whiteColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: asyncFunkos.when(
                  data: (funkos) {
                    final num = funkos.length;
                    return Text(
                      "${formatter.format(num)} out of 49,000",
                      style: GoogleFonts.fredoka(fontSize: 12, color: blackColor, fontWeight: FontWeight.bold),
                    );
                  },
                  loading: () => Text(
                      "Loading...",
                      style: GoogleFonts.fredoka(fontSize: 12, color: blackColor, fontWeight: FontWeight.bold),
                    ),
                  error: (e, stack) => Text("Error!"),
                ),
              ),
              Expanded(
                child: Container(
                  color: whiteColor,
                  child: RefreshIndicator(
                    onRefresh: refresh,
                    child: asyncFunkos.when(
                      data: (funkos) => funkos.isNotEmpty ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 7 / 10,
                        ),
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: funkos.length,
                        itemBuilder: (context, index) {
                          final funko = funkos[index];
                          return FunkoCard(funko: funko);
                        },
                      ) : ListView(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [Center(child: Text("No data available! Pull to refresh."))],
                      ),
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (e, stack) => Text("Error!"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
