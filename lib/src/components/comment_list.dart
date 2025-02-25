import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/api/comment.dart';
import 'package:buzzby/src/components/comment_card.dart';
import 'package:flutter/material.dart';

class CommentList extends StatefulWidget {
  final int postId;
  final int? replyId;
  final Function(Comment) onReplyTo;
  final bool isReplyList;
  final bool expanded;
  const CommentList(
      {super.key,
      required this.postId,
      required this.onReplyTo,
      this.replyId,
      this.isReplyList = false,
      this.expanded = true});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList>
    with AutomaticKeepAliveClientMixin {
  bool loaded = false;
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    Buzzby.loadComments(widget.postId, widget.replyId)
        .then((value) => setState(() {
              comments = value;
              loaded = true;
            }));

    Buzzby.addNewReplyListener(widget.replyId, (newReply) {
      debugPrint('comment list got new reply');
      if (mounted) {
        setState(() {
          comments.insert(0, newReply);
        });
      }
    });
  }

  @override
  void dispose() {
    Buzzby.removeNewReplyListener(widget.replyId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!loaded) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (comments.isEmpty && !widget.isReplyList) {
      return const Center(
          child:
              Text('No comments yet!', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: comments.length,
        itemBuilder: (BuildContext context, int index) {
          return CommentCard(
              comment: comments[index],
              onReplyTo: (comment) {
                setState(() {
                  widget.onReplyTo(comment);
                });
              });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
