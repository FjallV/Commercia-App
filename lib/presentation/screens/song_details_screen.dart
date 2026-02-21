import 'package:commercia/data/models/song_model.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFontSize();
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
      appBar: appBarDetails(context, widget.song.title),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Font size control as chips
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FontChipButton(
                        icon: Icons.remove,
                        onTap: _decreaseFontSize,
                        enabled: _fontPercentage > 50,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: ShapeDecoration(
                          shape: StadiumBorder(),
                          color: colorScheme.primary,
                        ),
                        child: Text(
                          '$_fontPercentage%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _FontChipButton(
                        icon: Icons.add,
                        onTap: _increaseFontSize,
                        enabled: _fontPercentage < 300,
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 12),
                  // Lyrics
                  Text(
                    widget.song.lyrics,
                    textScaler: TextScaler.linear(_fontPercentage / 100),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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