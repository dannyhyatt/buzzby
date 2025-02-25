class Comment {
  final int id, postId;
  final String author, text;
  int directReplies, totalReplies;
  final int likes, dislikes;
  final DateTime createdAt;
  final int? replyTo;

  Comment(
      {required this.id,
      required this.postId,
      required this.author,
      required this.text,
      required this.directReplies,
      required this.totalReplies,
      required this.likes,
      required this.dislikes,
      required this.createdAt,
      required this.replyTo});

  static Comment fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      author: json['author'],
      text: json['content'],
      directReplies: json['direct_replies'],
      totalReplies: json['total_replies'],
      likes: json['likes'],
      dislikes: json['dislikes'],
      createdAt: DateTime.parse(json['created_at']),
      replyTo: json['reply_to'],
    );
  }
}
