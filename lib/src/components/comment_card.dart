import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/api/comment.dart';
import 'package:buzzby/src/components/comment_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum CommentCardState { collapsed, regular, expanded, deleted }

class CommentCard extends StatefulWidget {
  final Function(Comment) onReplyTo;
  final Comment comment;

  const CommentCard({Key? key, required this.comment, required this.onReplyTo})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard>
    with AutomaticKeepAliveClientMixin {
  CommentCardState cardState = CommentCardState.regular;

  @override
  void initState() {
    super.initState();
    Buzzby.addNewReplyListener(widget.comment.id, (newReply) {
      debugPrint('incrementing commmm');
      if (mounted) {
        setState(() {
          widget.comment.directReplies++;
          widget.comment.totalReplies++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (cardState == CommentCardState.deleted) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    return GestureDetector(
      onTap: () => setState(() {
        if (cardState == CommentCardState.collapsed) {
          cardState = CommentCardState.regular;
        } else if (cardState == CommentCardState.regular) {
          cardState = CommentCardState.expanded;
        } else if (cardState == CommentCardState.expanded) {
          cardState = CommentCardState.regular;
        }
      }),
      onLongPressEnd: (_) => showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Buzzby.deleteComment(widget.comment)
                          .then((value) => setState(() {
                                cardState = CommentCardState.deleted;
                              }));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              )),
      onDoubleTap: () => setState(() => cardState = CommentCardState.collapsed),
      child: Card(
        color: Colors.black.withOpacity(0.2),
        borderOnForeground: true,
        elevation: 0,
        margin: EdgeInsets.fromLTRB(
            8,
            cardState == CommentCardState.collapsed ? 2 : 4,
            2,
            cardState == CommentCardState.collapsed ? 2 : 4),
        child: AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cardState == CommentCardState.regular ||
                        cardState == CommentCardState.expanded)
                      Text(
                        widget.comment.text,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white), // Set the text color to white
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.comment.author,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: FilledButton(
                            onPressed: () {
                              if (cardState == CommentCardState.collapsed) {
                                setState(() {
                                  cardState = CommentCardState.regular;
                                });
                              } else {
                                widget.onReplyTo(widget.comment);

                                setState(() {
                                  cardState = CommentCardState.expanded;
                                });
                              }
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.all(0),
                              ),
                              minimumSize: MaterialStateProperty.all(
                                const Size.square(
                                    28), // Adjust the size as needed
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Adjust the border radius as needed
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.reply,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.comment.directReplies > 0)
                          Text(
                            '${widget.comment.directReplies} ${widget.comment.directReplies == 1 ? 'reply' : 'replies'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: cardState == CommentCardState.expanded ? null : 0,
                child: CommentList(
                  key: ValueKey('${widget.comment.id}-replies'),
                  isReplyList: true,
                  postId: widget.comment.postId,
                  replyId: widget.comment.id,
                  onReplyTo: (comment) {
                    widget.onReplyTo(comment);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
