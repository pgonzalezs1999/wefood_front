import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/business/business_bank_data.dart';

class BusinessRetributions extends StatefulWidget {
  const BusinessRetributions({super.key});

  @override
  State<BusinessRetributions> createState() => _BusinessRetributionsState();
}

class _BusinessRetributionsState extends State<BusinessRetributions> {

  List<Retribution> retributions = [];
  LoadingStatus loadingRetributions = LoadingStatus.loading;

  _retrieveData() {
    Api.getRetributionsFromBusiness(
      id: context.read<UserInfoCubit>().state.user.idBusiness!,
    ).then((List<RetributionModel> response) {
      setState(() {
        retributions = response.asMap().entries.map((entry) {
          int idx = entry.key;
          RetributionModel r = entry.value;
          return Retribution(
            retribution: r,
            isFirst: (idx == 0),
          );
        }).toList();
        setState(() {
          loadingRetributions = LoadingStatus.successful;
        });
      });
    }).onError((error, stackTrace) {
      setState(() {
        loadingRetributions = LoadingStatus.error;
      });
    });
  }

  void _navigateToBusinessBankData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessBankData()),
    );
  }

  @override
  void initState() {
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: <Widget>[
        const BackUpBar(
          title: 'Cobros',
        ),
        if(loadingRetributions == LoadingStatus.successful && retributions.isNotEmpty) Column(
          children: retributions,
        ),
        if(loadingRetributions == LoadingStatus.successful && retributions.isEmpty) Align(
          alignment: Alignment.center,
          child: Card(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.width * 0.025,
              ),
              child: const Text(
                'Aún no figura ningún cobro para su negocio',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if(loadingRetributions == LoadingStatus.loading) const LoadingIcon(),
        if(loadingRetributions == LoadingStatus.error) Align(
          alignment: Alignment.center,
          child: Card(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.width * 0.025,
              ),
              child: const Text(
                'Ha ocurrido un error al cargar los cobros. Por favor, inténtelo de nuevo más tarde',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.075,
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToBusinessBankData();
        },
        label: const Text('DATOS BANCARIOS'),
        icon: const Icon(
          Icons.credit_card,
        ),
      ),
    );
  }
}
