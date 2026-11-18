import 'package:flutter/material.dart';

/// Beschreibt ein kaufbares Maskottchen-Accessoire mit Preis, Symbol und übersetzbaren Texten.
class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.price,
    required this.icon,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final int price;
  final IconData icon;
}

/// Lokales Angebot; die stabilen IDs werden auch für Besitz und Ausrüstung gespeichert.
const cosmeticItems = [
  CosmeticItem(
    id: 'cap',
    titleKey: 'profile.shop.cap.title',
    descriptionKey: 'profile.shop.cap.description',
    price: 60,
    icon: Icons.school_rounded,
  ),
  CosmeticItem(
    id: 'scarf',
    titleKey: 'profile.shop.scarf.title',
    descriptionKey: 'profile.shop.scarf.description',
    price: 90,
    icon: Icons.dry_cleaning_rounded,
  ),
  CosmeticItem(
    id: 'glasses',
    titleKey: 'profile.shop.glasses.title',
    descriptionKey: 'profile.shop.glasses.description',
    price: 120,
    icon: Icons.visibility_rounded,
  ),
  CosmeticItem(
    id: 'crown',
    titleKey: 'profile.shop.crown.title',
    descriptionKey: 'profile.shop.crown.description',
    price: 180,
    icon: Icons.workspace_premium_rounded,
  ),
];
