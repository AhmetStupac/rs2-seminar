import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final provider = UserProvider();
    final user = await provider.getCurrentUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Greška pri učitavanju profila.'))
              : Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(24.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: TextEditingController(text: (_user!.firstName ?? '') + ' ' + (_user!.lastName ?? '')),
                                decoration: const InputDecoration(
                                  labelText: 'Ime i prezime',
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                                textAlign: TextAlign.center,
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: TextEditingController(text: _user!.email ?? ''),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                                textAlign: TextAlign.center,
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: TextEditingController(text: _user!.phoneNumber ?? ''),
                                decoration: const InputDecoration(
                                  labelText: 'Telefon',
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                                textAlign: TextAlign.center,
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: TextEditingController(text: _user!.username ?? ''),
                                decoration: const InputDecoration(
                                  labelText: 'Korisničko ime',
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                                textAlign: TextAlign.center,
                                readOnly: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
