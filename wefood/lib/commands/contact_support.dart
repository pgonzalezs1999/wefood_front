import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';

launchContact({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Align(
          alignment: Alignment.center,
          child: Text('Contáctanos'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              'Número de teléfono:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(Environment.supportPhone,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Divider(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
            ),
            Text(
              'Correo electrónico: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(Environment.supportEmail),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Divider(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
            ),
            const Text(
              'Le atenderemos más rápidamente si nos escribe un mensaje via WhatsApp:',
              textAlign: TextAlign.center,
            ),
            TextButton(
              child: const Text(
                'Enviar WhatsApp',
              ),
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
            ),
          ],
        ),
        actions: <TextButton>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }
  );
}