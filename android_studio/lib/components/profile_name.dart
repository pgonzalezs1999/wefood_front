import 'package:flutter/material.dart';
import 'package:wefood/components/editable_field.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/models/user_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class ProfileName extends StatefulWidget {
  const ProfileName({super.key});

  @override
  State<ProfileName> createState() => ProfileNameState();
}

class ProfileNameState extends State<ProfileName> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: Api.getProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserModel> userData) {
        if(userData.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(userData.hasData) {
          resultWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(userData.data?.realName != null) EditableField(
                feedbackText: '¡Hola de nuevo, ${userData.data!.realName!}!',
                firstTopic: 'nombre',
                firstInitialValue: userData.data!.realName!,
                firstMinimumLength: 6,
                firstMaximumLength: 50,
                secondTopic: 'apellidos',
                secondInitialValue: userData.data!.realSurname,
                secondMinimumLength: 6,
                secondMaximumLength: 50,
                onSave: (newValue, newSecondValue) async {
                  dynamic response = await Api.updateRealName(
                    name: newValue,
                    surname: newSecondValue!,
                  );
                  print('CONTINUA BIEN POR PROFILE_NAME: $response');
                  setState(() {});
                  return response;
                },
              ),
              if(userData.data?.realName != null) EditableField(
                feedbackText: 'Usuario: ${userData.data!.username}',
                firstTopic: 'usuario',
                firstInitialValue: userData.data!.username,
                firstMinimumLength: 5,
                firstMaximumLength: 50,
                onSave: (newValue, newSecondValue) async {
                  dynamic response = await Api.updateUsername(
                    username: newValue,
                  );
                  print('CONTINUA BIEN POR PROFILE_NAME: $response');
                  setState(() {});
                  return response;
                },
              ),
            ],
          );
        }
        return resultWidget;
      }
    );
  }
}