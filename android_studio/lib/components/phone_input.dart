import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/models/country_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';

class PhoneInput extends StatefulWidget {
  final Function(CountryModel) onChangedPrefix;
  final Function(String) onChangedNumber;

  const PhoneInput({
    super.key,
    required this.onChangedPrefix,
    required this.onChangedNumber,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  String selectedPrefix = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountryModel>>(
      future: Api.getAllCountries(),
      builder: (BuildContext context, AsyncSnapshot<List<CountryModel>> response) {
        if(response.hasError) {
          return Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: const Text('No hemos podido conectar con el servidor. Por favor, inténtalo de nuevo más tarde'),
          );
        } else if(response.hasData) {
          if (response.data!.isEmpty) {
            return Align(
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: const Text(
                      'Error al contactar con el servidor. Por favor, inténtalo de nuevo más tarde.'),
                ),
              ),
            );
          } else {
            List<DropdownMenuItem<String>> items = response.data!.map((country) {
              return DropdownMenuItem<String>(
                value: country.prefix.toString(),
                child: Text('(+${country.prefix}) ${country.name}'),
              );
            }).toList();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: selectedPrefix.isNotEmpty ? selectedPrefix : '51',
                  items: items,
                  onChanged: (value) {
                      setState(() {
                        selectedPrefix = value!;
                      });
                      widget.onChangedPrefix(response.data!.firstWhere((country) => country.prefix.toString() == value));
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: WefoodInput(
                    onChanged: widget.onChangedNumber,
                    labelText: 'Número de teléfono',
                    type: InputType.integer,
                  ),
                ),
              ],
            );
          }
        } else {
          return const LoadingIcon();
        }
      },
    );
  }
}