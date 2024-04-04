import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChoosableNumericInput extends StatefulWidget {

  final String? title;
  final Function(String) onChanged;
  final double initialValue;
  final double? interval;
  final bool allowsDecimals;

  const ChoosableNumericInput({
    this.title,
    required this.onChanged,
    required this.initialValue,
    this.interval,
    this.allowsDecimals = false,
    super.key,
  });

  @override
  State<ChoosableNumericInput> createState() => _ChoosableNumericInputState();
}

class _ChoosableNumericInputState extends State<ChoosableNumericInput> {

  TextEditingController? _controller;
  int numberOfDecimals = 0;

  @override
  void initState() {
    numberOfDecimals = widget.allowsDecimals ? 2 : 0;
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(numberOfDecimals),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.title != null) Column(
          children: <Widget>[
            Text(widget.title!),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        Container(
          width: 150,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 0.25,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.allowsDecimals,
                    signed: false,
                  ),
                    inputFormatters: (widget.allowsDecimals)
                      ? <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'), // Allows dígits, decimal point y max. 2 decimal digits
                        ),
                      ]
                      : <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                  onChanged: (String value) {
                    widget.onChanged(_controller!.text);
                  }
                ),
              ),
              SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          child: const Icon(
                            Icons.arrow_drop_up,
                          ),
                          onTap: () {
                            double currentValue = double.parse(_controller!.text);
                            if(widget.interval != null) {
                              currentValue += widget.interval!;
                            } else {
                              currentValue++;
                            }
                            _controller!.text = (currentValue).toStringAsFixed(numberOfDecimals);
                            widget.onChanged(_controller!.text);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          child: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          onTap: () {
                            double currentValue = double.parse(_controller!.text);
                            if(widget.interval != null) {
                              if(currentValue - widget.interval! > widget.interval!) {
                                currentValue -= widget.interval!;
                              } else {
                                currentValue = widget.interval!;
                              }
                            } else {
                                if(currentValue - 1 > 1) {
                                  currentValue--;
                                } else {
                                  currentValue = 1;
                                }
                            }
                            _controller!.text = (currentValue).toStringAsFixed(numberOfDecimals);
                            widget.onChanged(_controller!.text);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}