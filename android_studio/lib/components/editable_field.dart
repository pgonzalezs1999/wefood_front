import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/wefood_input.dart';

class EditableField extends StatefulWidget {
  final String feedbackText;
  final String firstTopic;
  final String firstInitialValue;
  final int? firstMinimumLength;
  final int? firstMaximumLength;
  final String? secondTopic;
  final String? secondInitialValue;
  final int? secondMinimumLength;
  final int? secondMaximumLength;
  final Function(String, String?) onSave;

  const EditableField({
    super.key,
    required this.feedbackText,
    required this.firstTopic,
    required this.firstInitialValue,
    this.firstMinimumLength,
    this.firstMaximumLength,
    this.secondTopic,
    this.secondInitialValue,
    this.secondMinimumLength,
    this.secondMaximumLength,
    required this.onSave,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  String newFirst = '';
  String? newSecond;
  String errorFeedback = '';
  bool confirmed = false;

  @override
  void initState() {
    newFirst = widget.firstInitialValue;
    newSecond = widget.secondInitialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void setCanConfirm() {
      String result = '';
      if(newFirst == widget.firstInitialValue && newSecond == widget.secondInitialValue) {
        result = 'No se han hecho cambios';
      } else if(widget.secondInitialValue == null) {
          if(newFirst == '') {
            result = 'Campo obligatorio';
          }
        } else {
        if(newFirst == '' || newSecond == '' || newSecond == null) {
          result = 'Ambos campos obligatorios';
        }
      }
      if(widget.firstMinimumLength != null && widget.firstMinimumLength! > newFirst.length) {
        result = 'El campo ${widget.firstTopic} debe tener más de ${widget.firstMinimumLength} caracteres';
      } else if(widget.firstMaximumLength != null && widget.firstMaximumLength! < newFirst.length) {
        result = 'El campo ${widget.firstTopic} debe tener menos de ${widget.firstMaximumLength} caracteres';
      } else if(widget.secondMinimumLength != null && widget.secondMinimumLength! > newSecond!.length) {
        result = 'El campo ${widget.secondTopic} debe tener más de ${widget.secondMinimumLength} caracteres';
      } else if(widget.secondMaximumLength != null && widget.secondMaximumLength! < newSecond!.length) {
        result = 'El campo ${widget.secondTopic} debe tener menos de ${widget.secondMaximumLength} caracteres';
      }
      setState(() {
        errorFeedback = result;
      });
    }

    return Row(
      children: [
        Expanded(
          child: Text(widget.feedbackText),
        ),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          child: const Icon(Icons.edit),
          onTap: () {
            setState(() {
              confirmed = false;
            });
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, StateSetter setState) {
                  return AlertDialog(
                    content: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery
                            .of(context)
                            .size
                            .height * 0.01,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WefoodInput(
                            onChanged: (value) {
                              setState(() {
                                newFirst = value;
                                setCanConfirm();
                              });
                            },
                            labelText: '${(widget.firstInitialValue == '') ? 'Añadir' : 'Cambiar'} ${widget.firstTopic}',
                            initialText: widget.firstInitialValue,
                          ),
                          if(widget.secondInitialValue != null) Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              WefoodInput(
                                onChanged: (value) {
                                  setState(() {
                                    newSecond = value;
                                    setCanConfirm();
                                  });
                                },
                                labelText: '${(widget.secondInitialValue == '') ? 'Añadir' : 'Cambiar'} ${widget.secondTopic}',
                                initialText: widget.secondInitialValue,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              top: 20,
                            ),
                            child: Text(
                              errorFeedback,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('CANCELAR'),
                      ),
                      if(errorFeedback == '' && confirmed == false) TextButton(
                        onPressed: () async {
                          setState(() {
                            confirmed = true;
                          });
                          final response = await widget.onSave(newFirst, newSecond);
                          print('RESPONSE EN EDITABLE_FIELD: $response');
                          if(response['error'] == null) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              errorFeedback = response['error'];
                              confirmed = false;
                            });
                          }
                        },
                        child: const Text('CONFIRMAR'),
                      ),
                      if(confirmed == true) const LoadingIcon(),
                    ],
                  );
                });
              }
            );
          }
        ),
      ],
    );
  }
}