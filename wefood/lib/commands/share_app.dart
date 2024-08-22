import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

shareApp(BuildContext context) {
  Share.share(
    '¡Encuentra comida de restaurantes a precio de descuento con WeFood! Descubre más en www.wefoodcompany.com'
  ).then((result) {
    if(result.status == ShareResultStatus.success) {
      const snackBar = SnackBar(
        content: Text('¡Gracias por compartirnos!'),
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  });
}