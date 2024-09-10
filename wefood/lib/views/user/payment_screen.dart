import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/scroll_to_bottom.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {

  final double price;
  final int itemId;
  final int amount;

  const PaymentScreen({
    required this.price,
    required this.itemId,
    required this.amount,
    super.key,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  String deviceSessionId = "";
  late final WebViewController _controller = WebViewController();

  final ScrollController scrollController = ScrollController();
  PaymentOption chosenOption = PaymentOption.creditCard;
  String error = '';

  String ownerName = '';
  int cardNumber = 0;
  int expirationMonth = 0;
  int expirationYear = 0;
  int securityCode = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          _controller.runJavaScriptReturningResult('''
            OpenPay.setId('mg1ippvpuekjrkszeuxc');
            OpenPay.setApiKey('pk_540273ba143943b999db84f432e85aa3');
            OpenPay.setSandboxMode(false);
            var deviceDataId = OpenPay.deviceData.setup();
            deviceDataId;
          ''').then((result) {
            setState(() {
              deviceSessionId = result.toString().replaceAll('"', '');
              print('EL NUEVO DEVICE_SESSION_ID ES: $deviceSessionId');
            });
          });
        },
      ),
    );
    _controller.loadRequest(
      Uri.dataFromString(
        '''
          <!DOCTYPE html>
          <html lang="es">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Obtener Device Session ID</title>
            <script type="text/javascript" src="https://resources.openpay.mx/lib/openpay-js/1.2.38/openpay.v1.min.js"></script>
            <script type="text/javascript" src="https://resources.openpay.mx/lib/openpay-data-js/1.2.38/openpay-data.v1.min.js"></script>
          </head>
          <body>
            <p id="deviceSessionId">Cargando...</p>
            <script type="text/javascript">
              OpenPay.setId('${Environment.openpayMerchantId}');
              OpenPay.setApiKey('${Environment.openpayPublicKey}');
              OpenPay.setSandboxMode(false);
              var deviceDataId = OpenPay.deviceData.setup();
              document.getElementById('deviceSessionId').textContent = deviceDataId;
            </script>
          </body>
          </html>
        ''',
        mimeType: 'text/html',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/images/openpay/circulo_pasarela.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.075,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Pago con  ',
                        style: TextStyle(
                          color: Color(0xFF004181),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Image.asset(
                        'assets/images/openpay/openpay_logo.png',
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Vas a pagar el importe de S/ ${widget.price}. ',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF004181),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: 'Selecciona el método de pago que quieres usar:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  if(chosenOption == PaymentOption.creditCard) Container(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01,
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD7D7D6),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Expanded(
                              child: SvgPicture.asset(
                                'assets/images/openpay/visa.svg',
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Expanded(
                              child: SvgPicture.asset(
                                'assets/images/openpay/mastercard.svg',
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Expanded(
                              child: SvgPicture.asset(
                                'assets/images/openpay/american-express.svg',
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Expanded(
                              child: SvgPicture.asset(
                                'assets/images/openpay/diners.svg',
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFBBBBBB),
                            ),
                          ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'Nombre del Titular',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBBBBB),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                error = '';
                                ownerName = newValue;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFBBBBBB),
                            ),
                          ),
                          child: TextField(
                            inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'Número de la tarjeta',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBBBBB),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (String newValue) {
                              if(newValue != '') {
                                int newNumber = int.parse(newValue);
                                setState(() {
                                  error = '';
                                  cardNumber = newNumber;
                                });
                              } else {
                                setState(() {
                                  error = '';
                                  cardNumber = 0;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: const Color(0xFFBBBBBB),
                                  ),
                                ),
                                child: TextField(
                                  inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: 'Mes Expiración',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFBBBBBB),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (String newValue) {
                                    if(newValue != '') {
                                      int newNumber = int.parse(newValue);
                                      setState(() {
                                        error = '';
                                        expirationMonth = newNumber;
                                      });
                                    } else {
                                      setState(() {
                                        error = '';
                                        expirationMonth = 0;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.025,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: const Color(0xFFBBBBBB),
                                  ),
                                ),
                                child: TextField(
                                  inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: 'Año Expiración',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFBBBBBB),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (String newValue) {
                                    if(newValue != '') {
                                      int newNumber = int.parse(newValue);
                                      setState(() {
                                        error = '';
                                        expirationYear = newNumber;
                                      });
                                    } else {
                                      setState(() {
                                        error = '';
                                        expirationYear = 0;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFBBBBBB),
                            ),
                          ),
                          child: TextField(
                            inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'Código de seguridad',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBBBBB),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (String newValue) {
                              if(newValue != '') {
                                int newNumber = int.parse(newValue);
                                setState(() {
                                  error = '';
                                  securityCode = newNumber;
                                });
                              } else {
                                setState(() {
                                  error = '';
                                  securityCode = 0;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        if(error != '' && error != 'Loading') Align(
                          alignment: Alignment.center,
                          child: FeedbackMessage(
                            message: error,
                            isError: true,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004580),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            scrollToBottom(
                              scrollController: scrollController,
                            );
                            setState(() {
                              error = 'Loading';
                            });
                            if(ownerName == '') {
                              setState(() {
                                error = 'Introduce el nombre del titular';
                              });
                            } else if(cardNumber <= 99999999999999 || cardNumber > 9999999999999999) { // Only 15-16 digits allowed
                              setState(() {
                                error = 'Número de tarjeta no válido';
                              });
                            } else if(expirationMonth <= 0 || expirationMonth > 12) {
                              setState(() {
                                error = 'Mes de expiración no válido';
                              });
                            } else if(expirationYear < 24 || expirationYear > 99) {
                              setState(() {
                                error = 'Año de expiración no válido';
                              });
                            } else if(securityCode < 0 || securityCode > 9999) {
                              setState(() {
                                error = 'Código de seguridad no válido';
                              });
                            } else {
                              callRequestWithLoading(
                                context: context,
                                request: () async {
                                  return await Api.openpayPayment(
                                    idItem: widget.itemId,
                                    amount: widget.amount,
                                    price: widget.price,
                                    holderName: ownerName,
                                    cardNumber: cardNumber,
                                    expirationMonth: expirationMonth,
                                    expirationYear: expirationYear,
                                    cvv2: securityCode,
                                    deviceSessionId: deviceSessionId,
                                  );
                                },
                                onSuccess: (String status) {
                                  setState(() {
                                    if(status == 'completed') {
                                      error = '';
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return WefoodPopup(
                                            context: context,
                                            title: '¡Producto comprado!',
                                            description: 'Cuando llegue al establecimiento, enseñe el QR que encontrará en \nPerfil -> Pedidos pendientes.\n¡Que aproveche!',
                                            cancelButtonTitle: 'OK',
                                          );
                                        }
                                      );
                                    } else {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return WefoodPopup(
                                            context: context,
                                            title: 'Pago rechazado',
                                            cancelButtonTitle: 'OK',
                                          );
                                        }
                                      );
                                    }
                                  });
                                },
                                onError: (error) {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WefoodPopup(
                                        context: context,
                                        title: 'Ha ocurrido un error al realizar el pago',
                                        description: 'Por favor, inténtelo de nuevo más tarde: $error',
                                        cancelButtonTitle: 'OK',
                                      );
                                    }
                                  );
                                }
                              );
                            }
                          },
                          child: const Text('Pagar'),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}