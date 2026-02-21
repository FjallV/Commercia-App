import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberEditScreen extends StatefulWidget {
  const MemberEditScreen({super.key, required this.member});
  final MemberModel member;

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _mobileController = TextEditingController(text: widget.member.mobile ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final updated = await MemberRepository().updateContactInfo(
        id: widget.member.id,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        mobile: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
      );
      // Reflect changes back into the local model
      widget.member.email = updated.email;
      widget.member.mobile = updated.mobile;
      if (mounted) GoRouter.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakt bearbeiten'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Speichern'),
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
                    prefixIcon: Icon(Icons.mail_outline),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null; // optional
                    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                    return valid ? null : 'Ungültige E-Mail-Adresse';
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}