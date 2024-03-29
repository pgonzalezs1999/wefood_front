import 'package:flutter/material.dart';
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

  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BusinessExpandedModel>(
      future: Api.getSessionBusiness(),
      builder: (BuildContext context, AsyncSnapshot<BusinessExpandedModel> response) {
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
                  feedbackText: (response.data!.business.name != null) ? 'Nombre: ${response.data!.business.name!}' : 'Añade tu nombre',
                  firstTopic: 'nombre',
                  firstInitialValue: (response.data!.business.name != null) ? response.data!.business.name! : '',
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
                  feedbackText: 'Descripción: ${response.data!.business.description}',
                  firstTopic: 'descripción',
                  firstInitialValue: response.data!.business.description ?? '',
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
                      response.data!.business.longitude ?? 0,
                      response.data!.business.latitude ?? 0,
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Ubicación: ${response.data!.business.directions!}'),
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
        return resultWidget;
      }
    );
  }
}