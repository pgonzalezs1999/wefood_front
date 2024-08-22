import 'package:flutter/material.dart';

class ImageWithLoader {

  static Image network({
    required String route,
    double? height,
    double? width,
    BoxFit? fit,
  }) {
    return Image.network(
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if(loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
            value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          ),
        );
      },
      route,
      fit: fit ?? BoxFit.cover,
      height: height,
      width: width,
    );
  }
}
