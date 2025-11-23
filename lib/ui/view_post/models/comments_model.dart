class CommentModel {
  final int commentId;
  final String commentText;
  final String createdAt;
  final int userId;
  final String username;
  final String fullName;
  final String? profilePictureUrl;

  // এগুলো যদি API থেকে না আসে, তবে অপশনাল রাখুন
  final String? like_count;
  final String? comment_count;

  CommentModel({
    required this.commentId,
    required this.commentText,
    required this.createdAt,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    this.like_count,
    this.comment_count,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      // .toString() ব্যবহার করা নিরাপদ
      commentId: int.tryParse(json['comment_id'].toString()) ?? 0,
      commentText: json['comment_text']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username']?.toString() ?? "Unknown",
      fullName: json['full_name']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture_url'],

      like_count: json['like_count']?.toString(),
      comment_count: json['comment_count']?.toString(),
    );
  }
}