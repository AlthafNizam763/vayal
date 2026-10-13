import 'package:flutter/material.dart';

/// Contact model in the player's smartphone.
class PhoneContact {
  final String id;
  final String name;
  final String role;
  final String phoneNumber;
  final Color themeColor;
  final String avatarInitials;
  final bool isAvailableForCall;
  final String statusBio;

  const PhoneContact({
    required this.id,
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.themeColor,
    required this.avatarInitials,
    this.isAvailableForCall = true,
    this.statusBio = '',
  });

  static const List<PhoneContact> defaultContacts = [
    PhoneContact(
      id: 'contact_meera',
      name: 'Meera',
      role: 'Wife • Safehouse Anchor',
      phoneNumber: '+91 94471 00214',
      themeColor: Color(0xFFEC4899),
      avatarInitials: 'M',
      statusBio: 'Keeping the lamp lit at the ancestral home.',
    ),
    PhoneContact(
      id: 'contact_rahu',
      name: 'Rahu',
      role: 'Childhood Friend • Highway Diner',
      phoneNumber: '+91 98460 33491',
      themeColor: Color(0xFF6366F1),
      avatarInitials: 'R',
      statusBio: 'Eyes on the highway. Call me if the convoy moves.',
    ),
    PhoneContact(
      id: 'contact_diya',
      name: 'Diya',
      role: 'Sister • Village Orchard',
      phoneNumber: '+91 94473 88120',
      themeColor: Color(0xFFA855F7),
      avatarInitials: 'D',
      statusBio: 'Looking after the family groves.',
    ),
    PhoneContact(
      id: 'contact_kumaran',
      name: 'Kumaran',
      role: 'Old Mechanic • Old Town Garage',
      phoneNumber: '+91 97455 12099',
      themeColor: Color(0xFF38BDF8),
      avatarInitials: 'K',
      statusBio: 'Engines speak honesty when people do not.',
    ),
    PhoneContact(
      id: 'contact_mohan',
      name: 'Mohan',
      role: 'Dock Union Worker • Port Berth 4',
      phoneNumber: '+91 98950 44012',
      themeColor: Color(0xFF06B6D4),
      avatarInitials: 'MO',
      statusBio: 'Night shift at Berth 4. Cargo keeps arriving in silence.',
    ),
  ];
}
