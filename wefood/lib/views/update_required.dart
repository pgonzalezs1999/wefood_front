import 'package:flutter/material.dart';
import 'package:wefood/views/views.dart';

class UpdateRequired extends StatefulWidget {

  const UpdateRequired({
    super.key,
  });

  @override
  State<UpdateRequired> createState() => _UpdateRequiredState();
}

class _UpdateRequiredState extends State<UpdateRequired> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '¡Nueva actualización!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Hemos hecho cambios que creemos que te van a gustar. ¡Queremos enseñártelos!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              if(_showButton) ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
                child: const Text('YA HE ACTUALIZADO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}