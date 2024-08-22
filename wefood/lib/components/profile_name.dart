import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';

class ProfileName extends StatefulWidget {
  const ProfileName({super.key});

  @override
  State<ProfileName> createState() => ProfileNameState();
}

class ProfileNameState extends State<ProfileName> {
  Widget resultWidget = const LoadingIcon();


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: Api.getProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserModel> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          resultWidget = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditableField(
                  feedbackText: (response.data?.realName != null) ? '¡Hola de nuevo, ${response.data!.realName!}!' : 'Añade tu nombre',
                  firstTopic: 'nombre',
                  firstInitialValue: (response.data?.realName != null) ? response.data!.realName! : '',
                  firstMinimumLength: 2,
                  firstMaximumLength: 30,
                  firstExtraRequirement: () async {
                    bool result = false;
                    print('ENTRANDO EN EL TIMER...');
                    Timer(
                      const Duration(seconds: 1),
                      () async {
                        Random random = Random();
                        result = random.nextBool();
                        print('ELIGIÓ: $result');
                      }
                    );
                    return result;
                  },
                  secondTopic: 'apellidos',
                  secondInitialValue: (response.data?.realName != null) ? response.data!.realSurname : '',
                  secondMinimumLength: 2,
                  secondMaximumLength: 30,
                  onSave: (newValue, newSecondValue) async {
                    dynamic response = await Api.updateRealName(
                      name: newValue,
                      surname: newSecondValue!,
                    );
                    setState(() {});
                    return response;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                EditableField(
                  feedbackText: 'Usuario: ${response.data!.username}',
                  firstTopic: 'usuario',
                  firstInitialValue: response.data!.username!,
                  firstMinimumLength: 5,
                  firstMaximumLength: 50,
                  onSave: (newValue, newSecondValue) async {
                    dynamic response = await Api.updateUsername(
                      username: newValue,
                    );
                    setState(() {});
                    return response;
                  },
                ),
              ],
            ),
          );
        }
        return resultWidget;
      }
    );
  }
}