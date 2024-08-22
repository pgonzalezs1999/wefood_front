import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class BusinessManagement extends StatefulWidget {
  const BusinessManagement({super.key});

  @override
  State<BusinessManagement> createState() => _BusinessManagementState();
}

class _BusinessManagementState extends State<BusinessManagement> {

  bool isRetrieving = true;
  bool retrievingResumeError = false;

  void _navigateToPendingOrdersBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PendingOrdersBusiness()),
    );
  }

  void _retrieveData() async {
    await Api.getBusinessProductsResume().then((BusinessProductsResumeModel value) {
      context.read<BusinessBreakfastCubit>().set(value.breakfast);
      context.read<BusinessLunchCubit>().set(value.lunch);
      context.read<BusinessDinnerCubit>().set(value.dinner);
    }).onError((error, stackTrace) {
      setState(() {
        retrievingResumeError = true;
      });
    });
    setState(() {
      isRetrieving = false;
    });
  }

  @override
  void initState() {
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final BusinessBreakfastCubit businessBreakfastCubit = context.watch<BusinessBreakfastCubit>();
    final BusinessLunchCubit businessLunchCubit = context.watch<BusinessLunchCubit>();
    final BusinessDinnerCubit businessDinnerCubit = context.watch<BusinessDinnerCubit>();

    return WefoodNavigationScreen(
      children: [
        if(retrievingResumeError == true) Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: const Text('Error'),
        ),
        if(retrievingResumeError == false && isRetrieving == true) const LoadingIcon(),
        if(retrievingResumeError == false && isRetrieving == false) Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestionar productos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Container(
              margin: EdgeInsets.only(
                top: 20,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Text(
                'Desayunos:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            EditProductButton(
              product: businessBreakfastCubit.state,
              productType: ProductType.breakfast,
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Text(
                'Almuerzos:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            EditProductButton(
              product: businessLunchCubit.state,
              productType: ProductType.lunch,
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Text(
                'Cenas:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            EditProductButton(
              product: businessDinnerCubit.state,
              productType: ProductType.dinner,
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        Align(
          child: ElevatedButton(
            onPressed: () {
              _navigateToPendingOrdersBusiness();
            },
            child: const Text('RECOGIDAS'),
          ),
        ),
      ],
    );
  }
}