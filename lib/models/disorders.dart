import 'package:flutter/material.dart';

/// A condition the app offers screening and self-support for.
class Disorder {
  const Disorder({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}

/// Supported disorders. Add or remove one line to change the list.
// dart format off
const List<Disorder> kDisorders = [
  Disorder(id: 'hoarding', name: 'Hoarding Disorder', description: 'Difficulty discarding possessions, leading to clutter and distress.', icon: Icons.inventory_2_rounded),
  Disorder(id: 'ocd', name: 'OCD', description: 'Unwanted repeated thoughts and urges to repeat certain actions.', icon: Icons.autorenew_rounded),
];
// dart format on
