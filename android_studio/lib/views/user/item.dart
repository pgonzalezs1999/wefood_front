import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class Item extends StatefulWidget {

  final ProductExpandedModel productExpanded;

  const Item({
    super.key,
    required this.productExpanded,
  });

  @override
  State<Item> createState() => _ItemState();
}
class _ItemState extends State<Item> {

  Widget favouriteIcon = const Icon(Icons.favorite_outline);
  ProductExpandedModel? info;
  int selectedAmount = 1;
  List<String> backgroundImageRoutes = [];
  String? profileImageRoute;
  LoadingStatus loadingFavourite = LoadingStatus.unset;

  List<DropdownMenuItem<int>> _amountOptions(int max) {
    List<DropdownMenuItem<int>> amounts = [];
    for(int i = 1; i <= max; i++) {
      amounts.add(
        DropdownMenuItem<int>(
          value: i,
          child: Text(i.toString()),
        )
      );
    }
    return amounts;
  }

  void _getBackgroundImages({required int searchedPosition}) async {
    ImageModel? imageModel;
    try {
      imageModel = await Api.getImage(
        idUser: widget.productExpanded.user.id!,
        meaning: '${widget.productExpanded.product.type!.toLowerCase()}$searchedPosition',
      );
    } catch(e) {
      imageModel = null;
    }
    if(imageModel?.route != null) {
      setState(() {
        backgroundImageRoutes.addIf(true, imageModel!.route!);
      });
      _getBackgroundImages(
        searchedPosition: searchedPosition + 1,
      );
    }
  }

  void _getProfileImage() async {
    try {
      ImageModel? imageModel = await Api.getImage(
        idUser: widget.productExpanded.user.id!,
        meaning: 'profile',
      );
      setState(() {
        profileImageRoute = imageModel.route;
      });
    } catch(e) {
      return;
    }
  }

