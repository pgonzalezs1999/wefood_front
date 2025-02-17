import 'package:flutter/material.dart';
import 'package:wefood/models.dart';
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
    bool isLate = (Utils.minutesFromNowToDateTime(widget.productExpanded.product.endingHour!) < 0 && (widget.productExpanded.item.date!.day == DateTime.now().day));
    return Opacity(
      opacity: isLate ? 0.666 : 1,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(
          top: 20,
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderCustomer(
                itemId: widget.productExpanded.item.id!,
                orderId: widget.productExpanded.order.id!,
              )),
            ).whenComplete(() {
              (widget.comebackBehaviour != null) ? widget.comebackBehaviour!() : null;
            });
          },
          child: Card(
            color: isLate ? Theme.of(context).colorScheme.secondary.withOpacity(0.333) : Theme.of(context).colorScheme.primaryContainer,
            elevation: isLate ? 1 : 3,
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
                            if(widget.productExpanded.item.date != null) Text((widget.productExpanded.item.date!.day == DateTime.now().day)
                              ? '(hoy)'
                              : (widget.productExpanded.item.date!.day == DateTime.now().add(const Duration(days: 1)).day)
                                ? '(mañana)'
                                : '(${Utils.dateTimeToString(
                              date: widget.productExpanded.item.date,
                              showTime: false,
                            )})',
                            ),
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
                            isLate
                              ? Icon(
                                Icons.dangerous,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 15,
                              )
                              : (Utils.minutesFromNowToDateTime(widget.productExpanded.product.endingHour!) < 60 && (widget.productExpanded.item.date!.day == DateTime.now().day))
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
                        if(isLate == true) Text(
                          '(Horario de recogida excedido)',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}