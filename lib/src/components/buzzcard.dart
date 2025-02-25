import 'package:buzzby/src/api/buzz.dart';
import 'package:buzzby/src/components/buzz_core_display.dart';
import 'package:buzzby/src/pages/buzzpage.dart';
import 'package:flutter/material.dart';

class BuzzCard extends StatefulWidget {
  final Buzz buzz;
  final void Function(int) onReplyAdded;
  const BuzzCard({super.key, required this.buzz, required this.onReplyAdded});

  @override
  State<BuzzCard> createState() => _BuzzCardState();
}

class _BuzzCardState extends State<BuzzCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) => BuzzPage(
                      buzz: widget.buzz,
                      onReplyAdded: widget.onReplyAdded,
                    )))
            .then((value) => setState(() {})),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BuzzCoreDisplay(buzz: widget.buzz)),
        ),
      ),
    );
  }
}
