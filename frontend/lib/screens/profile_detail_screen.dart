import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color purpleDGN = Color(0xFF6A1B9A);

    // Sécurité pour les listes
    final List skills = user['skills'] is List ? user['skills'] : [];
    final List experiences = user['experience'] is List
        ? user['experience']
        : [];
    final List educations = user['education'] is List ? user['education'] : [];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text("${user['prenom'] ?? ''} ${user['nom'] ?? ''}"),
        backgroundColor: purpleDGN,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AVEC DÉGRADÉ ---
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (user['photoUrl'] != null &&
                              user['photoUrl'].toString().isNotEmpty)
                          ? NetworkImage(user['photoUrl'])
                          : null,
                      child:
                          (user['photoUrl'] == null ||
                              user['photoUrl'].toString().isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INFOS DE BASE ---
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "${user['prenom'] ?? ''} ${user['nom'] ?? ''}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['headline'] ?? "Membre ProLinks",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            Text(
                              " ${user['location'] ?? 'Cameroun'}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 40),

                  // --- COMPÉTENCES (Chips) ---
                  _buildSectionTitle(
                    Icons.star_outline,
                    "Compétences",
                    purpleDGN,
                  ),
                  if (skills.isEmpty)
                    const Text(
                      "Aucune compétence listée.",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      children: skills
                          .map(
                            (s) => Chip(
                              label: Text(s.toString()),
                              backgroundColor: purpleDGN.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                color: purpleDGN,
                                fontWeight: FontWeight.bold,
                              ),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 30),

                  // --- EXPÉRIENCES ---
                  _buildSectionTitle(
                    Icons.work_outline,
                    "Expérience",
                    purpleDGN,
                  ),
                  if (experiences.isEmpty)
                    const Text("Pas d'expérience renseignée.")
                  else
                    ...experiences.map(
                      (exp) => _buildDataCard(
                        title: exp['position'] ?? 'Poste',
                        subtitle: exp['company'] ?? 'Entreprise',
                        date:
                            "${exp['startDate'] ?? ''} - ${exp['endDate'] ?? 'Présent'}",
                        icon: Icons.business,
                      ),
                    ),

                  const SizedBox(height: 30),

                  // --- FORMATIONS ---
                  _buildSectionTitle(
                    Icons.school_outlined,
                    "Formation",
                    purpleDGN,
                  ),
                  if (educations.isEmpty)
                    const Text("Pas de formation renseignée.")
                  else
                    ...educations.map(
                      (edu) => _buildDataCard(
                        title: edu['degree'] ?? 'Diplôme',
                        subtitle: edu['school'] ?? 'École',
                        date:
                            "${edu['startYear'] ?? ''} - ${edu['endYear'] ?? ''}",
                        icon: Icons.book,
                      ),
                    ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.05),
          child: Icon(icon, color: Colors.purple, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          date,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
    );
  }
}
