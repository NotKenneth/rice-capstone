import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Date range selector widget for filtering analysis data
class DateRangeSelectorWidget extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate) onDateRangeChanged;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateRangeSelectorWidget({
    super.key,
    required this.onDateRangeChanged,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DateRangeSelectorWidget> createState() =>
      _DateRangeSelectorWidgetState();
}

class _DateRangeSelectorWidgetState extends State<DateRangeSelectorWidget> {
  late DateTime _startDate;
  late DateTime _endDate;
  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy');

  @override
  void initState() {
    super.initState();
    _endDate = widget.initialEndDate ?? DateTime.now();
    _startDate =
        widget.initialStartDate ?? _endDate.subtract(const Duration(days: 7));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final theme = Theme.of(context);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(colorScheme: theme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'calendar_today',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'arrow_drop_down',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
