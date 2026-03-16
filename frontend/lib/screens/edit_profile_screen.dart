import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _headlineController;
  late TextEditingController _locationController;
  late TextEditingController
  _skillsController; // ← Controller dédié compétences

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  List<String> _skills = [];
  List<Map<String, dynamic>> _experience = [];
  List<Map<String, dynamic>> _education = [];

  bool _isLoading = false;

  final Color _purple = const Color(0xFF6A1B9A);
  final Color _bgSoftPurple = const Color.fromARGB(255, 252, 251, 253);

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userData;

    _nomController = TextEditingController(
      text: user?['nom']?.toString() ?? '',
    );
    _prenomController = TextEditingController(
      text: user?['prenom']?.toString() ?? '',
    );
    _headlineController = TextEditingController(
      text: user?['headline']?.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: user?['location']?.toString() ?? '',
    );

    _skillsController = TextEditingController(); // ← Initialisé ici

    _skills = List<String>.from(user?['skills'] ?? []);
    _experience = List<Map<String, dynamic>>.from(user?['experience'] ?? []);
    _education = List<Map<String, dynamic>>.from(user?['education'] ?? []);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _skillsController.dispose(); // ← Nettoyé ici
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadAvatar();
    }
  }

  Future<void> _uploadAvatar() async {
    if (_imageFile == null) return;
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AuthProvider.baseUrl}/users/upload-avatar'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${auth.token}',
        'ngrok-skip-browser-warning': 'true',
      });

      request.files.add(
        await http.MultipartFile.fromPath('file', _imageFile!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("=== DEBUG UPLOAD PHOTO ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedData = json.decode(response.body);
        print("Données mises à jour reçues : $updatedData");

        auth.updateUserLocal(updatedData);
        setState(() {}); // Rafraîchit l'avatar immédiatement

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo mise à jour !"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec upload : ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Erreur upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final dataToSave = {
      "nom": _nomController.text.trim(),
      "prenom": _prenomController.text.trim(),
      "headline": _headlineController.text.trim(),
      "location": _locationController.text.trim(),
      "skills": _skills,
      "experience": _experience,
      "education": _education,
    };

    print("=== DEBUG SAVE PROFILE ===");
    print("Données envoyées : $dataToSave");

    try {
      final response = await http.patch(
        Uri.parse('${AuthProvider.baseUrl}/users/profile'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode(dataToSave),
      );

      print("STATUS SAVE : ${response.statusCode}");
      print("BODY SAVE : ${response.body}");

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        auth.updateUserLocal(updatedData);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès !"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur serveur : ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Erreur sauvegarde: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur réseau : $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addExperience() {
    setState(() {
      _experience.add({
        "company": "",
        "position": "",
        "startDate": "",
        "endDate": "",
      });
    });
  }

  void _addEducation() {
    setState(() {
      _education.add({
        "school": "",
        "degree": "",
        "startYear": "",
        "endYear": "",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().userData;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : _bgSoftPurple,
      appBar: AppBar(
        title: const Text(
          "Modifier le profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _purple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Photo de profil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (user?['photoUrl'] != null &&
                                    user!['photoUrl'].isNotEmpty)
                              ? NetworkImage(
                                  "${user['photoUrl']}?t=${DateTime.now().millisecondsSinceEpoch}",
                                )
                              : null,
                          child:
                              _imageFile == null &&
                                  (user?['photoUrl'] == null ||
                                      user!['photoUrl'].isEmpty)
                              ? const Icon(Icons.person, size: 65)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: _purple,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Informations de base
                  _buildSectionTitle("Informations de base"),
                  _buildCardSection(
                    isDark,
                    child: Column(
                      children: [
                        _buildTextField(
                          _prenomController,
                          "Prénom",
                          Icons.person_outline,
                        ),
                        _buildTextField(
                          _nomController,
                          "Nom",
                          Icons.person_outline,
                        ),
                        _buildTextField(
                          _headlineController,
                          "Headline",
                          Icons.work_outline,
                        ),
                        _buildTextField(
                          _locationController,
                          "Localisation",
                          Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Compétences (version finale et robuste)
                  _buildSectionTitle("Compétences"),
                  _buildCardSection(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_skills.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _skills
                                .map(
                                  (s) => Chip(
                                    label: Text(s),
                                    onDeleted: () =>
                                        setState(() => _skills.remove(s)),
                                    backgroundColor: _purple.withOpacity(0.15),
                                    deleteIconColor: _purple,
                                  ),
                                )
                                .toList(),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Aucune compétence ajoutée",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _skillsController,
                          decoration: InputDecoration(
                            hintText:
                                "Tape une compétence et appuie sur Entrée ou +",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: _purple,
                                size: 28,
                              ),
                              onPressed: () {
                                final value = _skillsController.text.trim();
                                if (value.isNotEmpty &&
                                    !_skills.contains(value)) {
                                  setState(() {
                                    _skills.add(value);
                                  });
                                  _skillsController.clear();
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            final trimmed = value.trim();
                            if (trimmed.isNotEmpty &&
                                !_skills.contains(trimmed)) {
                              setState(() {
                                _skills.add(trimmed);
                              });
                              _skillsController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Expérience
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Expérience"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addExperience,
                      ),
                    ],
                  ),
                  ..._experience.asMap().entries.map((entry) {
                    int i = entry.key;
                    return Card(
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (v) => _experience[i]['company'] = v,
                            decoration: const InputDecoration(
                              labelText: "Entreprise",
                            ),
                          ),
                          TextField(
                            onChanged: (v) => _experience[i]['position'] = v,
                            decoration: const InputDecoration(
                              labelText: "Poste",
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 25),

                  // Formation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Formation"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addEducation,
                      ),
                    ],
                  ),
                  ..._education.asMap().entries.map((entry) {
                    int i = entry.key;
                    return Card(
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (v) => _education[i]['school'] = v,
                            decoration: const InputDecoration(
                              labelText: "École",
                            ),
                          ),
                          TextField(
                            onChanged: (v) => _education[i]['degree'] = v,
                            decoration: const InputDecoration(
                              labelText: "Diplôme",
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    onPressed: _isLoading ? null : _saveProfile,
                    child: const Text(
                      "ENREGISTRER LES MODIFICATIONS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCardSection(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2226) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _purple,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}
