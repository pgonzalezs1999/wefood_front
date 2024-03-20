import 'package:flutter/material.dart';
import 'package:wefood/types.dart';

class WefoodInput extends StatefulWidget {
  final InputType type;
  final Function(String) onChanged;
  final String labelText;
  final String? initialText;
  final String upperTitle;
  final String upperDescription;

  const WefoodInput({
    super.key,
    this.type = InputType.normal,
    required this.onChanged,
    required this.labelText,
    this.initialText,
    this.upperTitle = '',
    this.upperDescription = '',
  });

  @override
  State<WefoodInput> createState() => WefoodInputState();
}

class WefoodInputState extends State<WefoodInput> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.type == InputType.secret;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.upperTitle != '') Text(widget.upperTitle),
        if(widget.upperDescription != '') Text(widget.upperDescription),
        TextFormField(
          keyboardType: TextInputType.visiblePassword,
          obscureText: _obscureText,
          onChanged: (text) => widget.onChanged(text),
          initialValue: widget.initialText,
          decoration: InputDecoration(
            labelText: widget.labelText,
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
      ],
    );
  }
}