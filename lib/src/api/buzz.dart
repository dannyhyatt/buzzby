enum BuzzReaction { like, dislike, none }

class Buzz {
  final int id;
  final String text;
  final String author;
  final String? domain;
  int likes, dislikes;
  final double distance;
  int comments;
  final DateTime createdAt;
  BuzzReaction reaction;

  // final int likes, dislikes;
  // bool liked = false, disliked = false;

  Buzz(
      {required this.id,
      required this.text,
      required this.author,
      required this.distance,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.comments,
      required this.reaction,
      this.domain});

  static Buzz fromJson(Map<String, dynamic> json) {
    if (json['dist'] is int) {
      json['dist'] = json['dist'].toDouble();
    }

    return Buzz(
      id: json['id'],
      text: json['content'],
      author: json['author'],
      domain: json['domain'],
      distance: json['dist'],
      comments: json['comments'],
      likes: json['likes'],
      dislikes: json['dislikes'],
      reaction: json['liked_reaction'] == null
          ? BuzzReaction.none
          : json['liked_reaction'] == true
              ? BuzzReaction.like
              : BuzzReaction.dislike,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Buzz copyWith(
          {int? id,
          String? author,
          String? text,
          String? domain,
          double? distance,
          int? comments,
          int? likes,
          int? dislikes,
          BuzzReaction? reaction,
          DateTime? createdAt}) =>
      Buzz(
        id: id ?? this.id,
        author: author ?? this.author,
        text: text ?? this.text,
        domain: domain ?? this.domain,
        distance: distance ?? this.distance,
        comments: comments ?? this.comments,
        likes: likes ?? this.likes,
        dislikes: dislikes ?? this.dislikes,
        reaction: reaction ?? this.reaction,
        createdAt: createdAt ?? this.createdAt,
      );
}
