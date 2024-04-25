import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';

launchWhatsapp({
  required BuildContext context,
}) async {
  String number = Environment.supportPhone;
  String message = 'Buenas tardes. Quería hacer una consulta sobre la aplicación de WeFood:\n\n';
  Uri uri = Uri.parse('String erróneo intencionado para testear el case de error'); // Uri.parse('ahttps://wa.me/$number?text=$message');
  try {
    await launchUrl(uri);
  } catch(error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WefoodPopup(
          title: 'No se ha podido abrir WhatsApp. Esto suele deberse a problemas de conexión, o a que no tenga la aplicación de WhatsApp instalada.\n\nSi el error persiste, por favor escríbanos a',
          content: Column(
            children: <Widget>[
              TextButton(
                onPressed: () async {
                  String subject = 'Consulta sobre la aplicación WeFood';
                  await launchUrl(
                    Uri.parse('mailto:${Environment.supportEmail}?subject=$subject&body=$message'),
                  );
                },
                child: const Text(Environment.supportEmail),
              ),
            ],
          ),
          cancelButtonTitle: 'OK',
        );
      }
    );
  }
}