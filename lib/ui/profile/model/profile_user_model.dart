class ProfileUserModel {
  final int userId;
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final String createdAt;

  ProfileUserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    required this.createdAt,
  });

  // JSON থেকে মডেলে কনভার্ট করা (Safe Parsing)
  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      // int.parse দিয়ে নিশ্চিত করছি যে ID সবসময় int হবে
      userId: int.tryParse(json['user_id'].toString()) ?? 0,

      username: json['username']?.toString() ?? "Unknown",
      fullName: json['full_name']?.toString() ?? "Unknown",

      // প্রোফাইল পিকচার null হতে পারে
      profilePictureUrl: json['profile_picture_url'],

      createdAt: json['created_at']?.toString() ?? "",
    );
  }
}