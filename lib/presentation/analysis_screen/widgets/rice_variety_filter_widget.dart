import 'package:flutter/material.dart';

/// Rice variety filter chips widget
class RiceVarietyFilterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> varieties;
  final Function(List<String> selectedVarieties) onSelectionChanged;
  final List<String>? initialSelection;

  const RiceVarietyFilterWidget({
    super.key,
    required this.varieties,
    required this.onSelectionChanged,
    this.initialSelection,
  });

  @override
  State<RiceVarietyFilterWidget> createState() =>
      _RiceVarietyFilterWidgetState();
}

class _RiceVarietyFilterWidgetState extends State<RiceVarietyFilterWidget> {
  late Set<String> _selectedVarieties;

  @override
  void initState() {
    super.initState();
    _selectedVarieties =
        widget.initialSelection?.toSet() ??
        widget.varieties.map((v) => v['name'] as String).toSet();
  }

  void _toggleVariety(String variety) {
    setState(() {
      if (_selectedVarieties.contains(variety)) {
        if (_selectedVarieties.length > 1) {
          _selectedVarieties.remove(variety);
        }
      } else {
        _selectedVarieties.add(variety);
      }
    });
    widget.onSelectionChanged(_selectedVarieties.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rice Varieties',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.varieties.map((variety) {
              final varietyName = variety['name'] as String;
              final varietyColor = variety['color'] as Color;
              final isSelected = _selectedVarieties.contains(varietyName);

              return FilterChip(
                label: Text(varietyName),
                selected: isSelected,
                onSelected: (_) => _toggleVariety(varietyName),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: varietyColor.withValues(alpha: 0.2),
                checkmarkColor: varietyColor,
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? varietyColor
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected ? varietyColor : theme.colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
