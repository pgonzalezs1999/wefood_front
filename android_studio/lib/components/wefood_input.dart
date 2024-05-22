import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wefood/types.dart';

class WefoodInput extends StatefulWidget {
  final InputType type;
  final Function(String) onChanged;
  final String labelText;
  final String? initialText;
  final String upperTitle;
  final String upperDescription;
  final Widget? feedbackWidget;

  const WefoodInput({
    super.key,
    this.type = InputType.normal,
    required this.onChanged,
    required this.labelText,
    this.initialText,
    this.upperTitle = '',
    this.upperDescription = '',
    this.feedbackWidget,
  });

  @override
  State<WefoodInput> createState() => WefoodInputState();
}

class WefoodInputState extends State<WefoodInput> {

  late bool _obscureText;
  late TextInputFormatter? _inputFormatter;

  @override
  void initState() {
    _obscureText = widget.type == InputType.secret;
    _inputFormatter = (widget.type == InputType.integer)
      ? FilteringTextInputFormatter.digitsOnly
      : (widget.type == InputType.decimal)
        ? FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        : null;
    super.initState();
  }

  Widget _suffixIcon() {
    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: IconButton(
        onPressed: () => {
          setState(() {
            _obscureText = !_obscureText;
          })
        },
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.upperTitle != '') Column(
          children: <Widget>[
            Text(
              widget.upperTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if(widget.upperDescription != '') Column(
          children: <Widget>[
            Text(widget.upperDescription),
          ],
        ),
        if(widget.upperTitle != '' || widget.upperDescription != '') const SizedBox(
          height: 10,
        ),
        TextFormField(
          keyboardType: (widget.type == InputType.integer || widget.type == InputType.decimal) ? TextInputType.number : TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          inputFormatters: (_inputFormatter != null) ? [ _inputFormatter! ] : null,
          obscureText: _obscureText,
          onChanged: (text) => widget.onChanged(text),
          initialValue: widget.initialText,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor,
              ),
            ),
            labelText: widget.labelText,
            focusColor: Colors.green,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
              gapPadding: 4,
              borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            suffixIcon: (widget.type == InputType.secret) ? _suffixIcon() : null,
          ),
        ),
        if(widget.feedbackWidget != null) widget.feedbackWidget!,
      ],
    );
  }
}