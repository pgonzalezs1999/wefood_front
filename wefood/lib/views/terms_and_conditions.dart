import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:wefood/services/app_links/app_links_subscription.dart';
import 'package:wefood/views/views.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {

  @override
  void initState() {
    super.initState();
    AppLinksSubscription.setOnAppLinkReceivedCallback((uri) {
      _handleAppLink(uri);
    });
    AppLinksSubscription.start();
  }

  void _handleAppLink(Uri uri) {
    if(uri.path.contains('changePassword')) {
      _navigateToChangePasswordSetScreen(
        appLink: uri,
      );
    }
  }

  void _navigateToChangePasswordSetScreen({
    required Uri appLink,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordSetScreen(
        appLink: appLink,
      )),
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popUntilFirst();
      });
    });
  }

  void _popUntilFirst() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popUntilFirst();
      });
    }
  }

  @override
  void dispose() {
    AppLinksSubscription.cancel();
    super.dispose();
  }

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