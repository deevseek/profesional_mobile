import 'package:flutter/material.dart';

enum ReceiptFormat { standard, thermal80, thermal58 }

extension ReceiptFormatX on ReceiptFormat {
  String get label => switch (this) {
        ReceiptFormat.standard => 'Default / A4',
        ReceiptFormat.thermal80 => 'Thermal 80mm',
        ReceiptFormat.thermal58 => 'Thermal 58mm',
      };
}

class ReceiptFormatSelector extends StatelessWidget {
  const ReceiptFormatSelector({super.key, required this.value, required this.onChanged});

  final ReceiptFormat value;
  final ValueChanged<ReceiptFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReceiptFormat>(
      showSelectedIcon: false,
      segments: ReceiptFormat.values
          .map((format) => ButtonSegment<ReceiptFormat>(value: format, label: Text(format.label)))
          .toList(growable: false),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
