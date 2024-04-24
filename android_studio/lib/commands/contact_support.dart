import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/environment.dart';

launchWhatsapp({
  required Function() onError,
}) async {
  String number = Environment.supportPhone;
  String message = 'Buenas tardes. Quería hacer una consulta sobre la aplicación de WeFood:\n\n';
  Uri uri = Uri.parse('https://wa.me/$number?text=$message');
  try {
    await launchUrl(uri);
  } catch(error) {
    onError();
  }
}