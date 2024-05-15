import 'package:flutter/material.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/components/components.dart';

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
      title: 'Validar negocios',
      body: [
        if(isRetrievingData == true) const LoadingIcon(),
        if(isRetrievingData == false) Column(
          children: businesses!.map(
            (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Card(
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.25,
                      ),
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.25,
                      ),
                      right: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.25,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Establecimiento solicitado:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _ValidatableRow(
                        title: 'Nombre',
                        value: item.business.name,
                      ),
                      _ValidatableRow(
                        title: 'Descripción',
                        value: item.business.description,
                      ),
                      _ValidatableRow(
                        title: 'RUC',
                        value: item.business.taxId,
                      ),
                      _ValidatableRow(
                        title: 'Dirección',
                        value: '${item.business.directions} - (long: ${item.business.longitude}, lat: ${item.business.latitude})',
                      ),
                      const Divider(
                        height: 30,
                      ),
                      Text(
                        'Usuario solicitante:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _ValidatableRow(
                        title: 'Username',
                        value: item.user.username,
                      ),
                      _ValidatableRow(
                        title: 'Correo',
                        value: item.user.email,
                      ),
                      _ValidatableRow(
                        title: 'Teléfono',
                        value: '(+${item.user.phone}) ${item.user.phone}',
                      ),
                      _ValidatableRow(
                        title: 'Solicitado a fecha',
                        value: Utils.dateTimeToString(item.business.createdAt),
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
                                    context: context,
                                    title: '¿Rechazar establecimiento?',
                                    actions: <TextButton>[
                                      TextButton(
                                        onPressed: () async {
                                          await Api.refuseBusiness(
                                            id: item.business.id!,
                                          ).then((value) async {
                                            _retrieveData();
                                          }).then((value) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: const Text('SÍ'),
                                      ),
                                    ],
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
                                    context: context,
                                    title: '¿Aceptar establecimiento?',
                                    actions: <TextButton>[
                                      TextButton(
                                        onPressed: () async {
                                          await Api.validateBusiness(
                                            id: item.business.id!,
                                          ).then((value) async {
                                            _retrieveData();
                                          }).then((value) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: const Text('SÍ'),
                                      ),
                                    ],
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
              fontWeight: FontWeight.w600,
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
