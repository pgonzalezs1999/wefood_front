import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/user_info_cubit.dart';
import 'package:wefood/components/editable_field.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/models/business_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/views/business/business_edit_directions.dart';

class BusinessInfo extends StatefulWidget {
  const BusinessInfo({super.key});

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {

  void _navigateToBusinessEditDirections(double longitude, double latitude) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BusinessEditDirections(
        longitude: longitude,
        latitude: latitude,
      )),
    );
  }

  void retrieveData() async {
    await Api.getSessionBusiness().then((BusinessExpandedModel data) {
      context.read<UserInfoCubit>().setBusinessName(data.business.name);
      context.read<UserInfoCubit>().setBusinessDescription(data.business.description);
      context.read<UserInfoCubit>().setBusinessDirections(data.business.directions);
    }).onError((error, stackTrace) {
      setState(() {
        retrievingDataError = true;
      });
    });
    setState(() {
      isRetrievingData = false;
    });
  }

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  Widget resultWidget = const LoadingIcon();
  bool retrievingDataError = false;
  bool isRetrievingData = true;

  @override
  Widget build(BuildContext context) {
    if(isRetrievingData == true) {
      return const LoadingIcon();
    } else if(retrievingDataError == true) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: const Text('Error'),
      );
    } else {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditableField(
              feedbackText: (context.read<UserInfoCubit>().state.business.name != null) ? 'Nombre: ${context.read<UserInfoCubit>().state.business.name!}' : 'Añade tu nombre',
              firstTopic: 'nombre',
              firstInitialValue: (context.read<UserInfoCubit>().state.business.name != null) ? context.read<UserInfoCubit>().state.business.name! : '',
              firstMinimumLength: 6,
              firstMaximumLength: 100,
              onSave: (newValue, newSecondValue) async {
                dynamic response = await Api.updateBusinessName(
                  name: newValue,
                );
                setState(() {});
                return response;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            EditableField(
              feedbackText: 'Descripción: ${context.read<UserInfoCubit>().state.business.description}',
              firstTopic: 'descripción',
              firstInitialValue: context.read<UserInfoCubit>().state.business.description ?? '',
              firstMinimumLength: 6,
              firstMaximumLength: 255,
              onSave: (newValue, newSecondValue) async {
                dynamic response = await Api.updateBusinessDescription(
                  description: newValue,
                );
                setState(() {});
                return response;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                _navigateToBusinessEditDirections(
                  context.read<UserInfoCubit>().state.business.longitude ?? 0,
                  context.read<UserInfoCubit>().state.business.latitude ?? 0,
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text('Ubicación: ${context.read<UserInfoCubit>().state.business.directions!}'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                      Icons.edit
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}