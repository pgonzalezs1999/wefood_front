import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/create_product_button.dart';
import 'package:wefood/components/edit_product_button.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/models/business_products_resume_model.dart';
import 'package:wefood/models/image_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/business/pending_orders_business.dart';

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
    ImageModel? picture = await Api.getImage(
        idUser: 26,
        meaning: 'profile',
    );
    imageUrl = picture?.image;
    await Api.businessProductsResume().then((BusinessProductsResumeModel value) {
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

  String? imageUrl;

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
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: const Text('Desayunos:'),
            ),
            if(businessBreakfastCubit.state != null) EditProductButton(
              product: businessBreakfastCubit.state!,
              productType: ProductType.breakfast,
            ),
            if(businessBreakfastCubit.state == null) const CreateProductButton(
              productType: ProductType.breakfast,
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: const Text('Almuerzos:'),
            ),
            if(businessLunchCubit.state != null) EditProductButton(
              product: businessLunchCubit.state!,
              productType: ProductType.lunch,
            ),
            if(businessLunchCubit.state == null) const CreateProductButton(
              productType: ProductType.lunch,
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              child: const Text('Cenas:'),
            ),
            if(businessDinnerCubit.state != null) EditProductButton(
              product: businessDinnerCubit.state!,
              productType: ProductType.dinner,
            ),
            if(businessDinnerCubit.state == null) const CreateProductButton(
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
        (imageUrl != null) ? Image.network(imageUrl!) : const LoadingIcon(),
      ],
    );
  }
}