import 'package:buzzby/src/api/buzz.dart';
import 'package:buzzby/src/components/banner_ad_card.dart';
import 'package:buzzby/src/components/buzzcard.dart';
import 'package:flutter/material.dart';

class BuzzList extends StatefulWidget {
  final Future<List<Buzz>> Function(int offset) getPosts;
  final bool showAds;
  const BuzzList({super.key, required this.getPosts, this.showAds = false});

  @override
  State<BuzzList> createState() => _BuzzListState();
}

class _BuzzListState extends State<BuzzList> {
  bool loaded = false;
  List<Buzz> posts = [];

  Map<int, int> replies = {};

  @override
  void initState() {
    super.initState();
    widget.getPosts(0).then((value) => setState(() {
          posts = value;
          loaded = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet!'));
    }

    return RefreshIndicator.adaptive(
        onRefresh: () async {
          setState(() {
            loaded = false;
          });
          posts = await widget.getPosts(0);
          setState(() {
            loaded = true;
          });
        },
        child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              if (widget.showAds) {
                if (index != 0 && index % 6 == 0) {
                  return const BannerAdCard();
                } else {
                  index = index - (index / 6).floor();
                }
              }
              return BuzzCard(
                  buzz: posts[index].copyWith(
                      comments: posts[index].comments +
                          (replies[posts[index].id] ?? 0)),
                  onReplyAdded: (value) {
                    setState(() {
                      replies[posts[index].id] = value;
                    });
                  });
            }));
  }
}
