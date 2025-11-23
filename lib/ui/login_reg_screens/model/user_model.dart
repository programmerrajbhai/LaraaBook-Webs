class UserModel {
  late final String? user_id;
  late final String username;
  late final String email;
  late final String full_name;
  late final String? profile_picture_url; // এটি null হতে পারে

  UserModel({
    this.user_id,
    required this.username,
    required this.email,
    required this.full_name,
    this.profile_picture_url,
  });

  // Named constructor
  UserModel.fromJson(Map<String, dynamic> json) {
    // --- সমাধান ---
    // .toString() ব্যবহার করায় int আসলেও সমস্যা হবে না
    user_id = json['user_id']?.toString();

    username = json['username']?.toString() ?? '';
    email = json['email']?.toString() ?? '';
    full_name = json['full_name']?.toString() ?? '';
    profile_picture_url = json['profile_picture_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'username': username,
      'email': email,
      'full_name': full_name,
      'profile_picture_url': profile_picture_url,
    };
  }
}