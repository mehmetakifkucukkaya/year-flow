import 'package:meta/meta.dart';

@immutable
class User {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isPremium = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isPremium;
}


