import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfScreen extends StatelessWidget {
  final String name;
  final String path;

  const PdfScreen({Key? key, required this.name, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarDetails(context, name),
      body: PdfViewer.asset(path,
      // TODO: Background color of scaffold
      params: PdfViewerParams(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor
      ),
    ));
  }
}