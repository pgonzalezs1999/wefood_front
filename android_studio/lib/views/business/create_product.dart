import 'package:flutter/material.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/types.dart';

class CreateProduct extends StatefulWidget {

  final ProductType productType;

  const CreateProduct({
    super.key,
    required this.productType,
  });

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      ignoreHorizontalPadding: true,
      ignoreVerticalPadding: true,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    BackArrow(),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.666)],
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
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
                            child: Image.asset('assets/images/logo.jpg'),
                          ),
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Caja sorpresa de',
                            style: TextStyle( // TODO deshardcodear estilo
                              color: Colors.white,
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
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
              vertical: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Card(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          child: const Icon(Icons.location_pin),
                          onTap: () {

                          },
                        ),
                      ),
                    )
                  ],
                ),
                const Divider(),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: Center(
                    child: ElevatedButton(
                      child: const Text('COMPRAR'),
                      onPressed: () {

                      },
                    ),
                  ),
                ),
                const Divider(),
                const Text('¿Qué opinan los compradores?'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}