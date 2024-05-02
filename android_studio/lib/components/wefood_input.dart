import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefood/types.dart';

List<String> positiveFeedback = [
  '¡Correo libre!',
  '¡RUC libre!',
  '¡Teléfono libre!'
];

class WefoodInput extends StatefulWidget {
  final InputType type;
  final Function(String) onChanged;
  final String labelText;
  final String? initialText;
  final String upperTitle;
  final String upperDescription;
  final String? errorText;

  const WefoodInput({
    super.key,
    this.type = InputType.normal,
    required this.onChanged,
    required this.labelText,
    this.initialText,
    this.upperTitle = '',
    this.upperDescription = '',
    this.errorText,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.upperTitle != '') Column(
          children: <Widget>[
            Text(widget.upperTitle),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        if(widget.upperDescription != '') Column(
          children: <Widget>[
            Text(widget.upperDescription),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        TextFormField(
          keyboardType: (widget.type == InputType.integer || widget.type == InputType.decimal) ? TextInputType.number : TextInputType.visiblePassword,
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
            suffixIcon: (widget.type == InputType.secret) ? IconButton(
              onPressed: () => {
                setState(() {
                  _obscureText = !_obscureText;
                })
              },
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ) : null,
          ),
        ),
        if(widget.errorText != null) Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.errorText!,
              style: TextStyle(
                color: (positiveFeedback.contains(widget.errorText))
                  ? null
                  : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        )
      ],
    );
  }
}