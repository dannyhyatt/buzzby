// ignore_for_file: unnecessary_null_comparison

import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/components/buzz_list.dart';
import 'package:buzzby/src/components/custom_theme_color.dart';
import 'package:flutter/material.dart';

class ProfilePopup extends StatefulWidget {
  final String username;
  const ProfilePopup({super.key, required this.username});

  @override
  _ProfilePopupState createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: (MediaQuery.sizeOf(context).height - 56) /
          MediaQuery.sizeOf(context).height,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
              title: Text(
                '${widget.username}\'s Posts',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: widget.username != Buzzby.username
                  ? []
                  : [
                      IconButton(
                        onPressed: () {
                          Buzzby.logout().then((_) {
                            CustomThemeSeed.of(context)!
                                .customThemeSeedBuilderState
                                .changeColor(Colors.purple);
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          });
                        },
                        icon: Icon(
                          Icons.logout,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
            ),
            body: BuzzList(
                getPosts: (offset) =>
                    Buzzby.getPostsByUsername(username: widget.username))),
      ),
    );
  }
}
