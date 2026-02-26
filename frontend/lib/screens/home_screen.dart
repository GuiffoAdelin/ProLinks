import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// 1. AJOUTE TES IMPORTS ICI (Vérifie bien les noms de fichiers)
import 'profile_screen.dart';
import 'network_screen.dart';
import 'add_post_screen.dart';
import 'feed_screen.dart';
import 'jobs_screen.dart';
import 'search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 2. Liste des écrans mise à jour
  final List<Widget> _screens = [
    const FeedScreen(), // Index 0
    const NetworkScreen(), // Index 1
    const AddPostScreen(), // Index 2
    const JobsScreen(), // Index 3
    const ProfileScreen(), // Index 4
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
        // On remplace le leading manuel par le bouton du Drawer automatique
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
      // 3. APPEL DU DRAWER
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
            onTap: (index) => setState(() => _currentIndex = index),
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

  // --- MÉTHODES DE CONSTRUCTION ---

  Widget _buildSideMenu(BuildContext context, AuthProvider auth, bool isDark) {
    final user = auth.userData;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            currentAccountPicture: _buildAvatar(user, Colors.white),
            accountName: Text(
              "${user?['prenom'] ?? ''} ${user?['nom'] ?? 'Utilisateur'}",
            ),
            accountEmail: Text(user?['email'] ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Mon Profil"),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text("Mon Réseau"),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDark ? "Mode Clair" : "Mode Sombre"),
            onTap: () {},
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Déconnexion",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => auth.logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic>? user, Color color) {
    final photoUrl = user?['photoUrl'];
    return CircleAvatar(
      backgroundColor: Colors.white24,
      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
          ? NetworkImage(photoUrl)
          : null,
      child: (photoUrl == null || photoUrl.isEmpty)
          ? const Icon(Icons.person, color: Colors.white)
          : null,
    );
  }
}
