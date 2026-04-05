import 'package:flutter/material.dart';

/// Represents the time period for analytics data
enum AnalyticsPeriod {
  week,
  month,
  quarter,
  year;

  /// Returns a human-readable label for the period
  String get label {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.quarter:
        return '3 Months';
      case AnalyticsPeriod.year:
        return 'Year';
    }
  }

  /// Returns the date range for this period
  DateTimeRange getDateRange() {
    final now = DateTime.now();

    switch (this) {
      case AnalyticsPeriod.week:
        // Get the start of the current week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);

      case AnalyticsPeriod.month:
        // Get the start of the current month
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);

      case AnalyticsPeriod.quarter:
        // Last 90 days
        final start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 90));
        final end = DateTime(now.year, now.month, now.day + 1);
        return DateTimeRange(start: start, end: end);

      case AnalyticsPeriod.year:
        // Get the start of the current year
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1);
        return DateTimeRange(start: start, end: end);
    }
  }
}
