import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/scroll_to_bottom.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
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
  List<BankCardModel> savedBankCards = [];
  BankCardModel currentBankCard = BankCardModel.empty();
  String? currentCvv2;
  bool fieldsAreValid = false;
  bool fieldsReadOnly = false;
  bool wantsToSaveCard = false;
  String deviceSessionId = '';
  String tokenOpenPay = '';
  late final WebViewController _controller = WebViewController();
  final ScrollController scrollController = ScrollController();

  PaymentOption chosenOption = PaymentOption.creditCardNew;
  String feedback = 'Start';

  TextEditingController ownerController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expirationMonthController = TextEditingController();
  TextEditingController expirationYearController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  @override
  void initState() {
    _getBankCards(savedBankCards);
    _getOpenpayDeviceSessionId();
    super.initState();
  }

  _getBankCards(List<BankCardModel> bankCardList) {
    UserSecureStorage().read(key: 'paymentCards').then((paymentCards) {
      if(paymentCards != '' && paymentCards != null) {
        List<String> splitByComma = paymentCards.split('&comma;');
        for(int i = 0; i < splitByComma.length; i++) {
          List<String> splitByDash = splitByComma[i].split('&mdash;');
          if(splitByDash.length > 2) {
            setState(() {
              bankCardList.add(BankCardModel.fromJson({
                'owner_name': splitByDash[0].replaceAll('&nbsp;', ' '),
                'card_number': int.parse(splitByDash[1]),
                'expiration_month': int.parse(splitByDash[2]),
                'expiration_year': int.parse(splitByDash[3]),
              }));
            });
          }
        }
      }
    });
  }

  _loadBankCard(String savedOwnerName, int savedCardNumber, int savedExpirationMonth, int savedExpirationYear) {
    ownerController.text = savedOwnerName;
    cardNumberController.text = savedCardNumber.toString();
    expirationMonthController.text = savedExpirationMonth.toString();
    expirationYearController.text = savedExpirationYear.toString();
    currentBankCard.ownerName = savedOwnerName;
    currentBankCard.cardNumber = savedCardNumber;
    currentBankCard.expirationMonth = savedExpirationMonth;
    currentBankCard.expirationYear = savedExpirationYear;
    _checkFieldsValid();
  }

  bool _bankCardAlreadySaved(BankCardModel attempting) {
    bool result = false;
    for(int i = 0; i < savedBankCards.length; i++) {
      if(savedBankCards[i].ownerName == attempting.ownerName &&
        savedBankCards[i].cardNumber == attempting.cardNumber &&
          savedBankCards[i].expirationMonth == attempting.expirationMonth &&
          savedBankCards[i].expirationYear == attempting.expirationYear) {
        result = true;
      }
    }
    return result;
  }

  _getOpenpayDeviceSessionId() async {
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
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
      ),
    );
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          _controller.runJavaScriptReturningResult('''
            OpenPay.setId('${Environment.openpayMerchantId}');
            OpenPay.setApiKey('${Environment.openpayPublicKey}');
            OpenPay.setSandboxMode(${Environment.openpayIsSandbox});
            var deviceDataId = OpenPay.deviceData.setup();
            deviceDataId;
          ''').then((result) {
            setState(() {
              deviceSessionId = result.toString().replaceAll('"', '');
            });
          });
        },
      ),
    );
  }

  _checkFieldsValid() {
    if(currentBankCard.ownerName == '') {
      setState(() {
        fieldsAreValid = false;
        feedback = 'Introduce el nombre del titular';
      });
    } else if(currentBankCard.cardNumber == null || currentBankCard.cardNumber! <= 99999999999999 ||currentBankCard. cardNumber! > 9999999999999999) { // Only 15-16 digits allowed
      setState(() {
        fieldsAreValid = false;
        feedback = 'Número de tarjeta no válido';
      });
    } else if(currentBankCard.expirationMonth == null || currentBankCard.expirationMonth! < 1 || currentBankCard.expirationMonth! > 12) {
      setState(() {
        fieldsAreValid = false;
        feedback = 'Mes de expiración no válido';
      });
    } else if(currentBankCard.expirationYear == null || currentBankCard.expirationYear! < 24 || currentBankCard.expirationYear! > 44) {
      setState(() {
        fieldsAreValid = false;
        feedback = 'Año de expiración no válido';
      });
    } else if(currentCvv2 == null || currentCvv2!.length < 3 || currentCvv2!.length > 4) {
      setState(() {
        fieldsAreValid = false;
        feedback = 'Código de seguridad no válido';
      });
    } else {
      setState(() {
        feedback = '';
        fieldsAreValid = true;
      });
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
            SizedBox(
              width: 1,
              height: 1,
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
                          text: 'Vas a pagar el importe de S/ ${widget.price.toStringAsFixed(2)}. ',
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
                  if(chosenOption == PaymentOption.creditCardNew) Container(
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
                            readOnly: fieldsReadOnly,
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
                                currentBankCard.ownerName = newValue;
                                _checkFieldsValid();
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
                            readOnly: fieldsReadOnly,
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
                              setState(() {
                                currentBankCard.cardNumber = int.tryParse(newValue);
                              });
                              _checkFieldsValid();
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
                                  readOnly: fieldsReadOnly,
                                  controller: expirationMonthController,
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
                                    setState(() {
                                      currentBankCard.expirationMonth = int.tryParse(newValue);
                                    });
                                    _checkFieldsValid();
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
                                  readOnly: fieldsReadOnly,
                                  controller: expirationYearController,
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
                                    setState(() {
                                      currentBankCard.expirationYear = int.tryParse(newValue);
                                    });
                                    _checkFieldsValid();
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
                            readOnly: fieldsReadOnly,
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
                              setState(() {
                                currentCvv2 = newValue;
                              });
                              _checkFieldsValid();
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        if(feedback != '' && feedback != 'Start' && feedback != 'Loading') Align(
                          alignment: Alignment.center,
                          child: FeedbackMessage(
                            message: feedback,
                            isError: true,
                          ),
                        ),
                        if(feedback == 'Start') const BlockedButton(
                          text: 'Pagar',
                        ),
                        if(feedback == 'Loading') const LoadingIcon(),
                        if(feedback == '') ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004580),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Pagar'),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            scrollToBottom(
                              scrollController: scrollController,
                            );
                            if(fieldsAreValid == true) {
                              if(wantsToSaveCard == true && _bankCardAlreadySaved(currentBankCard) == false) {
                                UserSecureStorage().read(key: 'paymentCards').then((paymentCards) {
                                  String resultString = '${(paymentCards != null && paymentCards != 'null') ? paymentCards : ''}${currentBankCard.ownerName!.replaceAll(' ', '&nbsp;')}&mdash;${currentBankCard.cardNumber}&mdash;${currentBankCard.expirationMonth}&mdash;${currentBankCard.expirationYear}&comma;';
                                  UserSecureStorage().write(
                                    key: 'paymentCards',
                                    value: resultString,
                                  ).then((value) {
                                  });
                                });
                              }
                              setState(() {
                                fieldsReadOnly = true;
                                feedback = 'Loading';
                              });
                              Api.openpayGetToken(
                                ownerName: currentBankCard.ownerName!,
                                cardNumber: currentBankCard.cardNumber!,
                                expirationMonth: currentBankCard.expirationMonth!,
                                expirationYear:currentBankCard. expirationYear!,
                                securityCode: currentCvv2!.toString(),
                              ).then((tokenJSON) {
                                setState(() {
                                  tokenOpenPay = tokenJSON;
                                  feedback = '';
                                });
                                callRequestWithLoading(
                                  context: context,
                                  request: () async {
                                    return await Api.openpayPayment(
                                      idItem: widget.itemId,
                                      amount: widget.amount,
                                      price: widget.price,
                                      deviceSessionId: deviceSessionId,
                                      token: tokenOpenPay,
                                    );
                                  },
                                  onSuccess: (String status) {
                                    setState(() {
                                      if(status == 'completed') {
                                        feedback = '';
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        wefoodShowDialog(
                                          context: context,
                                          title: '¡Producto comprado!',
                                          description: 'Cuando llegue al establecimiento, enseñe el QR que encontrará en \nPerfil -> Pedidos pendientes.\n¡Que aproveche!',
                                          cancelButtonTitle: 'OK',
                                        );
                                      } else {
                                        Navigator.of(context).pop();
                                        wefoodShowDialog(
                                          context: context,
                                          title: 'Pago rechazado', // status, // 'Pago rechazado',
                                          cancelButtonTitle: 'OK',
                                        );
                                      }
                                    });
                                  },
                                  onError: (error) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    print('---------------------------');
                                    print(error);
                                    print('---------------------------');
                                    wefoodShowDialog(
                                      context: context,
                                      title: 'Ha ocurrido un error al realizar el pago',
                                      description: 'Por favor, inténtelo de nuevo más tarde: $error',
                                      cancelButtonTitle: 'OK',
                                    );
                                  }
                                );
                              }).onError((error, stackTrace) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                wefoodShowDialog(
                                  context: context,
                                  title: 'Pago rechazado',
                                  cancelButtonTitle: 'OK',
                                );
                              });
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Guardar tarjeta para futuras compras',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Checkbox(
                              value: wantsToSaveCard,
                              onChanged: (newValue) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  wantsToSaveCard = !wantsToSaveCard;
                                });
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  if(chosenOption == PaymentOption.creditCardNew) Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Pagar con otra tarjeta ya guardada:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if(savedBankCards.isEmpty) const Text(
                        'No se han encontrado tarjetas guardadas',
                      ),
                      if(savedBankCards.isNotEmpty) ...savedBankCards.map((bankCard) => _PaymentScreenBankCard(
                        bankCard: bankCard,
                        onSelect: () => _loadBankCard(bankCard.ownerName!, bankCard.cardNumber!, bankCard.expirationMonth!, bankCard.expirationYear!),
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
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

class _PaymentScreenBankCard extends StatefulWidget {

  final BankCardModel bankCard;
  final Function() onSelect;

  const _PaymentScreenBankCard({
    required this.bankCard,
    required this.onSelect,
  });

  @override
  State<_PaymentScreenBankCard> createState() => _PaymentScreenBankCardState();
}

class _PaymentScreenBankCardState extends State<_PaymentScreenBankCard> {

  String _obfuscatedCardNumber() {
    String lastPart = widget.bankCard.cardNumber.toString().substring(widget.bankCard.cardNumber.toString().length - 4);
    return 'xxxxxxxxxxxx$lastPart';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: widget.onSelect,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            decoration: BoxDecoration(
              color: const Color(0x10000000),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${widget.bankCard.ownerName}'),
                Text('Nº ${_obfuscatedCardNumber()} - Exp. ${widget.bankCard.expirationMonth}/${widget.bankCard.expirationYear}'),
              ],
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
