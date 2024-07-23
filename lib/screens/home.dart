// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/services/provider.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  int num = 0;
  final formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(funkoListProvider.notifier).fetchFunkos();
    });

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

  @override
  Widget build(BuildContext context) {
    final asyncFunkos = ref.watch(funkoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("FunkoVault"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${formatter.format(num)} out of 49,000"),
          ),
          Expanded(
            child: asyncFunkos.when(
              data: (funkos) {
                num = funkos.length;
                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: funkos.length,
                    itemBuilder: (context, index) {
                      final funko = funkos[index];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Name"),
                        subtitle: Text("Series"),
                        trailing: Text("$index"),
                      );
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
