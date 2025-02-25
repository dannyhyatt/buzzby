// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:buzzby/src/api/buzzby.dart';
import 'package:buzzby/src/components/buzz_list.dart';
import 'package:buzzby/src/components/custom_theme_color.dart';
import 'package:buzzby/src/components/name_prompter.dart';
import 'package:buzzby/src/components/new_post.dart';
import 'package:buzzby/src/components/profile_popup.dart';
import 'package:buzzby/src/pages/buzzpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool schoolOnly = false;

  bool oneSignalLoggedIn = false;
  int lastPushedPostPage = -1;

  bool loaded = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    debugPrint('loading');
    // get the username of the user
    if (await Buzzby.getUsername() == null) {
      SchedulerBinding.instance.addPostFrameCallback(
          (_) => showUsernamePrompt(context, (username) async {
                debugPrint('received username: $username');
                await Buzzby.setUsername(username);
                load();
              }));

      return;
    }

    debugPrint('got username');

    CustomThemeSeedBuilder.instanceOf(context)!.changeColor(
        UsernameColor.getFromUsername((await Buzzby.getUsername())!));

    await Buzzby.getLocation();
    debugPrint('got location: ${Buzzby.locationData}');
    setState(() {
      loaded = true;
    });

    if (Platform.isIOS && !oneSignalLoggedIn) initOneSignal();
  }

  void initOneSignal() async {
    debugPrint('initiating one signal');

    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("e5f510b7-1cea-4b8f-ac50-b446bdf4da5f");

    await Future.delayed(const Duration(seconds: 5));

    await OneSignal.login((await Buzzby.getUsername())!);

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.Notifications.requestPermission(true);

    debugPrint('opting in...');
    await OneSignal.User.pushSubscription.optIn();

    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('abc: ${OneSignal.User.pushSubscription.optedIn}');
      debugPrint(OneSignal.User.pushSubscription.id);
      debugPrint(OneSignal.User.pushSubscription.token);
      debugPrint(state.current.jsonRepresentation());
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint("Has permission $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      debugPrint('addl data! ${event.notification}\n\n\n\ndone:');
      debugPrint('raw data:::: ${event.notification.rawPayload}');
      debugPrint(event.jsonRepresentation());
      debugPrint('a : ${ModalRoute.of(context)!.settings.name}');
      debugPrint('b : ${ModalRoute.of(context)!.settings.arguments}');
      debugPrint('c : ${event.notification.additionalData}');
      // check if it has a post associated with it to go to
      if (event.notification.additionalData != null &&
          event.notification.additionalData!.containsKey('post_id') &&
          // and check if the app is not already there

          (ModalRoute.of(context)!.settings.name != BuzzPage.routeName ||
              ModalRoute.of(context)!.settings.arguments !=
                  event.notification.additionalData!['post_id']) &&

          // and check in case this is called multiple times in sequence
          lastPushedPostPage != event.notification.additionalData!['post_id']) {
        Navigator.pushNamed(context, BuzzPage.routeName,
            arguments: event.notification.additionalData!['post_id']);
        lastPushedPostPage = event.notification.additionalData!['post_id'];
      }
    });

    oneSignalLoggedIn = true;
    debugPrint('done!');
  }

  void showUsernamePrompt(
      BuildContext context, Function(String) onFinished) async {
    final username = await showDialog(
        context: context, builder: (context) => const NamePrompter());
    onFinished(username);
  }

  String getDomain() {
    List<String> emails = Supabase.instance.client.auth.currentUser!.email!
        .split('@')[1]
        .split('.');
    String domain = '${emails[emails.length - 2]}.${emails[emails.length - 1]}';
    return domain;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'the buzz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (Supabase.instance.client.auth.currentUser!.email!
              .endsWith('.edu'))
            Directionality(
              textDirection: TextDirection.rtl,
              child: schoolOnly
                  ? FilledButton.icon(
                      onPressed: () {
                        schoolOnly = false;
                        load();
                      },
                      label: Text(getDomain()),
                      icon: const Icon(Icons.school))
                  : FilledButton.tonalIcon(
                      onPressed: () {
                        schoolOnly = true;
                        load();
                      },
                      label: Text(getDomain()),
                      icon: const Icon(Icons.school)),
            ),
          IconButton(
              onPressed: () {
                Buzzby.getUsername().then((username) {
                  debugPrint('got : $username');
                  if (username != null) {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return ProfilePopup(
                            username: username,
                          );
                        });
                  }
                });
              },
              icon: const Icon(Icons.person))
        ],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator.adaptive())
          : BuzzList(
              showAds: true,
              getPosts: (offset) => Buzzby.getPosts(withDomain: schoolOnly)),
      floatingActionButton: !loaded
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return NewPost(
                        onPost: () {
                          debugPrint('refreshing');
                          setState(() {
                            loaded = false;
                          });

                          Buzzby.getPosts().then((value) => setState(() {
                                loaded = true;
                              }));
                        },
                      );
                    });
              },
              child: const Icon(Icons.add)),
    );
  }
}
