import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class BusinessBankData extends StatefulWidget {
  const BusinessBankData({super.key});
  @override
  State<BusinessBankData> createState() => _BusinessBankDataState();
}

class _BusinessBankDataState extends State<BusinessBankData> {

  String bankName = '';
  String bankAccount = '';
  String bankAccountType = '';
  String interbankAccount = '';

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: [
        const BackUpBar(
          title: 'Datos bancarios',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        WefoodInput(
          upperTitle: 'Nombre del banco',
          onChanged: (String value) {

          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Tipo de cuenta',
          onChanged: (String value) {

          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Número de cuenta',
          onChanged: (String value) {

          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Titular de la cuenta cuenta',
          upperDescription: 'Por favor, introduzca el nombre exactamente como figure en su cuenta bancaria',
          onChanged: (String value) {

          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Número de cuenta Interbancario',
          onChanged: (String value) {

          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Center(
          child: ElevatedButton(
            child: const Text('GUARDAR'),
            onPressed: () {

            },
          ),
        ),
      ],
    );
  }
}