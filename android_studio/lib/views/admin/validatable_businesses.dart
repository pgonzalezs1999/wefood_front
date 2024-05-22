import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/components/components.dart';

class ValidatableBusinesses extends StatefulWidget {
  const ValidatableBusinesses({super.key});

  @override
  State<ValidatableBusinesses> createState() => _ValidatableBusinessesState();
}

class _ValidatableBusinessesState extends State<ValidatableBusinesses> {

  List<BusinessExpandedModel>? businesses = [];
  bool isRetrievingData = true;

  void _removeItem(int businessId) async {
    setState(() {
      businesses = businesses?.where((business) => business.business.id != businessId).toList();
    });
  }

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
        if(isRetrievingData == false && businesses != null && businesses!.isNotEmpty) Column(
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
                        value: '${item.business.directions}\n(long: ${item.business.longitude}, lat: ${item.business.latitude})',
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
                        isMail: true,
                      ),
                      _ValidatableRow(
                        title: 'Teléfono',
                        value: '(+${item.user.phonePrefix}) ${item.user.phone}',
                        isPhone: true,
                      ),
                      _ValidatableRow(
                        title: 'Solicitado a fecha',
                        value: Utils.dateTimeToString(
                          date: item.business.createdAt,
                        ),
                      ),
                      const Divider(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <ElevatedButton>[
                          ElevatedButton(
                            child: const Text('RECHAZAR'),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return WefoodPopup(
                                    context: _,
                                    title: '¿Rechazar establecimiento?',
                                    actions: <TextButton>[
                                      TextButton(
                                        onPressed: () async {
                                          callRequestWithLoading(
                                            closePreviousPopup: true,
                                            context: context,
                                            request: () async {
                                              return await Api.refuseBusiness(
                                                id: item.business.id!,
                                              );
                                            },
                                            onSuccess: (value) async {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return WefoodPopup(
                                                    context: context,
                                                    title: 'Establecimiento rechazado correctamente',
                                                    cancelButtonTitle: 'OK',
                                                  );
                                                }
                                              );
                                              _retrieveData();
                                            },
                                          );
                                        },
                                        child: const Text('SÍ'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          ElevatedButton(
                            child: const Text('ACEPTAR'),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return WefoodPopup(
                                    context: _,
                                    title: '¿Aceptar establecimiento?',
                                    actions: <TextButton>[
                                      TextButton(
                                        child: const Text('SÍ'),
                                        onPressed: () async {
                                          callRequestWithLoading(
                                            closePreviousPopup: true,
                                            context: context,
                                            request: () async {
                                              return await Api.validateBusiness(
                                                id: item.business.id!,
                                              );
                                            },
                                            onSuccess: (_) {
                                              _removeItem(item.business.id!);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return WefoodPopup(
                                                    context: context,
                                                    title: '¡Negocio validado!',
                                                    cancelButtonTitle: 'OK',
                                                  );
                                                }
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
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
        if(isRetrievingData == false && businesses != null && businesses!.isEmpty) Align( // TODO currarse más esto
          alignment: Alignment.center,
          child: Card(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Column(
                children: <Text>[
                  Text(
                    '¡Estamos al día!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Cuando nuevos negocios soliciten unirse, aparecerán aquí',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class _ValidatableRow extends StatefulWidget {

  final String title;
  final String? value;
  final bool isPhone;
  final bool isMail;

  const _ValidatableRow({
    required this.title,
    required this.value,
    this.isPhone = false,
    this.isMail = false,
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
          (widget.isPhone == true)
            ? GestureDetector(
              child: Row(
                children: <Widget>[
                  Text(
                    '${widget.value}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary, // TODO deshardcodear este estilo
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              onTap: () {
                launchUrlString('tel://${widget.value}');
              },
            )
            : (widget.isMail == true)
              ? GestureDetector(
                child: Text(
                  '${widget.value}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, // TODO deshardcodear este estilo
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () async {
                  String subject = 'Solicitud de alta en WeFood';
                  String message = 'Buenas tardes.\n\n'
                      'Desde WeFood hemos recibido la solicitud de registro para su negocio.\n\n'
                      'Estamos encantados que de haya elegido nuestra plataforma. Esperamos estar a la altura de sus expectativas.\n\n'
                      'Para mantener nuestra plataforma libre de estafas y malas experiencias que puedan hacer que nuestros clientes desconfíen de otros negocios, necesitamos que los solicitantes nos aclaren algunas dudas sobre su negocio:\n\n\n\n'
                      'En cuanto recibamos su respuesta y la verifiquemos, podrá comenzar a ofrecer sus productos, ¡y así ganar un dinero extra mientras lucha contra el desperdicio de alimentos!\n\n'
                      'Reciba un cordial saludo,\n'
                      'El equipo de WeFood.';
                  await launchUrl(
                    Uri.parse('mailto:${widget.value}?subject=$subject&body=$message'),
                  );
                },
              )
              : Expanded(
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
