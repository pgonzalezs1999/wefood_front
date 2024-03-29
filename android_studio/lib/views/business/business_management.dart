import 'package:flutter/material.dart';
import 'package:wefood/components/create_product_button.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/edit_product_button.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/models/business_products_resume_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';

class BusinessManagement extends StatefulWidget {
  const BusinessManagement({super.key});

  @override
  State<BusinessManagement> createState() => _BusinessManagementState();
}

class _BusinessManagementState extends State<BusinessManagement> {

  Widget resultWidget = const LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return WefoodNavigationScreen(
      children: [
        FutureBuilder<BusinessProductsResumeModel>(
          future: Api.businessProductsResume(),
          builder: (BuildContext context, AsyncSnapshot<BusinessProductsResumeModel> response) {
            if(response.hasError) {
              resultWidget = Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.05,
                ),
                child: Text('Error ${response.error}'),
              );
            } else if(response.hasData) {
              resultWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.025,
                      bottom: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: const Text('Desayunos:'),
                  ),
                  if(response.data!.breakfast != null) EditProductButton(
                    product: response.data!.breakfast!,
                    productType: ProductType.breakfast,
                  ),
                  if(response.data!.breakfast == null) const CreateProductButton(
                    productType: ProductType.breakfast,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.025,
                      bottom: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: const Text('Almuerzos:'),
                  ),
                  if(response.data!.lunch != null) EditProductButton(
                    product: response.data!.lunch!,
                    productType: ProductType.lunch,
                  ),
                  if(response.data!.lunch == null) const CreateProductButton(
                    productType: ProductType.lunch,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.025,
                      bottom: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: const Text('Cenas:'),
                  ),
                  if(response.data!.dinner != null) EditProductButton(
                    product: response.data!.dinner!,
                    productType: ProductType.dinner,
                  ),
                  if(response.data!.dinner == null) const CreateProductButton(
                    productType: ProductType.dinner,
                  ),
                ],
              );
            }
            return resultWidget;
          }
        ),
        const SizedBox(
          height: 50,
        ),
        Align(
          child: ElevatedButton(
            onPressed: () {
              // TODO falta crear esta pantalla
            },
            child: const Text('RECOGIDAS'),
          ),
        ),
      ],
    );
  }
}