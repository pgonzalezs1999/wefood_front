import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class EditProductButton extends StatefulWidget {

  final ProductModel product;
  final ProductType productType;

  const EditProductButton({
    super.key,
    required this.product,
    required this.productType,
  });

  @override
  State<EditProductButton> createState() => _EditProductButtonState();
}

class _EditProductButtonState extends State<EditProductButton> {

  void _retrieveData() async {
    ImageModel? imageModel = await Api.getImage(
        idUser: context.read<UserInfoCubit>().state.user.id!,
        meaning: '${Utils.productTypeToChar(widget.productType)}1',
    );
    setState(() {
      imageRoute = imageModel.image;
    });
  }

  @override
  void initState() {
    _retrieveData();
    print('PRODUCT_TYPE: ${Utils.productTypeToChar(widget.productType)}');
    super.initState();
  }

  String? imageRoute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProduct(
              productId: widget.product.id,
              productType: widget.productType,
            )),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if(imageRoute != null) Image.network(
                  imageRoute!,
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                ),
                if(imageRoute == null) Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                Container(
                  color: Colors.white.withOpacity(0.66),
                  width: double.infinity,
                  height: double.infinity,
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 6,
                      sigmaY: 6,
                    ),
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if(widget.productType == ProductType.breakfast) const Expanded(
                            child: Text('Edite sus desayunos'),
                          ),
                          if(widget.productType == ProductType.lunch) const Expanded(
                            child: Text('Edite sus almuerzos'),
                          ),
                          if(widget.productType == ProductType.dinner) const Expanded(
                            child: Text('Edite sus cenas'),
                          ),
                          const SizedBox(
                            width: 35,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9999999),
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            height: 80,
                            width: 80,
                            child: const Icon(
                              Icons.edit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}