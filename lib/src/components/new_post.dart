import 'package:buzzby/src/api/buzzby.dart';
import 'package:flutter/material.dart';

class NewPost extends StatefulWidget {
  final Function() onPost;
  const NewPost({Key? key, required this.onPost}) : super(key: key);
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final TextEditingController _textEditingController = TextEditingController();

  bool sending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textEditingController,
                maxLength: 280,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                minLines: 4,
              ),
              const SizedBox(height: 16.0),
              FilledButton.tonal(
                onPressed: sending
                    ? null
                    : () async {
                        setState(() {
                          sending = true;
                        });
                        debugPrint(_textEditingController.text);

                        String? username = await Buzzby.getUsername();

                        if (username == null) {
                          setState(() {
                            sending = false;
                          });
                        } else {
                          await Buzzby.postBuzz(_textEditingController.text);
                          widget.onPost();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Posted!'),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        }

                        // if (mounted) Navigator.of(context).pop();
                      },
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
