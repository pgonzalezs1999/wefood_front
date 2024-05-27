import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';

launchWhatsapp({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WefoodPopup(
        context: context,
        title: '¿Abrir WhatsApp?',
        description: 'Se podrá comunicar con soporte a través del número de WhatsApp de la empresa.',
        actions: <TextButton>[
          TextButton(
            child: const Text('SÍ'),
            onPressed: () {
              String number = Environment.supportPhone;
              String message = 'Buenas tardes. Quería hacer una consulta sobre la aplicación de WeFood:\n\n';
              Uri uri = Uri.parse('https://wa.me/$number?text=$message');
              launchUrl(uri).then((response) {
                if(kDebugMode) { print('Abriendo WhatsApp'); }
              }).onError((error, stackTrace) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WefoodPopup(
                      context: context,
                      title: 'No se ha podido abrir WhatsApp',
                      description: 'Esto suele deberse a problemas de conexión, o a que no tenga la aplicación de WhatsApp instalada. Si el error persiste, por favor escríbanos a',
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
              });
            },
          )
        ],
      );
    }
  );
}