  void _navigateToBusinessScreen({
    required businessExpanded
  }) {
    callRequestWithLoading(
      context: context,
      request: () async {
        return await Api.getBusiness(
          idBusiness: widget.productExpanded.business.id!,
        );
      },
      onSuccess: (BusinessExpandedModel response) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BusinessScreen(
            businessExpanded: response, // businessExpanded,
          )),
        );
      },
      onError: (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WefoodPopup(
              context: context,
              title: 'Ha ocurrido un error al cargar el negocio',
              description: 'Por favor, inténtelo de nuevo más tarde: $error',
              cancelButtonTitle: 'OK',
            );
          }
        );
      }
    );
  }

  _retrieveData() {
    Api.getItem(
      id: widget.productExpanded.item.id!,
    ).then((ProductExpandedModel response) {
      if(response.business.comments != null && response.business.comments!.isNotEmpty) {
        response.business.comments = response.business.comments!.reversed.toList();
      }
      setState(() {
        info = response;
      });
    });
  }

  @override
  void initState() {
    _getBackgroundImages(
      searchedPosition: 1
    );
    _getProfileImage();
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      ignoreHorizontalPadding: true,
      ignoreVerticalPadding: true,
      body: [
        if(info == null) const SizedBox(
          height: 500,
          child: Center(
              child: LoadingIcon()
          ),
        ),
        if(info != null) Column(
          children: [
            Stack(
              children: <Widget>[
                if(backgroundImageRoutes.isNotEmpty) CarouselSlider(
                  items: backgroundImageRoutes.map((String route) => ImageWithLoader.network(
                    route: route,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  )).toList(),
                  options: CarouselOptions(
                    viewportFraction: 1,
                    height: MediaQuery.of(context).size.height * 0.25,
                    enableInfiniteScroll: (backgroundImageRoutes.length > 1),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                  ),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const BackArrow(
                            whiteBackground: true,
                          ),
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: const Color.fromRGBO(255, 255, 255, 0.8),
                              ),
                              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                              child: (loadingFavourite == LoadingStatus.loading)
                                ? ReducedLoadingIcon(
                                  customMargin: MediaQuery.of(context).size.width * 0.016,
                                )
                                : (info!.isFavourite == true)
                                  ? const Icon(Icons.favorite)
                                  : const Icon(Icons.favorite_outline),
                            ),
                            onTap: () async {
                              if(loadingFavourite != LoadingStatus.loading) {
                                setState(() {
                                  loadingFavourite = LoadingStatus.loading;
                                });
                                try {
                                  if(info!.isFavourite == true) {
                                    Api.removeFavourite(idBusiness: info!.business.id!).then((_) {
                                      setState(() {
                                        loadingFavourite = LoadingStatus.successful;
                                        info!.isFavourite = false;
                                      });
                                    });
                                  } else {
                                    Api.addFavourite(idBusiness: info!.business.id!).then((_) {
                                      setState(() {
                                        loadingFavourite = LoadingStatus.successful;
                                        info!.isFavourite = true;
                                      });
                                    });
                                  }
                                } catch(e) {
                                  loadingFavourite = LoadingStatus.error;
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.75)],
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(MediaQuery.of(context).size.width * 0.05),
                                    child: (profileImageRoute != null)
                                      ? Image.network(
                                        profileImageRoute!,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(
                                        Icons.business,
                                      ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                _navigateToBusinessScreen(
                                  businessExpanded: info!.business.id,
                                );
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${Utils.productTypeInitialToName(
                                    string: widget.productExpanded.product.type!,
                                    isCapitalized: true,
                                    isPlural: true,
                                  )} de',
                                  style: const TextStyle( // TODO deshardcodear estilo
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  info!.business.name ?? '',
                                  style: const TextStyle( // TODO deshardcodear estilo
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
                vertical: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if(info!.business.description != null) Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Text>[
                      Text(
                        'Acerca de ${info!.business.name}:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(info!.business.description!),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Row(
                    children: <Text>[
                      Text(
                        'Precio: ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${info!.product.price?.toStringAsFixed(2)} Sol/.'),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: <Text>[
                      Text(
                        'Hora de recogida: ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('De ${_parseTime(info!.product.startingHour)} a ${_parseTime(info!.product.endingHour)} h'),
                    ],
                  ),
                  if(info!.business.rate != null) Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        children: <Widget>[
                          Text(
                            'Valoración: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if(info!.business.rate! > 0) Text('${info!.business.rate?.toStringAsFixed(1)}  '),
                          if(info!.business.rate! > 0) PrintStars(
                            rate: info!.business.rate!,
                          ),
                          if(info!.business.rate! == 0) const Text(
                            'Aún no hay valoraciones',
                            style: TextStyle(
                              color: Colors.grey, // TODO deshardcodear este estilo
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Ubicación: ',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Flexible(
                              child: Text('${info!.business.directions}'),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            child: const Icon(Icons.location_pin),
                            onTap: () {
                              MapsLauncher.launchQuery(info!.business.directions ?? '');
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  if(info!.product.vegetarian == true || info!.product.mediterranean == true || info!.product.junk == true || info!.product.dessert == true) Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Categorías: ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        children: <Widget>[
                          if(info!.product.vegetarian == true) const ProductTag(title: 'Vegetariano'),
                          if(info!.product.mediterranean == true) const ProductTag(title: 'Mediterráneo'),
                          if(info!.product.junk == true) const ProductTag(title: 'C. rápida'),
                          if(info!.product.dessert == true) const ProductTag(title: 'Postres'),
                        ],
                      ),
                    ],
                  ),
                  const Divider(
                    height: 50,
                  ),
                  Align(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if(info!.available != null) if(info!.available! > 0) Text('${info!.available} de ${info!.product.amount} disponibles'),
                        if(info!.available != null) if(info!.available! <= 0) const Text('¡Agotado!'),
                        if(info!.available != null) if(info!.available! > 0) ElevatedButton(
                          child: const Text('COMPRAR'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return StatefulBuilder(
                                  builder: (_, privateSetState) {
                                    return WefoodPopup(
                                      context: context,
                                      title: 'Comprar producto',
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Text('Cantidad:'),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              DropdownButton<int>(
                                                value: selectedAmount,
                                                items: _amountOptions(info!.available!),
                                                onChanged: (value) {
                                                  privateSetState(() {
                                                    selectedAmount = value!;
                                                  });
                                                },
                                              ),
                                              const Text(' packs'),
                                            ],
                                          ),
                                          if(info!.product.price != null) Align(
                                            alignment: Alignment.center,
                                            child: Text('Precio total:  ${(info!.product.price! * selectedAmount).toStringAsFixed(2)} Sol/.'),
                                          ),
                                        ],
                                      ),
                                      cancelButtonTitle: 'CANCELAR',
                                      actions: [
                                        TextButton(
                                          child: const Text('COMPRAR'),
                                          onPressed: () async {
                                            callRequestWithLoading(
                                              closePreviousPopup: true,
                                              context: context,
                                              request: () async {
                                                return await Api.orderItem(
                                                  idItem: info!.item.id!,
                                                  amount: selectedAmount,
                                                );
                                              },
                                              onSuccess: (_) {
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return WefoodPopup(
                                                      context: context,
                                                      title: '¡Producto comprado!',
                                                      description: 'Esto es todavía un entorno de pruebas. Más adelante, aquí aparecerá la pasarela de pago',
                                                      cancelButtonTitle: 'OK',
                                                      cancelButtonBehaviour: () {
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  }
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 50,
                  ),
                  Text(
                    '¿Qué opinan los compradores?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if(info!.business.comments != null && info!.business.comments!.isNotEmpty) Column(
                    children: info!.business.comments!.map((CommentExpandedModel c) => Comment(
                      comment: c,
                      deletable: false,
                    )).toList(),
                  ),
                  if(info!.business.comments == null || (info!.business.comments != null && info!.business.comments!.isEmpty)) const Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Aún nadie ha dejado ningún comentario. ¡Prueba el producto y sé el primero en comentar tu experiencia!',
                        style: TextStyle(
                          color: Colors.grey, // TODO deshardcodear este estilo
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _parseTime(DateTime? dateTime) {
    if(dateTime == null) {
      return '[No data]';
    } else {
      String timeRaw = dateTime.toString().split(' ')[1];
      String time = timeRaw.split('.')[0];
      String result = '${time.split(":")[0]}:${time.split(":")[1]}';
      return result;
    }
  }
}