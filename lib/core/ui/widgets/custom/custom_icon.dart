import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../utils/image/image_loader.dart';
import '../util/fontAwesomeChanger.dart';

class CustomIcon extends StatelessWidget {
  final String image;
  final Size size;
  final Color color;

  CustomIcon({@required this.image, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      if (checkFontAwesome(image)) {
        if (!image.contains("size=") && this.size == null) {
          return convertFontAwesomeTextToIcon(
              image, color != null ? color : Theme.of(context).primaryColor);
        } else {
          return _iconBuilder(formatFontAwesomeText(image), context);
        }
      }

      return getImage(image);
    } else {
      return Container();
    }
  }

  Size getSize(String image) {
    if (image == null) return null;

    List<String> arr = image.split(',');

    if (arr.length >= 3 &&
        double.tryParse(arr[1]) != null &&
        double.tryParse(arr[2]) != null)
      return Size(double.parse(arr[1]), double.parse(arr[2]));

    return null;
  }

  Image getImage(String image) {
    if (image == null) return null;

    Image img;
    List<String> arr = image.split(',');
    Size size = this.size;

    if (size == null) size = getSize(image);

    if (arr.length > 0)
      img = ImageLoader().loadImage('${arr[0]}', size?.width, size?.height);

    return img;
  }

  FaIcon _iconBuilder(Map data, BuildContext context) {
    double widgetSize;
    if (data['size'] != null && size == null) {
      List<String> arr = data['size'].split(',');
      if (arr.length > 0 && double.tryParse(arr[0]) != null)
        widgetSize = double.parse(arr[0]);
    } else {
      widgetSize = size?.height;
    }

    FaIcon icon = new FaIcon(
      data['icon'],
      size: widgetSize,
      color: color != null ? color : Theme.of(context).primaryColor,
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }
}