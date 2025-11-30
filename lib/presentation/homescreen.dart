import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled14/domain/comments.dart';
import 'package:untitled14/presentation/profile.dart';
import 'package:untitled14/presentation/repository.dart';
import 'package:untitled14/presentation/userprofile.dart';
import '../domain/post.dart';
import '../domain/model.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Model? currentUser;
  final TextEditingController _commentcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    currentUser = await userRepository.getCurrentUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Feed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<List<Post>>(
        stream: postRepository.getAllPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final posts = snapshot.data!;
          if (posts.isEmpty) return const Center(child: Text("No posts yet"));
          posts.shuffle();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return FutureBuilder<Model?>(
                future: userRepository.getUserById(post.ownerId),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final user = snap.data;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Profile(model: user),
                                      ),
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundImage:
                                      (user?.imageUrl != null &&
                                          user!.imageUrl!.isNotEmpty)
                                      ? NetworkImage(user.imageUrl!)
                                      : null,
                                  child:
                                      (user?.imageUrl == null ||
                                          user!.imageUrl!.isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Profile(model: user),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  user?.name ?? "User",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(post.post, style: const TextStyle(fontSize: 16)),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              StreamBuilder<bool>(
                                stream: postRepository.postlike(
                                  post.postId,
                                  FirebaseAuth.instance.currentUser!.uid,
                                ),
                                builder: (context, likeSnap) {
                                  bool liked = likeSnap.data ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: liked ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      liked
                                          ? postRepository.Unlike(
                                              post.postId,
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                            )
                                          : postRepository.Like(
                                              post.postId,
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                            );
                                    },
                                  );
                                },
                              ),
                              StreamBuilder<int>(
                                stream: postRepository.likecount(post.postId),
                                builder: (context, countSnap) {
                                  int likes = countSnap.data ?? 0;
                                  return Text("$likes likes");
                                },
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  comments(post.postId, user);
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
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 1) {
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please wait... loading profile")),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Userprofile(model: currentUser),
              ),
            ).then((_) => loadCurrentUser());
          }
        },
      ),
    );
  }

  Future<void> comments(postId, Model? user) async {
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
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data!;
                    if (data.isEmpty) {
                      return const Center(child: Text("No comments yet"));
                    }

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
                        final userName = user?.name ?? "User";

                        await postRepository.comments(
                          postId,
                          userName,
                          user!.uid!,
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
