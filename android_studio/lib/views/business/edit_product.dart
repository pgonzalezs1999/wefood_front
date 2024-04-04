import 'package:flutter/material.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/choosable_numeric_input.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/models/product_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';

class EditProductScreen extends StatefulWidget {

  final int productId;
  final ProductType productType;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productType,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  String _productTypeString = '';

  double? price;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? amount;
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
  List<Image?> images = [
    Image.asset('assets/images/salmon.jpg', fit: BoxFit.cover,),
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ];

  String displayDateTime(DateTime dateTime) {
    List<String> monthNames = [ 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre' ];
    return '${dateTime.day} de ${monthNames[dateTime.month]} del ${dateTime.year}';
  }

  @override
  void initState() {
    if(widget.productType == ProductType.breakfast) {
      _productTypeString = 'desayunos';
    } else if(widget.productType == ProductType.lunch) {
      _productTypeString = 'almuerzos';
    } else {
      _productTypeString = 'cenas';
    }
    super.initState();
  }

  Widget resultWidget = const LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Editar $_productTypeString'),
            ],
          ),
          FutureBuilder<ProductExpandedModel>(
              future: Api.getProduct(
                id: widget.productId,
              ),
              builder: (BuildContext context, AsyncSnapshot<ProductExpandedModel> response) {
                if(response.hasError) {
                  resultWidget = Container(
                    margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: const Text('Error'),
                  );
                } else if(response.hasData) {
                  ProductModel product = response.data!.product!;
                  price = product.price;
                  startTime = TimeOfDay(
                      hour: product.startingHour!.hour,
                      minute: product.startingHour!.minute,
                  );
                  endTime = TimeOfDay(
                    hour: product.endingHour!.hour,
                    minute: product.endingHour!.minute,
                  );
                  amount = product.amount!;
                  fresh = product.fresh!;
                  bakery = product.bakery!;
                  vegetarian = product.vegetarian!;
                  vegan = product.vegan!;
                  mondays = product.workingOnMonday!;
                  tuesdays = product.workingOnTuesday!;
                  wednesdays = product.workingOnWednesday!;
                  thursdays = product.workingOnThursday!;
                  fridays = product.workingOnFriday!;
                  saturdays = product.workingOnSaturday!;
                  sundays = product.workingOnSunday!;
                  endDate = product.endingDate;
                  endless = (endDate == null);

                  resultWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ChoosableNumericInput(
                        title: 'Precio',
                        initialValue: price ?? 1,
                        interval: 0.1,
                        allowsDecimals: true,
                        onChanged: (String value) {
                          setState(() {
                            price = double.parse(value);
                          });
                        },
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
                      ChoosableNumericInput(
                        title: 'Número de packs por día',
                        initialValue: (amount ?? 1).toDouble(),
                        interval: 1,
                        onChanged: (String value) {
                          setState(() {
                            price = double.parse(value);
                          });
                        },
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
                              );
                              setState(() {
                                endDate = pickedDate;
                              });
                            },
                            child: Text((endDate != null) ? displayDateTime(endDate!) : 'Elegir fecha'),
                          ),
                          _CheckBoxRow(
                            title: 'Indefinido',
                            value: endless,
                            onChanged: () {
                              setState(() {
                                endless = !endless; // TODO Si se marca indefinido, bloquear la fecha
                              });
                            },
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
                      Text('Se guardará: [\n'
                        '     Precio = ${price ?? 'N/A'};\n'
                        '     Desde las ${startTime?.format(context) ?? 'N/A'}h hasta las ${endTime?.format(context) ?? 'N/A'}h\n'
                        '     Packs/día: $amount\n'
                        '     Fresco: $fresh\n'
                        '     Bollería: $bakery\n'
                        '     Vegetariano: $vegetarian\n'
                        '     Vegano: $vegan\n'
                        '     Lunes: $mondays\n'
                        '     Martes: $tuesdays\n'
                        '     Miércoles: $wednesdays\n'
                        '     Jueves: $thursdays\n'
                        '     Viernes: $fridays\n'
                        '     Sábados: $saturdays\n'
                        '     Domingos: $sundays\n'
                        '     Hasta el día ${(endDate != null) ? displayDateTime(endDate!) : 'N/A'} (indefinido: $endless)\n'
                        ']'
                      ),
                    ],
                  );
                }
                return resultWidget;
              }
          ),
        ],
      ),
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