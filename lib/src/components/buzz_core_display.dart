import 'package:buzzby/src/api/buzz.dart';
import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/components/profile_popup.dart';
import 'package:flutter/material.dart';

class BuzzCoreDisplay extends StatefulWidget {
  final Buzz buzz;
  final bool canTapUsername;
  const BuzzCoreDisplay(
      {super.key, required this.buzz, this.canTapUsername = false});

  @override
  State<BuzzCoreDisplay> createState() => _BuzzCoreDisplayState();
}

class _BuzzCoreDisplayState extends State<BuzzCoreDisplay> {
  bool reactionSending = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.buzz.text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Colors.white,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.canTapUsername
                        ? () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return ProfilePopup(
                                    username: widget.buzz.author,
                                  );
                                });
                          }
                        : null,
                    child: Text(
                      widget.buzz.author,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.buzz.distance.toString().substring(0, 3).removeTrailingPeriod} mi',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getTimeAgoString(
                            DateTime.now().difference(widget.buzz.createdAt)),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.chat_bubble_outline_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.buzz.comments}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonalIcon(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          widget.buzz.reaction == BuzzReaction.like
                              ? Colors.white.withOpacity(0.2)
                              : const Color.fromRGBO(0, 0, 0, 0),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              )),
                        ),
                      ),
                      onPressed: reactionSending
                          ? null
                          : () {
                              setState(() {
                                reactionSending = true;
                              });
                              Buzzby.reactToBuzz(
                                      widget.buzz,
                                      widget.buzz.reaction != BuzzReaction.like
                                          ? BuzzReaction.like
                                          : BuzzReaction.none)
                                  .then((value) => setState(() {
                                        reactionSending = false;
                                      }));
                            },
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: Text(
                        widget.buzz.likes.toString(),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          widget.buzz.reaction == BuzzReaction.dislike
                              ? Colors.white.withOpacity(0.2)
                              : const Color.fromRGBO(0, 0, 0, 0),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              )),
                        ),
                      ),
                      onPressed: reactionSending
                          ? null
                          : () {
                              setState(() {
                                reactionSending = true;
                              });
                              Buzzby.reactToBuzz(
                                      widget.buzz,
                                      widget.buzz.reaction !=
                                              BuzzReaction.dislike
                                          ? BuzzReaction.dislike
                                          : BuzzReaction.none)
                                  .then((value) => setState(() {
                                        reactionSending = false;
                                      }));
                            },
                      icon: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: Text(
                        widget.buzz.dislikes.toString(),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getTimeAgoString(Duration timeDifference) {
    if (timeDifference.inDays > 0) {
      return '${timeDifference.inDays}d';
    } else if (timeDifference.inHours > 0) {
      return '${timeDifference.inHours}h';
    } else if (timeDifference.inMinutes > 0) {
      return '${timeDifference.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}

extension RemoveTrailingPeriod on String {
  String get removeTrailingPeriod =>
      endsWith('.') ? substring(0, length - 1) : this;
}
