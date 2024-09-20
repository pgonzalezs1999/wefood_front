import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/scroll_to_bottom.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

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
  String deviceSessionId = '';
  String tokenOpenPay = '';
  late final WebViewController _controller = WebViewController();
  final ScrollController scrollController = ScrollController();

  PaymentOption chosenOption = PaymentOption.creditCard;
  String error = '';
  String ownerName = '';
  String cardNumber = '';
  String expirationMonth = '';
  String expirationYear = '';
  String securityCode = '';

  TextEditingController ownerController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController monthExpirationController = TextEditingController();
  TextEditingController yearExpirationController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();    
    _initializeWebView();
    ownerName = 'Matthew Daniel Herrera Ortega';
    cardNumber = '4213550175102531';
    expirationMonth = '05';
    expirationYear = '29';
    securityCode = '232';
    ownerController.text = ownerName;
    cardNumberController.text = cardNumber;
    monthExpirationController.text = expirationMonth;
    yearExpirationController.text = expirationYear;
    cvvController.text = securityCode;
    getOpenpayToken();
  }

  void _initializeWebView() {
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) async {
          _controller.runJavaScriptReturningResult('''
            OpenPay.setId('mg1ippvpuekjrkszeuxc');
            OpenPay.setApiKey('pk_540273ba143943b999db84f432e85aa3');
            OpenPay.setSandboxMode(false);
            var deviceDataId = OpenPay.deviceData.setup();
            deviceDataId;
          ''').then((result) {
            setState(() {
              deviceSessionId = result.toString().replaceAll('"', '');
              print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Device Session ID: $deviceSessionId');
              // setupOpenPay();
            });
          });
        }
      )
    );
    _controller.loadRequest(
      Uri.dataFromString('''
        <!DOCTYPE html>
          <html>
          <head>
              <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
              <script type="text/javascript" src="https://js.openpay.pe/openpay.v1.min.js"></script>
              <script type="text/javascript" src="https://js.openpay.pe/openpay-data.v1.min.js"></script>
          </head>
          </html>
        ''',
        mimeType: 'text/html',
      )
    );
  }

  Future<void> getOpenpayToken() async {
    const String apiUrl = "https://api.openpay.pe/v1/mg1ippvpuekjrkszeuxc/tokens";
    Map<String, dynamic> cardData = {
      "holder_name": ownerName,
      "card_number": cardNumber,
      "cvv2": securityCode,
      "expiration_month": expirationMonth,
      "expiration_year": expirationYear,
      /*"address": {
        "city": "Lima",
        "postal_code": "00051",
        "country_code": "PE",
        "state": "La Victoria",
        "line1": "URB. APOLO",
      }*/
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('pk_540273ba143943b999db84f432e85aa3:'))}',
        },
        body: jsonEncode(cardData),
      );
      // Procesa la respuesta
      if(response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        tokenOpenPay = responseData['id'];
        deviceSessionId = await _controller.runJavaScriptReturningResult('OpenPay.deviceData.setup()') as String;
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Token: $tokenOpenPay');
      } else {
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Error en el response: ${response.statusCode}');
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Respuesta del servidor: ${response.body}');
      }
    } catch (error) {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Error al generar el token: $error');
    }
  }  

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Stack(
          children: <Widget>[
             // WebView que genera el deviceSessionId
            Positioned.fill(
              child: WebViewWidget(controller: _controller),
            ),
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
                            controller: ownerController,
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
                            controller: cardNumberController,
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
                                String newNumber = newValue;
                                setState(() {
                                  error = '';
                                  cardNumber = newNumber;
                                });
                              } else {
                                setState(() {
                                  error = '';
                                  cardNumber = '';
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
                                  controller: monthExpirationController,
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
                                      String newNumber = newValue;
                                      setState(() {
                                        error = '';
                                        expirationMonth = newNumber;
                                      });
                                    } else {
                                      setState(() {
                                        error = '';
                                        expirationMonth = '';
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
                                  controller: yearExpirationController,
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
                                      String newNumber = newValue;
                                      setState(() {
                                        error = '';
                                        expirationYear = newNumber;
                                      });
                                    } else {
                                      setState(() {
                                        error = '';
                                        expirationYear = '';
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
                            controller: cvvController,
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
                                String newNumber = newValue;
                                setState(() {
                                  error = '';
                                  securityCode = newNumber;
                                });
                              } else {
                                setState(() {
                                  error = '';
                                  securityCode = '';
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
                            /*} else if(cardNumber <= 99999999999999 || cardNumber > 9999999999999999) { // Only 15-16 digits allowed
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
                              });*/
                            } else {
                              try {
                                // Llamada a setupOpenPay para obtener el token
                                getOpenpayToken().then((value) {
                                  print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TOKEN OPENPAY: $tokenOpenPay');
                                  if(deviceSessionId.isNotEmpty && tokenOpenPay.isNotEmpty) {
                                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> D_S_I Y TOKEN AMBOS RELLENOS");
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
                                          token: tokenOpenPay,
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
                                  } else {
                                    setState(() {
                                      error = 'No se pudo generar el token o el deviceSessionId';
                                    });
                                  }
                                });
                              } catch(e) {
                                setState(() {
                                  error = 'Error al procesar el pago: $e';
                                });
                              }
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


