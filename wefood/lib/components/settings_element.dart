import 'package:flutter/material.dart';

class SettingsElement extends StatefulWidget {

  final IconData iconData;
  final String title;
  final Function() onTap;
  final bool? isFirst;

  const SettingsElement({
    super.key,
    required this.iconData,
    required this.title,
    required this.onTap,
    this.isFirst = false,
  });

  @override
  State<SettingsElement> createState() => _SettingsElementState();
}

class _SettingsElementState extends State<SettingsElement> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: (widget.title.contains('FALTA')) ? Colors.red.withOpacity(0.15) : Colors.transparent,
          border: Border(
            top: (widget.isFirst != true)
              ? const BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.25),
              )
              : BorderSide.none,
          ),
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                widget.iconData,
                color: (widget.title.contains('próximamente'))
                  ? Colors.black.withOpacity(0.4)
                  : Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: TextStyle(
                  color: (widget.title.contains('próximamente'))
                    ? Colors.black.withOpacity(0.4)
                    : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}