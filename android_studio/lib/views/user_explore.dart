import 'package:flutter/material.dart';
import 'package:wefood/components/product_button.dart';
import 'package:wefood/components/search_input.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';

class UserExplore extends StatefulWidget {
  const UserExplore({super.key});

  @override
  State<UserExplore> createState() => _UserExploreState();
}

class _UserExploreState extends State<UserExplore> {

  @override
  Widget build(BuildContext context) {
    return WefoodNavigationScreen(
      children: [
        SearchInput(
            onChanged: (value) {

            }
        ),
        const Text('Recomendados'),
        const ProductButton(
          tags: [ 'Vegetariano', 'Vegano' ],
          isFavourite: false,
          title: 'Kimberly Pollería - Restobar - Chifa',
          rate: 4.5,
          price: 5,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
        const ProductButton(
          tags: [ 'Bollería' ],
          isFavourite: true,
          title: 'Restaurant Cevichería ELENITA',
          rate: 3,
          price: 9,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
        const ProductButton(
          tags: [ 'Bollería' ],
          isFavourite: true,
          title: 'Restaurant Cevichería ELENITA',
          rate: 3,
          price: 9,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
        const Text('Cerca de tí'), // TODO que esto no exista si no tenemos su ubicación
        const ProductButton(
          tags: [ 'Bollería' ],
          isFavourite: true,
          title: 'Restaurant Cevichería ELENITA',
          rate: 3,
          price: 9,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
        const ProductButton(
          tags: [ 'Bollería' ],
          isFavourite: true,
          title: 'Restaurant Cevichería ELENITA',
          rate: 3,
          price: 9,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
        const Text('Tus favoritos'), // TODO que esto no exista si no tiene nada en favoritos
        const ProductButton(
          tags: [ 'Bollería' ],
          isFavourite: true,
          title: 'Restaurant Cevichería ELENITA',
          rate: 3,
          price: 9,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
        const ProductButton(
          tags: [ 'Bollería' ],
          isFavourite: true,
          title: 'Restaurant Cevichería ELENITA',
          rate: 3,
          price: 9,
          currency: 'Sol/.',
          startTime: TimeOfDay(hour: 23, minute: 15),
          endTime: TimeOfDay(hour: 23, minute: 30),
        ),
      ],
    );
  }
}