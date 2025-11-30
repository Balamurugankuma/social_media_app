import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled14/presentation/repository.dart';
import '../domain/comments.dart';
import '../domain/model.dart';
import '../domain/post.dart';

class Profile extends StatefulWidget {
  final Model? model;

  const Profile({super.key, required this.model});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _commentcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = widget.model;
    final profileUid = user?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: ListView(
        children: [
          const SizedBox(height: 10),

          /// Profile avatar
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
                  ? NetworkImage(user.imageUrl!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: (user?.imageUrl == null || user!.imageUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 60, color: Colors.green)
                  : null,
            ),
          ),

          const SizedBox(height: 10),

          /// Username
          Center(
            child: Text(
              user?.name ?? "No name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          /// Followers - Following - Posts counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder(
                stream: userRepository.getFollowers(profileUid),
                builder: (context, snap) {
                  int count = snap.hasData ? snap.data!.docs.length : 0;
                  return Column(
                    children: [const Text("Followers"), Text("$count")],
                  );
                },
              ),
              StreamBuilder(
                stream: userRepository.getFollowing(profileUid),
                builder: (context, snap) {
                  int count = snap.hasData ? snap.data!.docs.length : 0;
                  return Column(
                    children: [const Text("Following"), Text("$count")],
                  );
                },
              ),
              StreamBuilder(
                stream: postRepository.getUserPosts(profileUid),
                builder: (context, snap) {
                  int count = snap.hasData ? snap.data!.length : 0;
                  return Column(
                    children: [const Text("Posts"), Text("$count")],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Follow button (hide if owner)
          StreamBuilder(
            stream: userRepository.getFollowers(profileUid),
            builder: (context, snap) {
              if (!snap.hasData || currentUid == profileUid)
                return const SizedBox();

              bool isFollowing = snap.data!.docs.any(
                (doc) => doc.id == currentUid,
              );

              return Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? Colors.grey.shade300
                          : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      isFollowing
                          ? await userRepository.unfollowUser(
                              currentUid,
                              profileUid,
                            )
                          : await userRepository.followUser(
                              currentUid,
                              profileUid,
                            );
                    },
                    child: Text(
                      isFollowing ? "Following" : "Follow",
                      style: TextStyle(
                        color: isFollowing ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          const Divider(),

          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text("Posts", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          StreamBuilder<List<Post>>(
            stream: postRepository.getUserPosts(profileUid),
            builder: (context, snap) {
              if (!snap.hasData)
                return const Center(child: Text("No post yet"));
              final posts = snap.data!;
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
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            post.post,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(Icons.favorite),
                              SizedBox(width: 2),
                              StreamBuilder<int>(
                                stream: postRepository.likecount(post.postId),
                                builder: (context, likeCount) {
                                  int count = likeCount.data ?? 0;
                                  return Text('$count');
                                },
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  comments(post.postId);
                                },
                                icon: Icon(Icons.comment_outlined),
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
