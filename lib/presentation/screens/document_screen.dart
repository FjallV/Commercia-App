import 'package:commercia/data/models/document_links_model.dart';
import 'package:commercia/data/repositories/document_repository.dart';
import 'package:commercia/data/models/document_links_viewmodel.dart';
import 'package:commercia/presentation/widgets/app_bar_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentScreen extends StatefulWidget {
  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with TickerProviderStateMixin {
  final DocumentLinksViewmodel viewModel = DocumentLinksViewmodel(
    documentLinksRepository: DocumentRepository(),
  );
  late final TabController _tabController;
  late Future<List<DocumentLinksModel>> _linksFuture;

  // PDFs (bleiben vorerst statisch)
  final List<Map<String, String>> _pdfs = [
    {'name': 'Biercomment', 'path': 'assets/pdfs/Biercomment.pdf'},
    {'name': 'Statuten Aktivitas', 'path': 'assets/pdfs/StatutenAktivitas.pdf'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _linksFuture = viewModel.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshLinks() async {
    final newLinks = viewModel.load();
    setState(() {
      _linksFuture = newLinks;
    });
    await newLinks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokumente'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Links', icon: Icon(Icons.language)),
            Tab(text: 'PDFs', icon: Icon(Icons.picture_as_pdf)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
          const AppBarUserAvatar(),
        ],
      ),
      body: Center(
        child: Container(
          width: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLinksTab(),
              _buildPdfsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinksTab() {
    return RefreshIndicator(
      onRefresh: _refreshLinks,
      child: FutureBuilder<List<DocumentLinksModel>>(
        future: _linksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 40),
                Center(child: Text('Fehler beim Laden: ${snapshot.error}')),
              ],
            );
          }
          final links = snapshot.data ?? [];
          if (links.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SizedBox(height: 40),
                Center(child: Text('Keine Links vorhanden')),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            itemBuilder: (context, index) => _buildLinkTile(links[index]),
          );
        },
      ),
    );
  }

  Widget _buildPdfsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pdfs.length,
      itemBuilder: (context, index) {
        final pdf = _pdfs[index];
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(pdf['name']!),
          onTap: () {
            context.pushNamed(
              'pdf',
              extra: {'name': pdf['name'], 'path': pdf['path']},
            );
          },
        );
      },
    );
  }

  Widget _buildLinkTile(DocumentLinksModel link) {
    return ListTile(
      leading: _buildLinkIcon(link.icon),
      title: Text(link.name),
      subtitle: Text(link.url),
      onTap: () => _openLink(link.url),
    );
  }

  Widget _buildLinkIcon(String? iconName) {
    return Icon(_iconFromName(iconName));
  }

  /// Material-Icon-Name aus der DB auf konkretes [IconData] mappen.
  /// Dynamisches `IconData(...)` mit Tree-Shaking nicht möglich, daher
  /// explizite Map. Neue Icons hier ergänzen.
  IconData _iconFromName(String? name) {
    if (name == null || name.trim().isEmpty) return Icons.language;
    switch (name.trim()) {
      case 'language':
        return Icons.language;
      case 'web':
        return Icons.web;
      case 'public':
        return Icons.public;
      case 'link':
        return Icons.link;
      case 'mail':
        return Icons.mail;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'group':
        return Icons.group;
      case 'school':
        return Icons.school;
      case 'sports_bar':
        return Icons.sports_bar;
      case 'event':
        return Icons.event;
      case 'photo_library':
        return Icons.photo_library;
      case 'newspaper':
        return Icons.newspaper;
      case 'home':
        return Icons.home;
      default:
        return Icons.language;
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link kann nicht geöffnet werden')),
      );
    }
  }

}