import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/pages/buzzpage.dart';

import '../api/buzz.dart';
import 'package:flutter/material.dart';

class BuzzPageLoader extends StatefulWidget {
  final int buzzId;
  const BuzzPageLoader({super.key, required this.buzzId});

  @override
  State<BuzzPageLoader> createState() => _BuzzPageLoaderState();
}

class _BuzzPageLoaderState extends State<BuzzPageLoader> {
  Buzz? buzz;

  @override
  void initState() {
    super.initState();
    Buzzby.getPostById(id: widget.buzzId)
        .then((value) => setState(() => buzz = value));
  }

  @override
  Widget build(BuildContext context) {
    if (buzz != null) {
      return BuzzPage(
        buzz: buzz!,
        onReplyAdded: (_) {},
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
