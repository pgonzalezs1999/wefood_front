import 'package:flutter/material.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/wefood_popup.dart';
import 'package:wefood/models/business_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';

import '../../components/wefood_screen.dart';

class ValidatableBusinesses extends StatefulWidget {
  const ValidatableBusinesses({super.key});

  @override
  State<ValidatableBusinesses> createState() => _ValidatableBusinessesState();
}

class _ValidatableBusinessesState extends State<ValidatableBusinesses> {

  List<BusinessExpandedModel>? businesses = [];
  bool isRetrievingData = true;

  void _retrieveData() async {
    businesses = await Api.getValidatableBusinesses();
    setState(() {
      isRetrievingData = false;
    });
  }

  @override
  void initState() {
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        children: <Widget>[
          const Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Validar establecimientos'),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if(isRetrievingData == true) const LoadingIcon(),
          if(isRetrievingData == false) Column(
            children: businesses!.map(
              (item) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Establecimiento solicitado:',
                          style: TextStyle(
                            fontWeight: FontWeight.w900, // TODO deshardcodear estilo
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _ValidatableRow(
                          title: 'Nombre',
                          value: item.business!.name,
                        ),
                        _ValidatableRow(
                          title: 'Descripción',
                          value: item.business!.description,
                        ),
                        _ValidatableRow(
                          title: 'RUC',
                          value: item.business!.taxId,
                        ),
                        _ValidatableRow(
                          title: 'Dirección',
                          value: '${item.business!.directions} - (long: ${item.business!.longitude}, lat: ${item.business!.latitude})',
                        ),
                        const Divider(
                          height: 30,
                        ),
                        const Text(
                          'Usuario solicitante:',
                          style: TextStyle(
                            fontWeight: FontWeight.w900, // TODO deshardcodear estilo
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _ValidatableRow(
                          title: 'Username',
                          value: item.user?.username,
                        ),
                        _ValidatableRow(
                          title: 'Correo',
                          value: item.user?.email,
                        ),
                        _ValidatableRow(
                          title: 'Teléfono',
                          value: '(+${item.user?.phone}) ${item.user?.phone}',
                        ),
                        _ValidatableRow(
                          title: 'Solicitado a fecha',
                          value: CustomParsers.dateTimeToString(item.business!.createdAt),
                        ),
                        const Divider(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <ElevatedButton>[
                            ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WefoodPopup(
                                      title: '¿Rechazar establecimiento?',
                                      onYes: () async {
                                        await Api.refuseBusiness(
                                          id: item.business!.id!,
                                        ).then((value) async {
                                          _retrieveData();
                                        }).then((value) {
                                          Navigator.pop(context);
                                        });
                                      },
                                    );
                                  }
                                );
                              },
                              child: const Text('RECHAZAR'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WefoodPopup(
                                      title: '¿Aceptar establecimiento?',
                                      onYes: () async {
                                        await Api.validateBusiness(
                                          id: item.business!.id!,
                                        ).then((value) async {
                                          _retrieveData();
                                        }).then((value) {
                                          Navigator.pop(context);
                                        });
                                      },
                                    );
                                  }
                                );
                              },
                              child: const Text('ACEPTAR'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ).toList(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class _ValidatableRow extends StatefulWidget {

  final String? title;
  final String? value;

  const _ValidatableRow({
    required this.title,
    required this.value,
  });

  @override
  State<_ValidatableRow> createState() => _ValidatableRowState();
}

class _ValidatableRowState extends State<_ValidatableRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${widget.title}: ',
            style: const TextStyle(
              fontWeight: FontWeight.w800, // TODO deshardcodear estilo,
            ),
          ),
          Expanded(
            child: Text(
              widget.value ?? 'null',
              style: TextStyle(
                color: (widget.value == null || widget.value?.contains('null') == true) ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
