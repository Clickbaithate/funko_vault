// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Class Definition
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends ConsumerState<HomePage> {
  
  // Class Variables
  final ScrollController _scrollController = ScrollController();
  final formatter = NumberFormat('#,###');

  // Override Methods
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(funkoListProvider.notifier).fetchFunkos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper Methods
  Future<void> refresh() async {
    await ref.read(funkoListProvider.notifier).fetchFunkos(refresh: true);
  }

  // Build Method
  @override
  Widget build(BuildContext context) {

    // Fetching Funkos
    final asyncFunkos = ref.watch(funkoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FunkoVault",
          style: GoogleFonts.fredoka(fontSize: 36, color: blackColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, size: 32),
            ),
          ),
        ],
      ),
      body: Column(
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
              loading: () => Text("Loading..."),
              error: (e, stack) => Text("Error!"),
            ),
          ),
          Expanded(
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
                  children: [Center(child: Text("No data available! Pull to refresh."))]
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, stack) => Text("Error!")
              ),
            ),
          ),
        ],
      ),
    );
  }
}
