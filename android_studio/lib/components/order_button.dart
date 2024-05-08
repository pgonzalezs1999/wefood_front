import 'package:flutter/material.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/views/views.dart';

class OrderButton extends StatefulWidget {

  final ProductExpandedModel productExpanded;
  final Function()? comebackBehaviour;

  const OrderButton({
    super.key,
    required this.productExpanded,
    this.comebackBehaviour,
  });

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderCustomer(
              id: widget.productExpanded.order.id!,
            )),
          ).whenComplete(() {
            (widget.comebackBehaviour != null) ? widget.comebackBehaviour!() : null;
          });
        },
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRect(
                child: Container(
                  color: Colors.white.withOpacity(0.75),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  width: double.infinity,
                  child: Wrap(
                    runSpacing: -3,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Text>[
                          Text('${Utils.productTypeCharToString(
                            type: widget.productExpanded.product.type,
                            isCapitalized: true,
                          )} de'),
                          if(widget.productExpanded.item.date != null) Text((widget.productExpanded.item.date!.day == DateTime.now().day) ? '(hoy)' : '(mañana)'),
                        ],
                      ),
                      Text(
                        widget.productExpanded.business.name ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Row(
                        children: [
                          if(widget.productExpanded.business.rate != null) if(widget.productExpanded.business.rate! > 0) Row(
                            children: <Widget>[
                              const Icon(
                                Icons.star,
                                size: 15,
                              ),
                              Text(' ${widget.productExpanded.business.rate ?? 0} | '),
                            ],
                          ),
                          (Utils.minutesFromNowToDateTime(widget.productExpanded.product.endingHour!) < 60)
                            ? AnimatedBuilder(
                              animation: CurvedAnimation(
                                parent: _controller,
                                curve: Curves.easeInOut
                              ),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1 + _controller.value * 0.3,
                                  child: Icon(
                                    Icons.watch_later,
                                    size: 15,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                );
                              }
                            )
                            : const Icon(
                              Icons.watch_later,
                              size: 15,
                            ),
                          Text(' Horario: ${(widget.productExpanded.product.startingHour!.hour < 10) ? '0' : ''}${widget.productExpanded.product.startingHour?.hour}:${widget.productExpanded.product.startingHour?.minute}${(widget.productExpanded.product.startingHour!.minute < 10) ? '0' : ''}h - ${(widget.productExpanded.product.endingHour!.hour < 10) ? '0' : ''}${widget.productExpanded.product.endingHour?.hour}:${widget.productExpanded.product.endingHour?.minute}${(widget.productExpanded.product.endingHour!.minute < 10) ? '0' : ''}h'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}