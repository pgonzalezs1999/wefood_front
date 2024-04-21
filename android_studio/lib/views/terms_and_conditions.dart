import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
      ),
      body: SfPdfViewer.asset(
        'assets/documents/terms_and_conditions.pdf',
        enableTextSelection: false,
        enableDocumentLinkAnnotation: false,
      ),
    );
  }
}