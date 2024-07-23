import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterPill extends ConsumerWidget {
  final String series;
  final bool isSelected;
  final Function(String) onSelected;

  const FilterPill({
    Key? key,
    required this.series,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => onSelected(series),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 125,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            border: Border.all(color: isSelected ? Colors.blue : grayColor),
          ),
          child: Center(
            child: Text(
              series,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                color: blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
