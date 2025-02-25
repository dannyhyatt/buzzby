import 'dart:async';

import 'package:buzzby/src/api/buzz.dart';
import 'package:buzzby/src/api/comment.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Buzzby {
  static String? username;

  static LocationData? locationData;

  static Map<int?, StreamController<Comment>> commentListenerStreams = {};
  static Map<int?, List<void Function(Comment)>> commentListenerCallbacks = {};

  static Future<void> logout() {
    username = null;
    return Future.wait(
        [OneSignal.logout(), Supabase.instance.client.auth.signOut()]);
  }

  static Future<String?> getUsername() async {
    if (username != null) {
      return username;
    }

    final response = await Supabase.instance.client.rest
        .from('usernames')
        .select('*')
        .eq('id', Supabase.instance.client.auth.currentUser!.id)
        .limit(1);

    debugPrint('got $response');

    if (response.length == 0) {
      return null;
    }

    username = response[0]['username'];

    return username;
  }

  static Future<void> setUsername(String username) async {
    await Supabase.instance.client.rest.from('usernames').insert({
      'id': Supabase.instance.client.auth.currentUser!.id,
      'username': username
    });

    debugPrint('set username to $username');
  }

  static Future<void> postBuzz(final String text) async {
    String? author = await getUsername();
    LocationData location = await getLocation();
    if (username == null) {
      return;
    }
    String? domain;
    if (Supabase.instance.client.auth.currentUser!.email!.endsWith('.edu')) {
      List<String> emails = Supabase.instance.client.auth.currentUser!.email!
          .split('@')[1]
          .split('.');
      domain = '${emails[emails.length - 2]}.${emails[emails.length - 1]}';
    }

    return Supabase.instance.client.rest.rpc('create_post', params: {
      'p_content': text,
      'p_author': author!,
      'p_domain': domain,
      'lat': location.latitude,
      'lng': location.longitude,
    });
  }

  static Future<LocationData> getLocation() async {
    if (locationData != null) {
      return locationData!;
    }

    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Error();
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Error();
      }
    }

    locationData = await location.getLocation();
    return locationData!;
  }

  static Future<List<Buzz>> getPosts({bool withDomain = true}) async {
    LocationData location = await getLocation();
    String? domain;
    if (Supabase.instance.client.auth.currentUser!.email!.endsWith('.edu')) {
      List<String> emails = Supabase.instance.client.auth.currentUser!.email!
          .split('@')[1]
          .split('.');
      domain = '${emails[emails.length - 2]}.${emails[emails.length - 1]}';
    }

    final Map<String, dynamic> params = {
      'lat': location.latitude,
      'lng': location.longitude,
    };

    if (withDomain) {
      params['p_domain'] = domain;
    }

    final response = await Supabase.instance.client.rest
            .rpc(withDomain ? 'get_posts_domain' : 'get_posts', params: params)
        as List<dynamic>;

    debugPrint('received these posts: $response');

    return response.map((e) => Buzz.fromJson(e)).toList();
  }

  static Future<List<Buzz>> getPostsByUsername(
      {required String username}) async {
    LocationData location = await getLocation();

    final response =
        await Supabase.instance.client.rest.rpc('get_posts_username', params: {
      'p_username': username,
      'lat': location.latitude,
      'lng': location.longitude,
    }) as List<dynamic>;

    debugPrint('received these posts: $response');

    return response.map((e) => Buzz.fromJson(e)).toList();
  }

  static Future<void> reactToBuzz(Buzz buzz, BuzzReaction reaction) async {
    if (buzz.reaction == reaction) {
      return;
    }

    // if the reaction is none, delete the reaction
    if (reaction == BuzzReaction.none) {
      await _deleteReaction(buzz);
      // if the old reaction was none, insert the reaction
    } else if (buzz.reaction == BuzzReaction.none) {
      await _insertReaction(buzz, reaction);
      // if the old reaction was a like or dislike,
      // and it is changing to a like or dislike, update the reaction
    } else {
      debugPrint('updating reaction from ${buzz.reaction} to $reaction');
      await _updateReaction(buzz, reaction);
    }

    // buzz.reaction is the old reaction, it will change
    if (buzz.reaction == BuzzReaction.like) {
      buzz.likes--;
    } else if (buzz.reaction == BuzzReaction.dislike) {
      buzz.dislikes--;
    }

    if (reaction == BuzzReaction.like) {
      buzz.likes++;
    } else if (reaction == BuzzReaction.dislike) {
      buzz.dislikes++;
    }

    buzz.reaction = reaction;
  }

  static Future<void> _insertReaction(Buzz buzz, BuzzReaction reaction) {
    return Supabase.instance.client.rest.from('reactions').insert({
      'post_id': buzz.id,
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'is_like': reaction == BuzzReaction.like,
    });
  }

  static Future<void> _updateReaction(Buzz buzz, BuzzReaction reaction) {
    return Supabase.instance.client.rest.from('reactions').update({
      'is_like': reaction == BuzzReaction.like ? 'true' : 'false',
    }).match({
      'post_id': buzz.id,
      'user_id': Supabase.instance.client.auth.currentUser!.id
    });
  }

  static Future<void> _deleteReaction(Buzz buzz) {
    return Supabase.instance.client.rest.from('reactions').delete().match({
      'post_id': buzz.id,
      'user_id': Supabase.instance.client.auth.currentUser!.id
    });
  }

  static Future<Buzz> getPostById({required int id}) async {
    LocationData location = await getLocation();

    final response =
        await Supabase.instance.client.rest.rpc('get_post_id', params: {
      'p_id': id,
      'lat': location.latitude,
      'lng': location.longitude,
    }) as List<dynamic>;

    debugPrint('received these posts: $response');

    return Buzz.fromJson(response[0]);
  }

  static Future<void> postComment(Buzz buzz, String text, int? replyTo) async {
    String? author = await getUsername();
    if (username == null) {
      return;
    }

    final response = await Supabase.instance.client.rest
        .from('comments')
        .insert({
      'post_id': buzz.id,
      'author': author!,
      'content': text,
      'reply_to': replyTo
    }).select();

    debugPrint('received: $response');
    Comment comment = Comment.fromJson(response[0]);

    commentListenerStreams[replyTo]?.add(comment);
  }

  static Future<List<Comment>> loadComments(int postId, int? replyTo) async {
    debugPrint('loading comments for $postId, $replyTo');
    dynamic request = Supabase.instance.client.rest
        .from('comments')
        .select('*')
        .eq('post_id', postId);

    if (replyTo != null) {
      request = request.eq('reply_to', replyTo);
    } else {
      request = request.is_('reply_to', null);
    }
    request = request.order('created_at', ascending: true);

    final response = await request;

    debugPrint('got $response');

    return response.map<Comment>((e) => Comment.fromJson(e)).toList();
  }

  static void addNewReplyListener(int? id, void Function(Comment) callback) {
    debugPrint('adding new reply listener for $id');
    if (commentListenerStreams[id] == null) {
      commentListenerStreams[id] = StreamController();
      commentListenerStreams[id]!.stream.listen((Comment comment) {
        for (Function(Comment) element in commentListenerCallbacks[id]!) {
          element(comment);
        }
      });
    }
    if (commentListenerCallbacks[id] == null) {
      commentListenerCallbacks[id] = [];
    }

    commentListenerCallbacks[id]!.add(callback);
  }

  static void removeNewReplyListener(int? id) {
    commentListenerCallbacks.remove(id);
    commentListenerStreams.remove(id);
  }

  static Future<void> deleteComment(Comment comment) {
    return Supabase.instance.client.rest
        .from('comments')
        .delete()
        .eq('id', comment.id);
  }
}
