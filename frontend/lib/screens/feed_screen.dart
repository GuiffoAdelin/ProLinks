import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PostProvider>(context, listen: false).fetchPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => postProvider.fetchPosts(),
        child: postProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : postProvider.posts.isEmpty
            ? const Center(child: Text("Aucune publication pour le moment"))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: postProvider.posts.length,
                itemBuilder: (context, index) {
                  final post = postProvider.posts[index];
                  final author = post['author'] ?? {};
                  final List likes = post['likes'] ?? [];
                  final String currentUserId =
                      authProvider.userData?['_id'] ?? "";
                  final bool isLiked = likes.contains(currentUserId);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    elevation: 0,
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              authProvider.getFullImageUrl(
                                author['photoUrl'],
                              ), // ← Correction ici
                            ),
                          ),
                          title: Text(
                            "${author['prenom'] ?? 'Membre'} ${author['nom'] ?? ''}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            author['headline'] ?? "Membre ProLinks",
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            post['content'] ?? "",
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),

                        if (post['image'] != null &&
                            post['image'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                postProvider.getImageUrl(post['image']),
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),

                        Divider(color: theme.dividerColor),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              _buildActionButton(
                                icon: isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                label: "${likes.length} J'aime",
                                color: isLiked ? Colors.blue : Colors.grey,
                                onTap: () async {
                                  await postProvider.toggleLike(
                                    post['_id'],
                                    authProvider.token ?? "",
                                  );
                                  await postProvider.fetchPosts();
                                },
                              ),
                              const SizedBox(width: 16),
                              _buildActionButton(
                                icon: Icons.chat_bubble_outline_rounded,
                                label:
                                    "${post['comments']?.length ?? 0} commentaires",
                                color: Colors.grey,
                                onTap: () => _showCommentDialog(context, post),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context, dynamic post) {
    final commentController = TextEditingController();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Écris ton commentaire...",
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.trim().isNotEmpty) {
                    await postProvider.addComment(
                      post['_id'],
                      commentController.text.trim(),
                      auth.token ?? "",
                    );
                    await postProvider.fetchPosts();
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Envoyer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
