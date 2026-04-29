import 'dart:typed_data';
import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:commercia/presentation/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class MemberEditScreen extends StatefulWidget {
  const MemberEditScreen({super.key, required this.member});
  final MemberModel member;

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _jobController;
  late final TextEditingController _emplController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Pending photo upload
  Uint8List? _pendingPhotoBytes;
  String? _pendingMimeType;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _mobileController = TextEditingController(text: widget.member.mobile ?? '');
    _jobController = TextEditingController(text: widget.member.job ?? '');
    _emplController = TextEditingController(text: widget.member.empl ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _jobController.dispose();
    _emplController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pendingPhotoBytes = bytes;
      _pendingMimeType = picked.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      // Upload photo first if one was selected
      if (_pendingPhotoBytes != null) {
        final signedUrl = await MemberRepository().uploadPhoto(
          memberId: widget.member.id,
          cerevis: widget.member.cerevis,
          bytes: _pendingPhotoBytes!,
          mimeType: _pendingMimeType!,
        );

        // Evict the old URL from Flutter's image cache so the details screen
        // doesn't serve the stale bitmap when it rebuilds with the new URL.
        final oldUrl = widget.member.photo_url;
        if (oldUrl != null && oldUrl.isNotEmpty) {
          await NetworkImage(oldUrl).evict();
        }

        // Update the model in place — the signed URL is unique per upload
        // so no extra cache-busting is needed.
        widget.member.photo_url = signedUrl;
      }

      final updated = await MemberRepository().updateContactInfo(
        id: widget.member.id,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        mobile: _mobileController.text.trim().isEmpty
            ? null
            : _mobileController.text.trim(),
        job: _jobController.text.trim().isEmpty
            ? null
            : _jobController.text.trim(),
        empl: _emplController.text.trim().isEmpty
            ? null
            : _emplController.text.trim(),
      );
      widget.member.email = updated.email;
      widget.member.mobile = updated.mobile;
      widget.member.job = updated.job;
      widget.member.empl = updated.empl;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => GoRouter.of(context).pop(),
          ),
        ],
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
                const SizedBox(height: kToolbarHeight + 8),
                // ── Header: cerevis + name left, avatar right ────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.member.cerevis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              widget.member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tappable avatar with edit badge
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: SizedBox(
                          width: 128,
                          height: 128,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Preview pending photo or current avatar
                              _pendingPhotoBytes != null
                                  ? Container(
                                      width: 128,
                                      height: 128,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.memory(
                                          _pendingPhotoBytes!,
                                          width: 128,
                                          height: 128,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : MemberAvatar.large(member: widget.member),
                              // Edit badge
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // ── Contact fields ───────────────────────────────────────
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
                    if (v == null || v.isEmpty) return null;
                    final valid =
                        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                    return valid ? null : 'Ungültige E-Mail-Adresse';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jobController,
                  decoration: const InputDecoration(
                    labelText: 'Beruf',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emplController,
                  decoration: const InputDecoration(
                    labelText: 'Arbeitgeber',
                    prefixIcon: Icon(Icons.business_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}