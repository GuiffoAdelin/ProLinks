import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'network_screen.dart';
import 'add_post_screen.dart';
import 'feed_screen.dart';
import 'jobs_screen.dart';
import 'search_delegate.dart';
import 'notifications_screen.dart';
import 'invitations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // MODIFICATION : On retire AddPostScreen de la liste car il doit être ouvert en Modal
  final List<Widget> _screens = [
    const FeedScreen(),
    const NetworkScreen(),
    const SizedBox.shrink(), // Placeholder pour l'index 2 (Bouton Add)
    const JobsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color proLinksViolet = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "ProLinks",
          style: TextStyle(
            color: proLinksViolet,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: proLinksViolet),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(auth.token ?? ""),
              );
            },
          ),
        ],
      ),
      drawer: _buildSideMenu(context, auth, isDark),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              // MODIFICATION : Si on clique sur le bouton Add (index 2)
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true, // Apparence de modal
                    builder: (context) => const AddPostScreen(),
                  ),
                );
              } else {
                setState(() => _currentIndex = index);
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: proLinksViolet,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: "Network",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline_rounded, size: 35),
                label: "Add",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_rounded),
                label: "Jobs",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Le reste de votre code (Drawer, buildAvatar) reste identique ---

  Widget _buildSideMenu(BuildContext context, AuthProvider auth, bool isDark) {
    final user = auth.userData;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(user, primaryColor, 32),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${user?['prenom'] ?? ''} ${user?['nom'] ?? 'Utilisateur'}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerItem(
                  icon: Icons.person_outline_rounded,
                  label: "Mon Profil",
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 4);
                  },
                ),
                _drawerItem(
                  icon: Icons.people_outline_rounded,
                  label: "Mon Réseau",
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
                const Divider(),
                _drawerItem(
                  icon: Icons.notifications_none_rounded,
                  label: "Notifications",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.mail_outline_rounded,
                  label: "Mes Invitations",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InvitationsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _drawerItem(
              icon: Icons.logout_rounded,
              label: "Déconnexion",
              color: Colors.redAccent,
              onTap: () => auth.logout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[800], size: 26),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.grey[800],
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Widget _buildAvatar(
    Map<String, dynamic>? user,
    Color primaryColor,
    double radius,
  ) {
    final auth = context
        .watch<AuthProvider>(); // ← on récupère AuthProvider ici
    final photoUrl = user?['photoUrl'];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(
          auth.getFullImageUrl(photoUrl), // ← CORRECTION ICI !
        ),
        child: photoUrl == null || photoUrl.isEmpty
            ? Icon(Icons.person, size: radius, color: primaryColor)
            : null,
      ),
    );
  }
}
