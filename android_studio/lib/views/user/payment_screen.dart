import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/scroll_to_bottom.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';

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

  final ScrollController scrollController = ScrollController();
  PaymentOption chosenOption = PaymentOption.creditCard;
  String error = '';

  String ownerName = '';
  int cardNumber = 0;
  int expirationMonth = 0;
  int expirationYear = 0;
  int securityCode = 0;

  void _showCenterMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: MediaQuery.of(context).size.height * 0.75,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 100),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: PaymentOptionCard(
                          title: 'Tarjeta de crédito o débito',
                          image: 'assets/images/openpay/tarjeta.svg',
                          option: PaymentOption.creditCard,
                          isSelected: chosenOption == PaymentOption.creditCard,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _showCenterMessage('Esta funcionalidad aún no está disponible');
                          },
                          child: PaymentOptionCard(
                            title: 'Pago digital a través de la App o Web de tu banco',
                            image: 'assets/images/openpay/digital.svg',
                            option: PaymentOption.bankApp,
                            isSelected: chosenOption == PaymentOption.bankApp,
                          ),
                        ),
                      ),
                    ],
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
                            } else if(securityCode < 0 || securityCode > 999) {
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
                                      error = status;
                                    }
                                  });
                                },
                                onError: (error) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WefoodPopup(
                                        context: context,
                                        title: 'Ha ocurrido un error',
                                        description: '$error',
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

class PaymentOptionCard extends StatefulWidget {

  final String title;
  final String image;
  final PaymentOption option;
  final bool isSelected;

  const PaymentOptionCard({
    required this.title,
    required this.image,
    required this.option,
    this.isSelected = false,
    super.key,
  });

  @override
  State<PaymentOptionCard> createState() => _PaymentOptionCardState();
}

class _PaymentOptionCardState extends State<PaymentOptionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE9F7FF),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: widget.isSelected == false ? null : BoxDecoration(
          border: Border.all(
            color: const Color(0xFF004181),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            SvgPicture.asset(
              widget.image,
              height: MediaQuery.of(context).size.width * 0.2,
              width: MediaQuery.of(context).size.width * 0.2,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF004181),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
