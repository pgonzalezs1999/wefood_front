import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/commands/utils.dart';

class CreateProductScreen extends StatefulWidget {

  final ProductType productType;

  const CreateProductScreen({
    super.key,
    required this.productType,
  });

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {

  String _productTypeString = '';

  bool isSubmitting = false;

  double price = 1;
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  int amount = 1;
  bool fresh = false;
  bool bakery = false;
  bool vegetarian = false;
  bool vegan = false;
  bool mondays = false;
  bool tuesdays = false;
  bool wednesdays = false;
  bool thursdays = false;
  bool fridays = false;
  bool saturdays = false;
  bool sundays = false;
  DateTime? endDate;
  bool endless = false;
  List<Image?> images = [ null, null, null, null, null, null, null, null, null, null ];
  String error = '';

  bool _setError(String reason) {
    setState(() {
      error = reason;
    });
    return false;
  }

  bool _readyToRegister() {
    bool result = true;
    if(price <= 0) {
      result = _setError('El precio debe ser un número entero positivo');
    } else if(Utils.timesOfDayFirstIsSooner(startTime, endTime) == false) {
      result = _setError('Horario de recogida incorrecto: ¡la fecha de apertura debe ser antes que la fecha de cierre!');
    } else if(endless == false && endDate == null) {
      result = _setError('El campo fecha límite es obligatorio. Si no tiene fecha de fin, marque "Indefinido"');
    } else {
      setState(() {
        error = '';
      });
    }
    return result;
  }

  @override
  void initState() {
    _productTypeString = Utils.productTypeToString(
        type: widget.productType,
    ) ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Crear $_productTypeString',
      body: [
        Column(
          children: <Widget>[
            ChoosableNumericInput(
              initialValue: price,
              interval: 0.1,
              allowsDecimals: true,
              onChanged: (String value) {
                setState(() {
                  error = '';
                  price = double.tryParse(value) ?? 0.1;
                });
              },
            ),
            Text((price < 0.1) ? 'Número incorrecto' : '', style: const TextStyle(color: Colors.red),), // TODO deshardcodear estilo
          ],
        ),
        const Text('Horario de recogida:'),
        Row(
          children: <Widget>[
            const Text('Desde las'),
            TextButton(
              onPressed: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ) ?? TimeOfDay.now();
                setState(() {
                  startTime = selectedTime;
                });
              },
              child: Text('${startTime.format(context)} h'),
            ),
            const Text('hasta las'),
            TextButton(
              onPressed: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ) ?? TimeOfDay.now();
                setState(() {
                  endTime = selectedTime;
                });
              },
              child: Text('${endTime.format(context)} h'),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            ChoosableNumericInput(
              initialValue: amount.toDouble(),
              interval: 1,
              onChanged: (String value) {
                setState(() {
                  error = '';
                  amount = int.parse(value);
                });
              },
            ),
            Text((amount < 0.1 || int.tryParse('$amount') == null) ? 'Número incorrecto' : '', style: const TextStyle(color: Colors.red),), // TODO deshardcodear estilo
          ],
        ),
        const Text('Categorías'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <_CheckBoxRow>[
                _CheckBoxRow(
                    title: 'Productos frescos',
                    value: fresh,
                    onChanged: () {
                      setState(() {
                        fresh = !fresh;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Bollería',
                    value: bakery,
                    onChanged: () {
                      setState(() {
                        bakery = !bakery;
                      });
                    }
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <_CheckBoxRow>[
                _CheckBoxRow(
                    title: 'Vegetariano',
                    value: vegetarian,
                    onChanged: () {
                      setState(() {
                        vegetarian = !vegetarian;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Vegano',
                    value: vegan,
                    onChanged: () {
                      setState(() {
                        vegan = !vegan;
                      });
                    }
                ),
              ],
            )
          ],
        ),
        const Text('Días en que se ofrecen packs'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <_CheckBoxRow>[
                _CheckBoxRow(
                    title: 'Lunes',
                    value: mondays,
                    onChanged: () {
                      setState(() {
                        mondays = !mondays;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Martes',
                    value: tuesdays,
                    onChanged: () {
                      setState(() {
                        tuesdays = !tuesdays;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Miércoles',
                    value: wednesdays,
                    onChanged: () {
                      setState(() {
                        wednesdays = !wednesdays;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Jueves',
                    value: thursdays,
                    onChanged: () {
                      setState(() {
                        thursdays = !thursdays;
                      });
                    }
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <_CheckBoxRow>[
                _CheckBoxRow(
                    title: 'Viernes',
                    value: fridays,
                    onChanged: () {
                      setState(() {
                        fridays = !fridays;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Sábados',
                    value: saturdays,
                    onChanged: () {
                      setState(() {
                        saturdays = !saturdays;
                      });
                    }
                ),
                _CheckBoxRow(
                    title: 'Domingos',
                    value: sundays,
                    onChanged: () {
                      setState(() {
                        sundays = !sundays;
                      });
                    }
                ),
              ],
            )
          ],
        ),
        const Text('Ofrecer packs hasta'),
        Row(
          children: <Widget>[
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101)
                ) ?? endDate;
                setState(() {
                  error = '';
                  endless = false;
                  endDate = pickedDate;
                });
              },
              child: Text((endDate != null && endless == false) ? (Utils.displayDateTime(endDate!)) : 'Elegir fecha'),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 25,
              ),
              child: _CheckBoxRow(
                title: 'Indefinido',
                value: endless,
                onChanged: () {
                  setState(() {
                    endless = !endless;
                  });
                },
              ),
            ),
          ],
        ),
        const Text('Añadir imágenes'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Column(
                children: <Widget>[
                  _ImageSlot(
                    image: images[0],
                    isMain: true,
                  ),
                  const Text('Imagen principal'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <_ImageSlot>[
                      _ImageSlot(
                        image: images[0],
                      ),
                      _ImageSlot(
                        image: images[1],
                      ),
                      _ImageSlot(
                        image: images[2],
                      ),
                      _ImageSlot(
                        image: images[3],
                      ),
                      _ImageSlot(
                        image: images[4],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.025,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <_ImageSlot>[
                      _ImageSlot(
                        image: images[5],
                      ),
                      _ImageSlot(
                        image: images[6],
                      ),
                      _ImageSlot(
                        image: images[7],
                      ),
                      _ImageSlot(
                        image: images[8],
                      ),
                      _ImageSlot(
                        image: images[9],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            if(isSubmitting == true) const LoadingIcon(),
            if(isSubmitting == false) ElevatedButton(
              onPressed: () async {
                print('He pulsado GUARDAR');
                if(_readyToRegister() == true) {
                  print('Esta ready to register');
                  setState(() {
                    isSubmitting = true;
                  });
                  try {
                    ProductModel product = await Api.createProduct(
                      price: price,
                      amount: amount,
                      endingDate: CustomParsers.dateTimeToSqlDateTimeString(endDate),
                      startHour: CustomParsers.timeOfDayToSqlTimeString(startTime),
                      endHour: CustomParsers.timeOfDayToSqlTimeString(endTime),
                      vegetarian: CustomParsers.boolToSqlString(vegetarian),
                      vegan: CustomParsers.boolToSqlString(vegan),
                      bakery: CustomParsers.boolToSqlString(bakery),
                      fresh: CustomParsers.boolToSqlString(fresh),
                      workingOnMonday: CustomParsers.boolToSqlString(mondays),
                      workingOnTuesday: CustomParsers.boolToSqlString(tuesdays),
                      workingOnWednesday: CustomParsers.boolToSqlString(wednesdays),
                      workingOnThursday: CustomParsers.boolToSqlString(thursdays),
                      workingOnFriday: CustomParsers.boolToSqlString(fridays),
                      workingOnSaturday: CustomParsers.boolToSqlString(saturdays),
                      workingOnSunday: CustomParsers.boolToSqlString(sundays),
                      type: Utils.productTypeToChar(widget.productType),
                    );
                    if(widget.productType == ProductType.breakfast) {
                      context.read<BusinessBreakfastCubit>().set(product);
                    } else if(widget.productType == ProductType.lunch) {
                      context.read<BusinessLunchCubit>().set(product);
                    } else if(widget.productType == ProductType.dinner) {
                      context.read<BusinessDinnerCubit>().set(product);
                    }
                    setState(() {
                      isSubmitting = false;
                    });
                    Navigator.pop(context);
                  } catch(e) {
                    print('ERROR: $e');
                    setState(() {
                      isSubmitting = false;
                      error = 'Ha ocurrido un error'; // TODO hacer algo más currado
                    });
                  }
                }
              },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
        Align(
          child: ElevatedButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (_) => AlertDialog(
                    title: const Text('¿Eliminar producto?'),
                    content: const Text('No podrás deshacer esta acción'),
                    actions: <TextButton>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('CANCELAR'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await Api.deleteProduct(
                              type: (widget.productType == ProductType.breakfast) ? 'B'
                                  : (widget.productType == ProductType.lunch) ? 'L'
                                  : (widget.productType == ProductType.dinner) ? 'D' : '',
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } catch(e) {
                            setState(() {
                              error = 'Ha ocurrido un error eliminar el producto. Por favor, inténtelo de nuevo más tarde';
                            });
                          }
                        },
                        child: const Text('CONFIRMAR'),
                      ),
                    ],
                  )
              );
            },
            child: const Text('ELIMINAR PRODUCTO'),
          ),
        ),
        if(error != '') Align(
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle( // TODO deshardcodear estilo
              color: Colors.red,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckBoxRow extends StatefulWidget {

  final String title;
  final bool value;
  final Function() onChanged;

  const _CheckBoxRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_CheckBoxRow> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<_CheckBoxRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(
            right: 10,
          ),
          child: Checkbox(
            value: widget.value,
            onChanged: (value) => widget.onChanged(),
          ),
        ),
        Text(widget.title),
      ],
    );
  }
}

class _ImageSlot extends StatefulWidget {

  final bool isMain;
  final Image? image;

  const _ImageSlot({
    this.isMain = false,
    this.image,
  });

  @override
  State<_ImageSlot> createState() => _ImageSlotState();
}

class _ImageSlotState extends State<_ImageSlot> {
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * (widget.isMain ? 0.25 : 0.1);

    return (widget.image == null)
        ? Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.66),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: size * 0.75,
      ),
    )
        : SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: (widget.isMain) ? BorderRadius.circular(15) : BorderRadius.circular(10),
        child: widget.image!,
      ),
    );
  }
}