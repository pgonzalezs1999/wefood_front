import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';

class BusinessBankData extends StatefulWidget {
  const BusinessBankData({super.key});
  @override
  State<BusinessBankData> createState() => _BusinessBankDataState();
}

class _BusinessBankDataState extends State<BusinessBankData> {

  String bankName = '';
  String bankAccountType = '';
  String bankAccount = '';
  String bankOwnerName = '';
  String interbankAccount = '';
  String error = 'No changes';

  void checkForErrors() {
    if(
      bankName == context.read<UserInfoCubit>().state.business.bankName &&
      bankAccountType == context.read<UserInfoCubit>().state.business.bankAccountType &&
      bankAccount == context.read<UserInfoCubit>().state.business.bankAccount &&
      bankOwnerName == context.read<UserInfoCubit>().state.business.bankOwnerName &&
      interbankAccount == context.read<UserInfoCubit>().state.business.interbankAccount
    ) {
      setState(() {
        error = 'No changes';
      });
    } else if(Utils.countCharacterRepetitionsInText(bankAccount, ' ') > 0) {
      setState(() {
        error = 'Invalid bank account';
      });
    } else if(Utils.countCharacterRepetitionsInText(bankOwnerName, ' ') <= 0) {
      setState(() {
        error = 'Invalid bank owner name';
      });
    } else if(Utils.countCharacterRepetitionsInText(interbankAccount, ' ') > 0) {
      setState(() {
        error = 'Invalid interbank account';
      });
    } else {
      setState(() {
        error = '';
      });
    }
  }

  @override
  void initState() {
    bankName = context.read<UserInfoCubit>().state.business.bankName ?? '';
    bankAccountType = context.read<UserInfoCubit>().state.business.bankAccountType ?? '';
    bankAccount = context.read<UserInfoCubit>().state.business.bankAccount ?? '';
    bankOwnerName = context.read<UserInfoCubit>().state.business.bankOwnerName ?? '';
    interbankAccount = context.read<UserInfoCubit>().state.business.interbankAccount ?? '';
    super.initState();
  }

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
          initialText: context.read<UserInfoCubit>().state.business.bankName ?? '',
          onChanged: (String value) {
            setState(() {
              bankName = value;
            });
            checkForErrors();
          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Tipo de cuenta',
          initialText: context.read<UserInfoCubit>().state.business.bankAccountType ?? '',
          onChanged: (String value) {
            setState(() {
              bankAccountType = value;
            });
            checkForErrors();
          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Número de cuenta',
          initialText: context.read<UserInfoCubit>().state.business.bankAccount ?? '',
          onChanged: (String value) {
            setState(() {
              bankAccount = value;
            });
            checkForErrors();
          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Titular de la cuenta cuenta',
          upperDescription: 'Por favor, introduzca el nombre exactamente como figure en su cuenta bancaria',
          initialText: context.read<UserInfoCubit>().state.business.bankOwnerName ?? '',
          onChanged: (String value) {
            setState(() {
              bankOwnerName = value;
            });
            checkForErrors();
          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          upperTitle: 'Número de cuenta interbancario',
          initialText: context.read<UserInfoCubit>().state.business.interbankAccount ?? '',
          onChanged: (String value) {
            setState(() {
              interbankAccount = value;
            });
            checkForErrors();
          },
          labelText: '',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Center(
          child: (error == '')
            ? ElevatedButton(
              child: const Text('GUARDAR'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                callRequestWithLoading(
                  context: context,
                  request: () async {
                    return await Api.updateBankInfo(
                      idBusiness: context.read<UserInfoCubit>().state.business.id ?? -1,
                      bankName: bankName,
                      bankAccountType: bankAccountType,
                      bankAccount: bankAccount,
                      bankOwnerName: bankOwnerName,
                      interbankAccount: interbankAccount,
                    );
                  },
                  onSuccess: (_) {
                    context.read<UserInfoCubit>().setBankInfo(
                      bankName: bankName,
                      bankAccountType: bankAccountType,
                      bankAccount: bankAccount,
                      bankOwnerName: bankOwnerName,
                      interbankAccount: interbankAccount,
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return WefoodPopup(
                          context: context,
                          title: '¡Datos actualizados correctamente!',
                        );
                      }
                    );
                  },
                );
              },
            )
            : const BlockedButton(
              text: 'GUARDAR',
            ),
        ),
      ],
    );
  }
}