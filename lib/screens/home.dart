// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/components/funko_card.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final formatter = NumberFormat('#,###');
  String? selectedSeries;

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

  Future<void> refresh() async {
    await ref.read(funkoListProvider.notifier).fetchFunkos(refresh: true);
  }

  void onSeriesSelected(String series) {
    setState(() {
      selectedSeries = series;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(8.0),
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
            child: asyncFunkos.when(
              data: (funkos) {
                return RefreshIndicator(
                  onRefresh: refresh,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 7 / 10,
                    ),
                    controller: _scrollController,
                    itemCount: funkos.length,
                    itemBuilder: (context, index) {
                      final funko = funkos[index];
                      return FunkoCard(funko: funko);
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text("Error!")),
            ),
          ),
        ],
      ),
    );
  }
}
