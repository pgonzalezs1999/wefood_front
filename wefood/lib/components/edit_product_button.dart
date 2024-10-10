import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class EditProductButton extends StatefulWidget {

  final ProductModel? product;
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

  void _retrieveImage() async {
    if(_product?.id != null) {
      Api.getImage(
        idUser: context.read<UserInfoCubit>().state.user.id!,
        meaning: '${Utils.productTypeToChar(widget.productType)}1',
      ).then((ImageModel? imageModel) {
        if(imageModel?.route != null) {
          setState(() {
            imageRoute = imageModel!.route!;
          });
        }
      });
    }
  }

  @override
  void initState() {
    setState(() {
      _product = widget.product;
    });
    _retrieveImage();
    super.initState();
  }

  String? imageRoute;
  ProductModel? _product;

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
              productId: _product?.id,
              productType: widget.productType,
            )),
          ).whenComplete(() async {
            Api.getBusinessProductsResume().then((BusinessProductsResumeModel products) {
              _retrieveImage();
              if(widget.productType == ProductType.breakfast) {
                setState(() {
                  _product = products.breakfast;
                  context.read<BusinessBreakfastCubit>().set(products.breakfast);
                });
              } else if(widget.productType == ProductType.lunch) {
                setState(() {
                  _product = products.lunch;
                  context.read<BusinessBreakfastCubit>().set(products.lunch);
                });
              } else if(widget.productType == ProductType.dinner) {
                setState(() {
                  _product = products.dinner;
                  context.read<BusinessBreakfastCubit>().set(products.dinner);
                });
              }
            });
            Api.getImage(
              idUser: context.read<UserInfoCubit>().state.user.id!,
              meaning: '${Utils.productTypeToChar(widget.productType).toLowerCase()}1',
            ).then((ImageModel imageModel) {
              setState(() {
                imageRoute = imageModel.route;
              });
            });
          });
        },
        child: Card(
          elevation: 3,
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
                  color: Colors.white.withOpacity((widget.product?.id != null) ? 0.85 : 0.925),
                  width: double.infinity,
                  height: double.infinity,
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: (widget.product?.id != null) ? 2 : 1,
                      sigmaY: (widget.product?.id != null) ? 2 : 1,
                    ),
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${(_product?.id != null) ? 'Edite sus' : 'Cree productos para el horario de '} ${
                                (widget.productType == ProductType.breakfast) ? 'desayuno'
                                  : (widget.productType == ProductType.lunch) ? 'almuerzo'
                                  : 'cena'
                              }s',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(9999999),
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
                            ),
                            height: 80,
                            width: 80,
                            child: (widget.product?.id != null)
                              ? const Icon(
                                Icons.edit,
                              )
                              : const Icon(
                                Icons.add,
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