import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Utility class to create and download .ics calendar files in Dart Web
class ICSFileCreator {
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  ICSFileCreator({
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  /// Format datetime as UTC string for .ics (YYYYMMDDTHHMMSSZ)
  String _formatDate(DateTime dt) {
    // return dt
    //         .toUtc()
    //         .toIso8601String()
    //         .replaceAll('-', '')
    //         .replaceAll(':', '')
    //         .split('.')[0] +
    //     'Z';

            // Convert to UTC before generating the string — this prevents local times
    // from being incorrectly interpreted as UTC (which causes 1h offset issues).
    final utc = dt.isUtc ? dt : dt.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }

  /// Escape special characters for ICS fields
  String _escapeText(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;');
  }

  /// Generate ICS file content
  String generateICSContent() {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//CommerciaApp//EN');
    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:${DateTime.now().millisecondsSinceEpoch}@commercia-aarau.ch');
    buffer.writeln('DTSTAMP:${_formatDate(DateTime.now())}');
    buffer.writeln('DTSTART:${_formatDate(startTime)}');
    buffer.writeln('DTEND:${_formatDate(endTime)}');
    buffer.writeln('SUMMARY:${_escapeText(title)}');
    buffer.writeln('DESCRIPTION:${_escapeText(description)}');
    buffer.writeln('LOCATION:${_escapeText(location)}');
    buffer.writeln('END:VEVENT');
    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  /// Trigger browser download of the ICS file
  void downloadICSFile(String content, {String filename = 'event.ics'}) {
    final bytes = Uint8List.fromList(utf8.encode(content));

    // Create filename
    String safeFilename = filename
        .replaceAll(RegExp(r'[\/\\\:\*\?\"\<\>\|]'), '_')
        .replaceAll(' ', '');
    if (!safeFilename.endsWith('.ics')) safeFilename += '.ics';

    // Wrap bytes in JSUint8Array (valid BlobPart)
    final jsBytes = bytes.toJS;

    // Create JSArray<BlobPart> and add the bytes
    final jsParts = JSArray<web.BlobPart>();
    jsParts[0] = jsBytes;

    // Create Blob
    final blob = web.Blob(jsParts, web.BlobPropertyBag(type: 'text/calendar'));

    // Create object URL & download
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = safeFilename;

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    web.URL.revokeObjectURL(url);
  }
}