/// User profile model.
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String avatarUrl;
  final bool isGuest;
  final int savedStayCount;
  final int tripCount;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl = '',
    this.isGuest = false,
    this.savedStayCount = 0,
    this.tripCount = 0,
  });

  static const UserProfile guest = UserProfile(
    uid: 'guest',
    displayName: 'Guest',
    email: '',
    isGuest: true,
  );

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    int? savedStayCount,
    int? tripCount,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest,
      savedStayCount: savedStayCount ?? this.savedStayCount,
      tripCount: tripCount ?? this.tripCount,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] as String? ?? 'Traveller',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
    );
  }
}
