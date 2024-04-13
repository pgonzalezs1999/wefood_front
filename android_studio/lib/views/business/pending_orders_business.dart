import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/order_pending_list_business.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/services/auth/api/api.dart';

class PendingOrdersBusiness extends StatefulWidget {
  const PendingOrdersBusiness({super.key});

  @override
  State<PendingOrdersBusiness> createState() => _PendingOrdersBusinessState();
}

class _PendingOrdersBusinessState extends State<PendingOrdersBusiness> {

  MobileScannerController cameraController = MobileScannerController();
  bool _openCamera = false;

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Pedidos pendientes'),
            ],
          ),
          const OrderPendingListBusiness(),
          const SizedBox(
            height: 50,
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
                    setState(() {
                      _openCamera = true;
                    });
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
            child: MobileScanner(
              controller: cameraController,
              onDetect: _foundQR,
            ),
          ),
        ],
      ),
    );
  }

 void _foundQR(Barcode barcode, MobileScannerArguments? args) {
   if(_openCamera == true) {
     String qrContent = barcode.rawValue ?? '';
     int? qrOrderId = int.tryParse(qrContent);
     if(qrOrderId != null) {
       setState(() {
         _openCamera = false;
         showDialog(
           context: context,
           builder: (context) {
             return StatefulBuilder(
               builder: (context, setState) {
                 return AlertDialog(
                   title: const Text('¿Confirmar recogida?'),
                   content: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       Text('¿Confirmar el pedido ${CustomParsers.numberToHexadecimal(qrOrderId)}'),
                     ],
                   ),
                   actions: [
                     TextButton(
                       onPressed: () {
                         Navigator.of(context).pop();
                       },
                       child: const Text('CANCELAR'),
                     ),
                     TextButton(
                       onPressed: () async {
                         await Api.completeOrderBusiness(
                           idOrder: qrOrderId,
                         ).then((_) {
                           setState(() {
                             Navigator.pop(context);
                           });
                         });
                       },
                       child: const Text('CONFIRMAR'),
                     ),
                   ],
                 );
               },
             );
           },
         );
       });
     } else {
       setState(() {
         _openCamera = false;
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
}