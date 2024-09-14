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
    if(context.read<BusinessBreakfastCubit>().state?.id == null && context.read<BusinessLunchCubit>().state?.id == null && context.read<BusinessDinnerCubit>().state?.id == null) {
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
    } else {
      setState(() {
        isRetrieving = false;
      });
    }
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
        if(retrievingResumeError == false && isRetrieving == true) Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Gestionar productos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const _BusinessManagementTitle(
              isLoading: true,
            ),
            const SkeletonEditProductButton(),
            const _BusinessManagementTitle(
              isLoading: true,
            ),
            const SkeletonEditProductButton(),
            const _BusinessManagementTitle(
              isLoading: true,
            ),
            const SkeletonEditProductButton(),
          ],
        ),
        if(retrievingResumeError == false && isRetrieving == false) Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestionar productos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
            ),
            const _BusinessManagementTitle(
              title: 'Desayunos',
            ),
            EditProductButton(
              product: businessBreakfastCubit.state,
              productType: ProductType.breakfast,
            ),
            const _BusinessManagementTitle(
              title: 'Almuerzos',
            ),
            EditProductButton(
              product: businessLunchCubit.state,
              productType: ProductType.lunch,
            ),
            const _BusinessManagementTitle(
              title: 'Cenas',
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

class _BusinessManagementTitle extends StatefulWidget {

  final String title;
  final bool isLoading;

  const _BusinessManagementTitle({
    super.key,
    this.title = 'Not set',
    this.isLoading = false,
  });

  @override
  State<_BusinessManagementTitle> createState() => _BusinessManagementTitleState();
}

class _BusinessManagementTitleState extends State<_BusinessManagementTitle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.025,
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      child: (widget.isLoading)
        ? Container(
          margin: const EdgeInsets.only(
            top: 20,
          ),
          child: SkeletonText(
            width: MediaQuery.of(context).size.width * 0.25,
          ),
        )
        : Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
  }
}
