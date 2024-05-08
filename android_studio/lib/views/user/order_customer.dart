import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';

class OrderCustomer extends StatefulWidget {

  final int id;

  const OrderCustomer({
    super.key,
    required this.id,
  });

  @override
  State<OrderCustomer> createState() => _OrderCustomerState();
}
class _OrderCustomerState extends State<OrderCustomer> {

  Widget resultWidget = const LoadingIcon();
  Widget favouriteIcon = const Icon(Icons.favorite_outline);
  late ProductExpandedModel info;
  int selectedAmount = 1;

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Confirmar pedido',
      body: [
        FutureBuilder<ProductExpandedModel>(
          future: Api.getItem(
            id: widget.id,
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
                              MapsLauncher.launchQuery(info.business.directions ?? '');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('${info.business.directions}'),
                    ],
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
                    data: '${widget.id}',
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return WefoodPopup(
                            context: context,
                            title: '¿Confirmar recogida?',
                            description: 'Asegúrese de que el encargado está de acuerdo en confirmar el pedido de esta forma, ya que no se podrá deshacer esta acción',
                            cancelButtonTitle: 'CANCELAR',
                            actions: <TextButton>[
                              TextButton(
                                child: const Text('CONFIRMAR'),
                                onPressed: () {
                                  Api.completeOrderCustomer(
                                    idOrder: widget.id,
                                  ).then((_) {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return WefoodPopup(
                                          context: context,
                                          title: '¡Producto recogido!\n\n¡Muchas gracias por confiar en WeFood! ¡Esperamos volver a verle pronto!',
                                          cancelButtonTitle: 'OK',
                                          cancelButtonBehaviour: () async {
                                            setState(() {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            });
                                          },
                                        );
                                      }
                                    );
                                  });
                                },
                              ),
                            ],
                          );
                        }
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Código: ${CustomParsers.numberToHexadecimal(widget.id)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  )
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