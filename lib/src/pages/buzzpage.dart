import 'package:buzzby/src/api/buzz.dart';
import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/api/comment.dart';
import 'package:buzzby/src/components/buzz_core_display.dart';
import 'package:buzzby/src/components/comment_list.dart';
import 'package:flutter/material.dart';

class BuzzPage extends StatefulWidget {
  static const String routeName = '/buzz';

  final void Function(int) onReplyAdded;
  final Buzz buzz;
  const BuzzPage({super.key, required this.buzz, required this.onReplyAdded});

  @override
  State<BuzzPage> createState() => _BuzzPageState();
}

class _BuzzPageState extends State<BuzzPage> {
  bool commentsExpanded = false;
  Comment? replyingTo;
  FocusNode commentFocusNode = FocusNode();
  TextEditingController commentController = TextEditingController();

  void submitComment() {
    Buzzby.postComment(widget.buzz, commentController.text, replyingTo?.id)
        .then((_) {
      widget.onReplyAdded(++widget.buzz.comments);
      setState(() {
        commentController.text = '';
        replyingTo = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: Listener(
        onPointerDown: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BuzzCoreDisplay(
                  buzz: widget.buzz,
                  canTapUsername: true,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 128),
                  child: CommentList(
                    postId: widget.buzz.id,
                    onReplyTo: (comment) => setState(() {
                      replyingTo = comment;
                      commentFocusNode.requestFocus();
                    }),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 72,
                )
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SizedBox(
          height: MediaQuery.of(context).viewPadding.bottom +
              (MediaQuery.of(context).viewInsets.bottom / 2 > 0 ? 52 : 72) +
              (replyingTo == null ? 0 : 32),
          child: addCommentsField(context)),
    );
  }

  Widget addCommentsField(BuildContext context) {
    return SafeArea(
      child: Padding(
          padding: EdgeInsets.only(
              bottom: 8, left: 8, right: 8, top: replyingTo == null ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyingTo != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'replying to ${replyingTo!.author}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => replyingTo = null),
                        child: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextField(
                        controller: commentController,
                        focusNode: commentFocusNode,
                        minLines: 1,
                        maxLines: 1,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none)),
                        onSubmitted: (value) {
                          submitComment();
                        }),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: submitComment,
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.send),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }
}
