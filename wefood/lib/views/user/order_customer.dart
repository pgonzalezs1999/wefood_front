import 'package:flutter/material.dart';
// import 'package:maps_launcher/maps_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';

class OrderCustomer extends StatefulWidget {

  final int itemId;
  final int orderId;

  const OrderCustomer({
    super.key,
    required this.itemId,
    required this.orderId,
  });

  @override
  State<OrderCustomer> createState() => _OrderCustomerState();
}
class _OrderCustomerState extends State<OrderCustomer> {

  Widget resultWidget = const LoadingIcon();
  late ProductExpandedModel info;
  int selectedAmount = 1;

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Confirmar pedido',
      body: [
        FutureBuilder<ProductExpandedModel>(
          future: Api.getItem(
            id: widget.itemId,
          ),
          builder: (BuildContext context, AsyncSnapshot<ProductExpandedModel> response) {
            if(response.hasError) {
              resultWidget = Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.05,
                ),
                child: const Text('Error'),
              );
            } else if(response.hasData) {
              info = response.data!;
              resultWidget = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: <Text>[
                      Text(
                        'WeFood pack de ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${info.business.name}'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '1. Dirígete a',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            child: const Icon(Icons.location_pin),
                            onTap: () {
                              // MapsLauncher.launchQuery(info.business.directions ?? '');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text('${info.business.directions}'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.watch_later,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Debes estar entre las ${Utils.dateTimeToString(date: info.product.startingHour, showDate: false)}h '
                        'y las ${Utils.dateTimeToString(date: info.product.endingHour, showDate: false)}h'
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if(Utils.minutesFromNowToDateTime(info.product.endingHour!) < 0 && (info.item.date!.day == DateTime.now().day)) Text(
                    'Horario de recogida excedido. Recuerde que el negocio no está obligado a entregarle su paquete fuera del horario indicado',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '2. Enseña este QR al encargado:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  QrImageView(
                    data: '${widget.orderId}',
                    version: QrVersions.min,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '¿No conseguís leer el QR? Confirma tú la entrega desde el siguiente botón y enséñale el código al encargado para que reconozca tu pedido:',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('CONFIRMAR ENTREGA'),
                    onPressed: () async {
                      wefoodShowDialog(
                        context: context,
                        title: '¿Confirmar recogida?',
                        description: 'Asegúrese de que el encargado está de acuerdo en confirmar el pedido de esta forma, ya que no se podrá deshacer esta acción',
                        cancelButtonTitle: 'CANCELAR',
                        actions: <TextButton>[
                          TextButton(
                            child: const Text('CONFIRMAR'),
                            onPressed: () {
                              callRequestWithLoading(
                                closePreviousPopup: true,
                                context: context,
                                request: () async {
                                  return await Api.completeOrderCustomer(
                                    idOrder: widget.orderId,
                                  );
                                },
                                onSuccess: (_) {
                                  wefoodShowDialog(
                                    context: context,
                                    title: '¡Producto recogido!',
                                    description: '¡Muchas gracias por confiar en WeFood! ¡Esperamos volver a verle pronto!',
                                    cancelButtonTitle: 'OK',
                                    cancelButtonBehaviour: () async {
                                      setState(() {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Código: ${Utils.numberToHexadecimal(widget.orderId)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Teléfono de contacto:'),
                      TextButton(
                        child: Text('(+${info.user.phonePrefix}) ${info.user.phone}'),
                        onPressed: () {
                          launchUrlString('tel://${info.user.phone}');
                        },
                      ),
                    ],
                  ),
                ],
              );
            }
            return resultWidget;
          }
        ),
      ],
    );
  }
}