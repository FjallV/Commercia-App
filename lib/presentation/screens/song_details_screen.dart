import 'package:commercia/data/models/song_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongDetails extends StatefulWidget {
  SongDetails({super.key, required this.song});
  SongModel song;

  @override
  State<SongDetails> createState() => _SongDetailsState();
}

class _SongDetailsState extends State<SongDetails> {
  int _fontPercentage = 120;
  static const String _fontSizeKey = 'lyrics_font_size';

  final ScrollController _scrollController = ScrollController();
  bool _headerVisible = true;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldHide = _scrollController.offset > 60;
    if (shouldHide != !_headerVisible) {
      setState(() => _headerVisible = !shouldHide);
    }
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontPercentage = prefs.getInt(_fontSizeKey) ?? 120;
    });
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeKey, _fontPercentage);
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontPercentage < 300) {
        _fontPercentage += 10;
        _saveFontSize();
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontPercentage > 50) {
        _fontPercentage -= 10;
        _saveFontSize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _headerVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_headerVisible,
            child: AppBar(
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
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _FontChipButton(
              icon: Icons.remove,
              onTap: _decreaseFontSize,
              enabled: _fontPercentage > 50,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: colorScheme.primary,
              ),
              child: Text(
                '$_fontPercentage%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _FontChipButton(
              icon: Icons.add,
              onTap: _increaseFontSize,
              enabled: _fontPercentage < 300,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Space for the AppBar
              const SizedBox(height: kToolbarHeight + 8),

              // Header: title, type, info — fades out on scroll
              AnimatedOpacity(
                opacity: _headerVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.song.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                          ),
                        ),
                        if (widget.song.type != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.song.type!,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                        if (widget.song.info != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.song.info!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Lyrics — left-aligned
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.song.lyrics,
                  textAlign: TextAlign.left,
                  textScaler: TextScaler.linear(_fontPercentage / 100),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontChipButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _FontChipButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: ShapeDecoration(
          shape: StadiumBorder(
            side: BorderSide(
              color: enabled
                  ? colorScheme.outlineVariant
                  : colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}