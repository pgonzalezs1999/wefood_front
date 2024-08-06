import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';

class ChangePasswordAskScreen extends StatefulWidget {
  const ChangePasswordAskScreen({super.key});

  @override
  State<ChangePasswordAskScreen> createState() => _ChangePasswordAskScreenState();
}

class _ChangePasswordAskScreenState extends State<ChangePasswordAskScreen> {

  String email = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      canPop: false,
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: [
        const BackUpBar(title: 'Recuperar contraseña'),
        Container(
          height: MediaQuery.of(context).size.height * 0.75,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Introduce el correo asociado a tu usuario:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                'Te enviaremos un correo electrónico desde el que podrás establecer una nueva contraseña',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              WefoodInput(
                labelText: 'Correo electrónico',
                onChanged: (value) {
                  if(email.isEmail) {
                    setState(() {
                      email = value;
                    });
                  } else {
                    setState(() {
                      email = '';
                    });
                  }

                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
             /* Align(
                alignment: Alignment.center,
                child: (email.isEmail)
                  ? ElevatedButton(
                    onPressed: () async {
                      callRequestWithLoading(
                          context: context,
                          request: () async {
                            await return Api.
                          },
                          onSuccess: onSuccess,
                      )
                    },
                    child: const Text('Enviar'),
                  )
                : const BlockedButton(
                  text: 'Enviar',
                ),
              ),*/
            ],
          ),
        ),
      ],
    );
  }
}