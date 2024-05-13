import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/open_loading_popup.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/commands/scroll_to_bottom.dart';

class EditProduct extends StatefulWidget {

  final int? productId;
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

  final ScrollController scrollController = ScrollController();

  String _productTypeString = '';
  bool isRetrievingData = true;
  bool isSubmitting = false;
  double? price;
  TimeOfDay startTime = const TimeOfDay(
    hour: 0,
    minute: 1
  );
  TimeOfDay endTime = const TimeOfDay(
    hour: 23,
    minute: 59,
  );
  int? amount;
  bool dessert = false;
  bool junk = false;
  bool vegetarian = false;
  bool vegan = false;
  bool mondays = true;
  bool tuesdays = true;
  bool wednesdays = true;
  bool thursdays = true;
  bool fridays = true;
  bool saturdays = true;
  bool sundays = true;
  DateTime? endDate;
  bool endless = false;
  List<Image?> images = List.generate(10, (_) => null);
  String error = '';

  List<bool> initialWeekDays = List.generate(7, (_) => false);

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
    } else if(price! < Environment.minimumPrice) {
      result = _setError('El precio debe ser de al menos ${Environment.minimumPrice} S/.');
    } else if(Utils.timesOfDayFirstIsSooner(startTime, endTime) == false) {
      result = _setError('Horario de recogida incorrecto: ¡la fecha de apertura debe ser antes que la fecha de cierre!');
    } else if(amount == null) {
      result = _setError('El campo cantidad es obligatorio');
    } else if(amount! < 1) {
      result = _setError('Cantidad mínima: 1 pack');
    } else if(Utils.sumTrueBooleans([junk, dessert, vegetarian, vegan]) > 2) {
      result = _setError('Se tiene que seleccionar como máximo 2 categorías');
    } else if(Utils.sumTrueBooleans([mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays]) == 0) {
      result = _setError('Se tiene que seleccionar al menos 1 día de la semana');
    } else if(endless == false && endDate == null) {
      result = _setError('El campo fecha límite es obligatorio. Si no tiene fecha de fin, marque "Indefinido"');
    } else {
      setState(() {
        error = '';
      });
    }
    return result;
  }

  _pickImageFrom({
    required ImageSource source,
    required int position,
  }) {
    ImagePicker().pickImage(source: source).then((XFile? returnedImage) {
      File imageFile;
      if(returnedImage != null) {
        imageFile = File(returnedImage.path);
        Navigator.pop(context);
        openLoadingPopup(context);
        Api.uploadImage(
          idUser: context.read<UserInfoCubit>().state.user.id!,
          meaning: '${Utils.productTypeToChar(widget.productType).toLowerCase()}$position',
          file: imageFile,
        ).then((ImageModel imageModel) {
          setState(() {
            images[position-1] = Image.file(
              imageFile,
              fit: BoxFit.cover,
            );
          });
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WefoodPopup(
                context: context,
                title: '¡Foto actualizada correctamente!',
                cancelButtonTitle: 'OK',
                cancelButtonBehaviour: () {
                  Navigator.pop(context);
                },
              );
            }
          );
        });
      }
    });
  }

  void _safeEditProduct() async {
    Api.updateProduct(
      id: widget.productId!,
      price: price!,
      amount: amount!,
      endingDate: Utils.dateTimeToSqlDateTimeString(endDate),
      startHour: Utils.timeOfDayToSqlTimeString(startTime),
      endHour: Utils.timeOfDayToSqlTimeString(endTime),
      vegetarian: Utils.boolToSqlString(vegetarian),
      vegan: Utils.boolToSqlString(vegan),
      junk: Utils.boolToSqlString(junk),
      dessert: Utils.boolToSqlString(dessert),
      workingOnMonday: Utils.boolToSqlString(mondays),
      workingOnTuesday: Utils.boolToSqlString(tuesdays),
      workingOnWednesday: Utils.boolToSqlString(wednesdays),
      workingOnThursday: Utils.boolToSqlString(thursdays),
      workingOnFriday: Utils.boolToSqlString(fridays),
      workingOnSaturday: Utils.boolToSqlString(saturdays),
      workingOnSunday: Utils.boolToSqlString(sundays),
    ).then((ProductModel product) {
      setState(() {
        isSubmitting = false;
      });
      Navigator.pop(context);
      String title = '¡Producto modificado correctamente!';
      String? description;
      int dayOfWeekToday = DateTime.now().weekday - 1;
      int dayOfWeekTomorrow = DateTime.now().weekday;
      if(dayOfWeekTomorrow == 7) {
        dayOfWeekTomorrow = 0;
      }
      List<bool> workingOns = [mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays];
      if((initialWeekDays[dayOfWeekToday] == true && workingOns[dayOfWeekToday] == false) || (initialWeekDays[dayOfWeekTomorrow] == true && workingOns[dayOfWeekTomorrow] == false)) {
        setState(() {
          description = 'Se han deslistado productos activos. Si alguien ya ha reservado un pack, tendrá que ofrecérselo igualmente. Revise sus reservas clicando en "RECOGIDAS"';
        });
      }
      if((initialWeekDays[dayOfWeekToday] == false && workingOns[dayOfWeekToday] == true) && (initialWeekDays[dayOfWeekTomorrow] == false && workingOns[dayOfWeekTomorrow] == true)) {
        setState(() {
          description = 'También se ha activado el producto para hoy y para mañana';
        });
      } else {
        if(initialWeekDays[dayOfWeekToday] == false && workingOns[dayOfWeekToday] == true) {
          setState(() {
            description = 'También se ha activado el producto para hoy';
          });
        }
        if(initialWeekDays[dayOfWeekTomorrow] == false && workingOns[dayOfWeekTomorrow] == true) {
          setState(() {
            description = 'También se ha activado el producto para mañana';
          });
        }
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: ((BuildContext context) {
          return WefoodPopup(
            context: context,
            title: title,
            description: description,
            cancelButtonTitle: 'OK',
          );
        }),
      );
    });
  }

  void _safeCreateProduct() async {
    Api.createProduct(
      price: price!,
      amount: amount!,
      endingDate: Utils.dateTimeToSqlDateTimeString(endDate),
      startHour: Utils.timeOfDayToSqlTimeString(startTime),
      endHour: Utils.timeOfDayToSqlTimeString(endTime),
      vegetarian: Utils.boolToSqlString(vegetarian),
      vegan: Utils.boolToSqlString(vegan),
      junk: Utils.boolToSqlString(junk),
      dessert: Utils.boolToSqlString(dessert),
      workingOnMonday: Utils.boolToSqlString(mondays),
      workingOnTuesday: Utils.boolToSqlString(tuesdays),
      workingOnWednesday: Utils.boolToSqlString(wednesdays),
      workingOnThursday: Utils.boolToSqlString(thursdays),
      workingOnFriday: Utils.boolToSqlString(fridays),
      workingOnSaturday: Utils.boolToSqlString(saturdays),
      workingOnSunday: Utils.boolToSqlString(sundays),
      type: Utils.productTypeToChar(widget.productType),
    ).then((ProductModel product) {
      setState(() {
        isSubmitting = false;
      });
      if(widget.productType == ProductType.breakfast) {
        setState(() {
          context.read<BusinessBreakfastCubit>().set(product);
        });
      } else if(widget.productType == ProductType.breakfast) {
        setState(() {
          context.read<BusinessBreakfastCubit>().set(product);
        });
      } else {
        setState(() {
          context.read<BusinessBreakfastCubit>().set(product);
        });
      }
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: ((BuildContext context) {
          return WefoodPopup(
            context: context,
            title: '¡Producto creado correctamente!',
            cancelButtonTitle: 'OK',
          );
        }),
      );
    });
  }

  _manageImageSlot(int current) async {
    int lastFilled = 0;
    for(int i = 0; i < images.length; i++) {
      if(images[i] != null) {
        lastFilled = i+1;
      }
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WefoodPopup(
          context: context,
          image: images[current],
          content: Column(
            children: <TextButton>[
              TextButton(
                child: Text('${(current < lastFilled) ? 'CAMBIAR' : 'AÑADIR'} IMAGEN DESDE LA CÁMARA'),
                onPressed: () async {
                  _pickImageFrom(
                    source: ImageSource.camera,
                    position: (current <= lastFilled) ? current+1 : lastFilled+1,
                  );
                },
              ),
              TextButton(
                child: Text('${(current < lastFilled) ? 'CAMBIAR' : 'AÑADIR'} IMAGEN DE LA GALERÍA'),
                onPressed: () async {
                  _pickImageFrom(
                    source: ImageSource.gallery,
                    position: (current <= lastFilled) ? current+1 : lastFilled+1,
                  );
                },
              ),
              if(current < lastFilled) TextButton(
                child: const Text('ELIMINAR IMAGEN'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return WefoodPopup(
                        image: images[current],
                        context: context,
                        title: '¿Eliminar imagen?',
                        actions: <TextButton>[
                          TextButton(
                            child: const Text('SÍ'),
                            onPressed: () {
                              Api.removeImage(
                                idUser: context.read<UserInfoCubit>().state.user.id!,
                                meaning: '${Utils.productTypeToChar(widget.productType).toLowerCase()}${current+1}',
                              ).then((_) {
                                for(int i = current; i < images.length - 1; i++) {
                                  setState(() {
                                    images[i] = images[i+1];
                                  });
                                }
                                setState(() {
                                  images[images.length-1] = null;
                                  lastFilled = lastFilled - 1;
                                });
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WefoodPopup(
                                      context: context,
                                      title: '¡Imagen eliminada correctamente!',
                                      cancelButtonTitle: 'OK',
                                    );
                                  }
                                );
                              });
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
            ],
          ),
          cancelButtonTitle: 'CANCELAR',
        );
      }
    );
  }

  void _retrieveData() async {
    ProductExpandedModel response = await Api.getProduct(
      id: widget.productId!,
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

  void _retrieveImages() async {
    for(int i = 0; i < images.length; i++) {
      try {
        Api.getImage(
          idUser: context.read<UserInfoCubit>().state.user.id!,
          meaning: '${Utils.productTypeToChar(widget.productType).toLowerCase()}${i+1}',
        ).then((ImageModel imageModel) async {
          if(imageModel.route != null) {
            setState(() {
              images[i] = ImageWithLoader.network(
                  route: imageModel.route!
              );
            });
          }
        });
      } catch(error) { /*if (kDebugMode) print('ERROR AL CARGAR LA FOTO [$i]: $error');*/ }
    }
  }

  @override
  void initState() {
    _productTypeString = Utils.productTypeToString(
      type: widget.productType,
    ) ?? '';
    if(widget.productId != null) { // Is editing an existing product
      _retrieveData();
      _retrieveImages();
    } else { // Is creating a new product
      setState(() {
        isRetrievingData = false;
      });
    }
    initialWeekDays[0] = mondays;
    initialWeekDays[1] = tuesdays;
    initialWeekDays[2] = wednesdays;
    initialWeekDays[3] = thursdays;
    initialWeekDays[4] = fridays;
    initialWeekDays[5] = saturdays;
    initialWeekDays[6] = sundays;
    super.initState();
  }

  Widget resultWidget = const LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      controller: scrollController,
      title: '${(widget.productId != null) ? 'Editar' : 'Crear'} $_productTypeString',
      body: [
        Wrap(
          runSpacing: 25,
          children: <Widget>[
            if(isRetrievingData == true) const LoadingIcon(),
            if(isRetrievingData == false) Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Precio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: WefoodInput(
                    initialText: (widget.productId != null) ? price.toString() : '',
                    onChanged: (String value) {
                      double? parsedValue = double.tryParse(value);
                      setState(() {
                        if(parsedValue != null && parsedValue < Environment.minimumPrice) {
                          _setError('El precio debe ser de al menos ${Environment.minimumPrice} S/.');
                        } else {
                          _setError('');
                        }
                        error = '';
                        price = double.tryParse(value);
                      });
                    },
                    labelText: 'Hasta',
                    type: InputType.decimal,
                    feedbackWidget: (price != null)
                      ? (price! < Environment.minimumPrice)
                        ? const FeedbackMessage(
                          message: 'Precio mínimo: ${Environment.minimumPrice} S/.',
                          isError: true,
                        ) : null
                      : null,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Horario de recogida:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                (widget.productId == null || (widget.productId != null && isRetrievingData == false))
                  ? ScheduleSetter(
                    startTime: startTime,
                    endTime: endTime,
                    onChangeStartTime: (TimeOfDay selectedTime) {
                      setState(() {
                        startTime = selectedTime;
                      });
                    },
                    onChangeEndTime: (TimeOfDay selectedTime) {
                      setState(() {
                        endTime = selectedTime;
                      });
                    },
                  )
                  : const LoadingIcon(),
              ],
            ),
            if(isRetrievingData == true) const LoadingIcon(),
            if(isRetrievingData == false) Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Número de packs por día:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: WefoodInput(
                    initialText: (widget.productId != null) ? amount.toString() : null,
                    onChanged: (String value) {
                      setState(() {
                        error = '';
                        amount = int.tryParse(value);
                      });
                    },
                    labelText: 'Hasta',
                    type: InputType.integer,
                  ),
                ),
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
                if(Utils.sumTrueBooleans([junk, dessert, vegetarian, vegan]) > 2) const FeedbackMessage(
                  message: 'Máximo 2 categorías',
                  isError: true
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
                if(Utils.sumTrueBooleans([mondays, tuesdays, wednesdays, thursdays, fridays, saturdays, sundays]) == 0) const FeedbackMessage(
                    message: 'Mínimo 1 día de la semana',
                    isError: true
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Añadir imágenes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
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
                            image: (images[0] != null) ? images[0] : null,
                            isMain: true,
                            onTap: () async {
                              _manageImageSlot(0);
                            },
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
                            children: <int>[0, 1, 2, 3, 4].map((i) {
                              return ImageSlot(
                                image: (images[i] != null) ? images[i] : null,
                                onTap: () async {
                                  _manageImageSlot(i);
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.025,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <int>[5, 6, 7, 8, 9].map((i) {
                              return ImageSlot(
                                image: (images[i] != null) ? images[i] : null,
                                onTap: () async {
                                  _manageImageSlot(i);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                const SizedBox(
                  width: 20,
                ),
                if(isSubmitting == true) const LoadingIcon(),
                if(isSubmitting == false && isRetrievingData == false) ElevatedButton(
                  child: const Text('GUARDAR'),
                  onPressed: () {
                    if(_readyToRegister() == true) {
                      setState(() {
                        isSubmitting = true;
                      });
                      try {
                        if(widget.productId != null) {
                          _safeEditProduct();
                        } else {
                          _safeCreateProduct();
                        }
                      } catch(e) {
                        setState(() {
                          isSubmitting = false;
                          error = 'Ha ocurrido un error: $e'; // TODO hacer algo más currado
                        });
                        scrollToBottom(
                          scrollController: scrollController,
                        );
                      }
                    } else {
                      scrollToBottom(
                        scrollController: scrollController,
                      );
                    }
                  },
                ),
              ],
            ),
            if(error != '') FeedbackMessage(
              message: error,
              isError: true,
              isCentered: true,
            ),
            if(widget.productId != null && isSubmitting == false && isRetrievingData == false) Align(
              child: ElevatedButton(
                child: const Text('ELIMINAR PRODUCTO'),
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
                                scrollToBottom(
                                  scrollController: scrollController,
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}