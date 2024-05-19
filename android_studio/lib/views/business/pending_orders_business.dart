import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/blocs/blocs.dart';

class PendingOrdersBusiness extends StatefulWidget {
  const PendingOrdersBusiness({super.key});

  @override
  State<PendingOrdersBusiness> createState() => _PendingOrdersBusinessState();
}

class _PendingOrdersBusinessState extends State<PendingOrdersBusiness> {

  MobileScannerController? cameraController;
  bool _openCamera = false;

  _toggleCamera(bool newState) {
    if(newState == true) {
      setState(() {
        cameraController = MobileScannerController();
        _openCamera = true;
      });
    } else {
      setState(() {
        cameraController = null;
        _openCamera = false;
      });
    }
  }

  Future<void> _setPendingList({
    required PendingOrdersBusinessCubit cubit
  }) async {
    try {
      Api.getPendingOrdersBusiness().then((List<OrderModel> orderList) {
        if(orderList.isEmpty) {
          setState(() {
            resultWidgetPendingList = resultWidgetPendingList = Align( // TODO poner algo más currado
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: const Text(
                    'Cuando alguien compre alguno de sus productos, aparecerán aquí',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          });
        } else {
          cubit.setWholeList(orderList);
          int i = 0;
          setState(() {
            resultWidgetPendingList = SingleChildScrollView(
              child: Column(
                children: cubit.state.map((OrderModel order) {
                  i = i + 1;
                  return PendingOrderBusiness(
                    id: order.id!,
                    receptionMethod: Utils.stringToOrderReceptionMethod(order.receptionMethod),
                    isFirst: (i != 1),
                  );
                }).toList(),
              ),
            );
          });
        }
      });
    } catch(error) {
      setState(() {
        resultWidgetPendingList = Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: const Text('Error'),
        );
      });
    }
  }

  Widget resultWidgetPendingList = const LoadingIcon();
  bool _hasLoadedData = false;

  @override
  Widget build(BuildContext context) {

    PendingOrdersBusinessCubit pendingOrdersBusinessCubit = context.watch<PendingOrdersBusinessCubit>();

    if(_hasLoadedData == false) {
      _setPendingList(
        cubit: pendingOrdersBusinessCubit,
      );
      _hasLoadedData = true;
    }

    void foundQR(Barcode barcode, MobileScannerArguments? args) {
      if(_openCamera == true) {
        String qrContent = barcode.rawValue ?? '';
        int? qrOrderId = int.tryParse(qrContent);
        if(qrOrderId != null) {
          setState(() {
            _toggleCamera(false);
            showDialog(
              context: context,
              builder: (context) {
                return WefoodPopup(
                  context: context,
                  title: '¿Confirmar el pedido ${Utils.numberToHexadecimal(qrOrderId)}',
                  cancelButtonTitle: 'CANCELAR',
                  actions: [
                    TextButton(
                      child: const Text('CONFIRMAR'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const WefoodLoadingPopup(),
                        );
                        Api.completeOrderBusiness(
                          idOrder: qrOrderId,
                        ).then((_) {
                          _setPendingList(
                            cubit: pendingOrdersBusinessCubit,
                          ).then((_) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return WefoodPopup(
                                  context: context,
                                  title: '¡Pedido confirmado!',
                                  description: 'Ya puede entregarle el paquete a su cliente. En los próximos dís recibirá el dinero correspondiente',
                                  cancelButtonTitle: 'OK',
                                );
                              }
                            );
                          });
                        });
                      },
                    ),
                  ],
                );
              },
            );
          });
        } else {
          setState(() {
            _toggleCamera(false);
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Código incorrecto'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Parece que el QR leído no pertenece a WeFood. Si el error persiste, pídale al cliente que valide él mismo su pedido'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          });
        }
      }
    }

    return WefoodScreen(
      title: 'Pedidos pendientes',
      body: [
        Container(
          margin: const EdgeInsets.only(
            top: 20,
            bottom: 50,
          ),
          child: resultWidgetPendingList,
        ),
        if(_openCamera == false) Center(
          child: Column(
            children: <Widget>[
              const Text('Escanear QR de un cliente:'),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () async {
                  _toggleCamera(true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.15,
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          )
        ),
        Visibility(
          visible: _openCamera,
          child: Column(
            children: <Widget>[
              const Text('Escanee QRs para confirmar recogidas:'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: MediaQuery.of(context).size.width - (Environment.defaultHorizontalMargin * 2),
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MobileScanner(
                        controller: cameraController,
                        onDetect: foundQR,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.025,
                      ),
                      child: GestureDetector(
                        child: Container( // TODO deshardcodear este estilo
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.02,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(999),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Icon(
                            Icons.close,
                          ),
                        ),
                        onTap: () {
                          _toggleCamera(false);
                        },
                      ),
                    ),
                  ],
                )
              ),
            ],
          )
        ),
      ],
    );
  }
}