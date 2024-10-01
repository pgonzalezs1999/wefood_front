import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/views/views.dart';

class UpdateRequired extends StatefulWidget {

  const UpdateRequired({
    super.key,
  });

  @override
  State<UpdateRequired> createState() => _UpdateRequiredState();
}

class _UpdateRequiredState extends State<UpdateRequired> {

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _launchStore() async {
    String url = '';
    if(Platform.isAndroid) {
      url = Environment.linkToDownloadGooglePlay;
    } else if(Platform.isIOS) {
      url = Environment.linkToDownloadAppleStore;
    }
    Uri uri = Uri.parse(url);
    if(await canLaunchUrl(uri)) {
      launchUrl(uri).whenComplete(() {
        _navigateToMain();
      });
    } else {
      throw 'No se pudo abrir la URL $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '¡Nueva actualización!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Hemos hecho cambios que creemos que te van a gustar. ¡Queremos enseñártelos!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () => _launchStore(),
                child: const Text('ACTUALIZAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}