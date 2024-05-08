import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/commands/utils.dart';

class EditProduct extends StatefulWidget {

  final int productId;
  final ProductType productType;

  const EditProduct({
    super.key,
    required this.productId,
    required this.productType,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {

  String _productTypeString = '';

  bool isRetrievingData = true;
  bool isSubmitting = false;

  double? price;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? amount;
  bool dessert = false;
  bool junk = false;
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
  List<Image?> images = [ // TODO ponerlos a null
    Image.asset('assets/images/logo.png', fit: BoxFit.cover,), null, null, null, null, null, null, null, null, null,
  ];
  String error = '';

  bool _setError(String reason) {
    setState(() {
      error = reason;
    });
    return false;
  }

  bool _readyToRegister() {
    bool result = true;
    if(price == null) {
      result = _setError('El campo precio es obligatorio');
    } else if(price! <= 0) {
      result = _setError('El precio debe ser un número entero positivo');
    } else if(Utils.timesOfDayFirstIsSooner(startTime!, endTime!) == false) {
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

  void retrieveData() async {
    ProductExpandedModel response = await Api.getProduct(
      id: widget.productId,
    );
    price = response.product.price;
    startTime = TimeOfDay(
      hour: response.product.startingHour!.hour,
      minute: response.product.startingHour!.minute,
    );
    endTime = TimeOfDay(
      hour: response.product.endingHour!.hour,
      minute: response.product.endingHour!.minute,
    );
    setState(() {
      amount = response.product.amount!;
      dessert = response.product.dessert!;
      junk = response.product.junk!;
      vegetarian = response.product.vegetarian!;
      vegan = response.product.vegan!;
      mondays = response.product.workingOnMonday!;
      tuesdays = response.product.workingOnTuesday!;
      wednesdays = response.product.workingOnWednesday!;
      thursdays = response.product.workingOnThursday!;
      fridays = response.product.workingOnFriday!;
      saturdays = response.product.workingOnSaturday!;
      sundays = response.product.workingOnSunday!;
      endDate = response.product.endingDate;
      endless = (endDate == null);
      isRetrievingData = false;
    });
  }

  @override
  void initState() {
    _productTypeString = Utils.productTypeToString(
      type: widget.productType,
    ) ?? '';
    retrieveData();
    super.initState();
  }

  Widget resultWidget = const LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Editar $_productTypeString',
      body: [
        Wrap(
          runSpacing: 25,
          children: <Widget>[
            if(price == null) const LoadingIcon(),
            if(price != null) Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Precio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ChoosableNumericInput(
                  initialValue: price!,
                  interval: 0.1,
                  allowsDecimals: true,
                  onChanged: (String value) {
                    setState(() {
                      error = '';
                      price = double.tryParse(value);
                    });
                  },
                ),
                Text((price == null || price == 0) ? 'Número incorrecto' : '', style: const TextStyle(color: Colors.red),), // TODO deshardcodear estilo
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Horario de recogida:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: <Widget>[
                    const Text('Desde las'),
                    TextButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {
                          startTime = selectedTime;
                        });
                      },
                      child: Text('${startTime?.format(context)} h'),
                    ),
                    const Text('hasta las'),
                    TextButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {
                          endTime = selectedTime;
                        });
                      },
                      child: Text('${endTime?.format(context)} h'),
                    ),
                  ],
                ),
              ],
            ),
            if(amount == null) const LoadingIcon(),
            if(amount != null) Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Número de packs por día:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ChoosableNumericInput(
                  initialValue: amount!.toDouble(),
                  interval: 1,
                  onChanged: (String value) {
                    setState(() {
                      error = '';
                      amount = int.parse(value);
                    });
                  },
                ),
                Text((amount == null || amount == 0 || int.tryParse('$amount') == null) ? 'Número incorrecto' : '', style: const TextStyle(color: Colors.red),), // TODO deshardcodear estilo
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <CheckBoxRow>[
                        CheckBoxRow(
                          title: 'Comida rápida',
                          value: junk,
                          onChanged: () {
                            setState(() {
                              junk = !junk;
                            });
                          }
                        ),
                        CheckBoxRow(
                          title: 'Postres',
                          value: dessert,
                          onChanged: () {
                            setState(() {
                              dessert = !dessert;
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
                      children: <CheckBoxRow>[
                        CheckBoxRow(
                          title: 'Vegetariano',
                          value: vegetarian,
                          onChanged: () {
                            setState(() {
                              vegetarian = !vegetarian;
                            });
                          }
                        ),
                        CheckBoxRow(
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Días en que se ofrecen packs',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <CheckBoxRow>[
                        CheckBoxRow(
                          title: 'Lunes',
                          value: mondays,
                          onChanged: () {
                            setState(() {
                              mondays = !mondays;
                            });
                          }
                        ),
                        CheckBoxRow(
                          title: 'Martes',
                          value: tuesdays,
                          onChanged: () {
                            setState(() {
                              tuesdays = !tuesdays;
                            });
                          }
                        ),
                        CheckBoxRow(
                          title: 'Miércoles',
                          value: wednesdays,
                          onChanged: () {
                            setState(() {
                              wednesdays = !wednesdays;
                            });
                          }
                        ),
                        CheckBoxRow(
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
                      children: <CheckBoxRow>[
                        CheckBoxRow(
                          title: 'Viernes',
                          value: fridays,
                          onChanged: () {
                            setState(() {
                              fridays = !fridays;
                            });
                          }
                        ),
                        CheckBoxRow(
                          title: 'Sábados',
                          value: saturdays,
                          onChanged: () {
                            setState(() {
                              saturdays = !saturdays;
                            });
                          }
                        ),
                        CheckBoxRow(
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ofrecer packs hasta',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
                      child: CheckBoxRow(
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
              ],
            ),
            Text(
              'Añadir imágenes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Column(
                    children: <Widget>[
                      ImageSlot(
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
                        children: <ImageSlot>[
                          ImageSlot(
                            image: images[0],
                          ),
                          ImageSlot(
                            image: images[1],
                          ),
                          ImageSlot(
                            image: images[2],
                          ),
                          ImageSlot(
                            image: images[3],
                          ),
                          ImageSlot(
                            image: images[4],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.025,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <ImageSlot>[
                          ImageSlot(
                            image: images[5],
                          ),
                          ImageSlot(
                            image: images[6],
                          ),
                          ImageSlot(
                            image: images[7],
                          ),
                          ImageSlot(
                            image: images[8],
                          ),
                          ImageSlot(
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
                if(isSubmitting == false && isRetrievingData == false) ElevatedButton(
                  onPressed: () {
                    if(_readyToRegister() == true) {
                      setState(() {
                        isSubmitting = true;
                      });
                      try {
                        Api.updateProduct(
                          id: widget.productId,
                          price: price!,
                          amount: amount!,
                          endingDate: CustomParsers.dateTimeToSqlDateTimeString(endDate),
                          startHour: CustomParsers.timeOfDayToSqlTimeString(startTime!),
                          endHour: CustomParsers.timeOfDayToSqlTimeString(endTime!),
                          vegetarian: CustomParsers.boolToSqlString(vegetarian),
                          vegan: CustomParsers.boolToSqlString(vegan),
                          junk: CustomParsers.boolToSqlString(junk),
                          dessert: CustomParsers.boolToSqlString(dessert),
                          workingOnMonday: CustomParsers.boolToSqlString(mondays),
                          workingOnTuesday: CustomParsers.boolToSqlString(tuesdays),
                          workingOnWednesday: CustomParsers.boolToSqlString(wednesdays),
                          workingOnThursday: CustomParsers.boolToSqlString(thursdays),
                          workingOnFriday: CustomParsers.boolToSqlString(fridays),
                          workingOnSaturday: CustomParsers.boolToSqlString(saturdays),
                          workingOnSunday: CustomParsers.boolToSqlString(sundays),
                        ).then((ProductModel product) {
                          setState(() {
                            isSubmitting = false;
                          });
                          Navigator.pop(context);
                        });
                      } catch(e) {
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
                    builder: ((BuildContext context) {
                      return WefoodPopup(
                        context: context,
                        title: '¿Eliminar producto?',
                        description: 'No podrás deshacer esta acción',
                        cancelButtonTitle: 'CANCELAR',
                        actions: <TextButton>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              try {
                                Api.deleteProduct(
                                  type: (widget.productType == ProductType.breakfast) ? 'B'
                                      : (widget.productType == ProductType.lunch) ? 'L'
                                      : (widget.productType == ProductType.dinner) ? 'D' : '',
                                ).then((_) {
                                  if(widget.productType == ProductType.breakfast) {
                                    context.read<BusinessBreakfastCubit>().set(null);
                                  } else if(widget.productType == ProductType.lunch) {
                                    context.read<BusinessLunchCubit>().set(null);
                                  } else {
                                    context.read<BusinessDinnerCubit>().set(null);
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              } catch(e) {
                                setState(() {
                                  error = 'Ha ocurrido un error eliminar el producto. Por favor, inténtelo de nuevo más tarde';
                                });
                              }
                            },
                          ),
                        ],
                      );
                    }),
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
        ),
      ],
    );
  }
}