import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wefood/blocs/user_info_cubit.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';

class BusinessInfo extends StatefulWidget {
  const BusinessInfo({super.key});

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {

  void retrieveData() async {
    await Api.getSessionBusiness().then((BusinessExpandedModel data) {
      context.read<UserInfoCubit>().setBusinessName(data.business.name);
      context.read<UserInfoCubit>().setBusinessDescription(data.business.description);
      context.read<UserInfoCubit>().setBusinessDirections(data.business.directions);
      context.read<UserInfoCubit>().setBusinessLatLng(
        LatLng(
          data.business.latitude ?? 0,
          data.business.longitude ?? 0,
        )
      );
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

    final UserInfoCubit userInfoCubit = context.watch<UserInfoCubit>();

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
              feedbackText: (userInfoCubit.state.business.name != null) ? 'Nombre: ${userInfoCubit.state.business.name!}' : 'Añade tu nombre',
              firstTopic: 'nombre',
              firstInitialValue: (userInfoCubit.state.business.name != null) ? userInfoCubit.state.business.name! : '',
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
          ],
        ),
      );
    }
  }
}