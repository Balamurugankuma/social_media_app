import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:untitled14/presentation/repository.dart';
import '../domain/comments.dart';
import '../domain/model.dart';
import '../domain/post.dart';

class Userprofile extends StatefulWidget {
  final Model? model;

  const Userprofile({super.key, required this.model});

  @override
  State<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  File? image;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _postcontroller = TextEditingController();
  final TextEditingController _commentcontroller = TextEditingController();

  @override
  void dispose() {
    _postcontroller.dispose();
    _commentcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.model;
    final profileUid = user?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // PROFILE IMAGE
          Center(
            child: GestureDetector(
              onTap: currentUid == profileUid ? editprofile : null,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
                    ? NetworkImage(user!.imageUrl!)
                    : null,
                backgroundColor: Colors.grey.shade300,
                child: (user?.imageUrl == null || user!.imageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 60, color: Colors.green)
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // NAME
          Center(
            child: Text(
              user?.name ?? "No name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // FOLLOWERS / FOLLOWING / POSTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder(
                stream: userRepository.getFollowers(profileUid),
                builder: (context, snapshot) {
                  final count = snapshot.hasData
                      ? snapshot.data!.docs.length
                      : 0;
                  return Column(
                    children: [const Text("Followers"), Text("$count")],
                  );
                },
              ),
              StreamBuilder(
                stream: userRepository.getFollowing(profileUid),
                builder: (context, snapshot) {
                  final count = snapshot.hasData
                      ? snapshot.data!.docs.length
                      : 0;
                  return Column(
                    children: [const Text("Following"), Text("$count")],
                  );
                },
              ),
              StreamBuilder<List<Post>>(
                stream: postRepository.getUserPosts(profileUid),
                builder: (context, snapshot) {
                  final count = snapshot.hasData ? snapshot.data!.length : 0;
                  return Column(
                    children: [const Text("Posts"), Text("$count")],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),

          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text("Posts", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          // POSTS LIST
          StreamBuilder<List<Post>>(
            stream: postRepository.getUserPosts(profileUid),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: Text("No post yet"));
              final posts = snapshot.data!;
              if (posts.isEmpty)
                return const Center(child: Text("No post yet"));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(post.post, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.favorite),
                              const SizedBox(width: 2),
                              StreamBuilder<int>(
                                stream: postRepository.likecount(post.postId),
                                builder: (context, likeCount) {
                                  int count = likeCount.data ?? 0;
                                  return Text('$count');
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => comments(post.postId),
                                icon: const Icon(Icons.comment_outlined),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createpost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> editprofile() async {
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      openAppSettings();
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => image = File(picked.path));
    final newUrl = await userRepository.uploadImage(image!, currentUid);
    setState(() => widget.model?.imageUrl = newUrl);
  }

  Future<void> createpost() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: _postcontroller,
            decoration: const InputDecoration(labelText: 'Post'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _postcontroller.clear();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                postRepository.createPost(
                  uid: currentUid,
                  post: _postcontroller.text.trim(),
                );
                Navigator.pop(context);
                _postcontroller.clear();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Post uploaded")));
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> comments(postId) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // COMMENTS LIST
              Expanded(
                child: StreamBuilder<List<Comments>>(
                  stream: postRepository.getCommets(postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final data = snapshot.data!;
                    if (data.isEmpty)
                      return const Center(child: Text("No comments yet"));

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final comment = data[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(comment.userName ?? "Unknown"),
                          subtitle: Text(comment.comments),
                        );
                      },
                    );
                  },
                ),
              ),

              // TEXTFIELD + SEND BUTTON
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentcontroller,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (_commentcontroller.text.trim().isEmpty) return;
                        final userName = widget.model?.name ?? "User";

                        await postRepository.comments(
                          postId,
                          userName,
                          currentUid,
                          _commentcontroller.text.trim(),
                        );

                        _commentcontroller.clear();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }
}
