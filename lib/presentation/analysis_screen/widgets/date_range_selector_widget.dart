import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorWidget extends StatefulWidget {
  final Function(DateTime start, DateTime end) onRangeChanged;
  final DateTimeRange? initialRange;

  const DateSelectorWidget({
    super.key,
    required this.onRangeChanged,
    this.initialRange,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late DateTimeRange _selectedRange;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _selectedRange =
        widget.initialRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRange != oldWidget.initialRange &&
        widget.initialRange != null) {
      setState(() {
        _selectedRange = widget.initialRange!;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: Theme.of(context).colorScheme.primary,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedRange) {
      setState(() => _selectedRange = picked);
      widget.onRangeChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            // Increased blur slightly for a denser frost
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Replaced flat color with a gradient for depth
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withOpacity(0.4), // Brighter top-left
                    theme.colorScheme.surface.withOpacity(0.1), // Faded bottom-right
                  ],
                ),
                // Thicker, slightly darker border to define the edge
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedRange.start.year == _selectedRange.end.year &&
                              _selectedRange.start.month ==
                                  _selectedRange.end.month &&
                              _selectedRange.start.day == _selectedRange.end.day
                          ? _dateFormat.format(_selectedRange.start)
                          : "${_dateFormat.format(_selectedRange.start)} - ${_dateFormat.format(_selectedRange.end)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}