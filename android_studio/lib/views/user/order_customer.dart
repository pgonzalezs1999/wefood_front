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
      body: Column(
        children: <Widget>[
          const Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Confirmar pedido'),
            ],
          ),
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('WeFood pack de'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${info.business.name}'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Expanded(
                          child: Text('${info.business.directions}'),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Enseña este QR al encargado:'),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.75,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: QrImageView(
                        data: '${widget.id}',
                        version: QrVersions.min,
                        size: 200.0,
                      ),
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
                      onPressed: () async {
                        WefoodPopup.show(
                          context: context,
                          title: '¿Confirmar recogida?\n\nConfirme que el encargado está de acuerdo en confirmar el pedido de esta forma, ya que no podrá deshacer esta acción.',
                          cancelButtonTitle: 'CANCELAR',
                          actions: <TextButton>[
                            TextButton(
                              child: const Text('CONFIRMAR'),
                              onPressed: () async {
                                Navigator.pop(context);
                                await Api.completeOrderCustomer(
                                  idOrder: widget.id,
                                ).then((_) {
                                  WefoodPopup.show(
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
                                });
                              },
                            ),
                          ],
                        );
                      },
                      child: const Text('CONFIRMAR RECOGIDA'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text( // TODO deshardcodear este estilo
                      'Código: ${CustomParsers.numberToHexadecimal(widget.id)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    )
                  ],
                );
              }
              return resultWidget;
            }
          ),
        ],
      ),
    );
  }
}