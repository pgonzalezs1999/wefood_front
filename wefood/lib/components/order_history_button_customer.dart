import 'package:flutter/material.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/models.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/views/views.dart';

class OrderHistoryButtonCustomer extends StatefulWidget {

  final ProductExpandedModel productExpanded;
  final Function()? comebackBehaviour;

  const OrderHistoryButtonCustomer({
    super.key,
    required this.productExpanded,
    this.comebackBehaviour,
  });

  @override
  State<OrderHistoryButtonCustomer> createState() => _OrderHistoryButtonCustomerState();
}

class _OrderHistoryButtonCustomerState extends State<OrderHistoryButtonCustomer> {

  void _navigateToBusinessScreen({
    required businessExpanded
  }) {
    callRequestWithLoading(
      context: context,
      request: () async {
        return await Api.getBusiness(
          idBusiness: widget.productExpanded.business.id!,
        );
      },
      onSuccess: (BusinessExpandedModel businessExpanded) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BusinessScreen(
            businessExpanded: businessExpanded,
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (widget.productExpanded.business.deletedAt != null) ? 0.75 : 1,
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
        ),
        child: Card(
          elevation: (widget.productExpanded.business.deletedAt != null) ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Wrap(
                  children: [
                    Row(
                      children: <Text>[
                        Text('${Utils.productTypeCharToString(
                          type: widget.productExpanded.product.type,
                          isCapitalized: true,
                          isPlural: false,
                        )} del '),
                        if(widget.productExpanded.order.orderDate != null) Text('${Utils.displayDateTimeShort(widget.productExpanded.order.orderDate!)} de'),
                      ],
                    ),
                    Text(
                      widget.productExpanded.business.name ?? '',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.price_change,
                          size: 15,
                        ),
                        Text('  ${widget.productExpanded.order.amount} packs por ${(widget.productExpanded.order.amount! * widget.productExpanded.product.price!).toStringAsFixed(2)} Sol/.'),
                      ],
                    ),
                    const Divider(
                      height: 30,
                    ),
                    if(widget.productExpanded.business.deletedAt != null) const Align(
                      child: Text('Este negocio ya no opera en WeFood'),
                    ),
                    if(widget.productExpanded.business.deletedAt == null) Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <TextButton>[
                        TextButton(
                          child: const Text('VER NEGOCIO'),
                          onPressed: () {
                            _navigateToBusinessScreen(
                              businessExpanded: BusinessExpandedModel.fromParameters(
                                businessModel: widget.productExpanded.business,
                                userModel: widget.productExpanded.user,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}