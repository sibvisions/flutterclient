import 'dart:io';

import 'package:flutter/widgets.dart';
import '../../ui/widgets/fontAwesomeChanger.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;

class CustomIcon extends StatelessWidget {
  final String image;
  final Size size;

  CustomIcon({
    @required this.image,
    this.size
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      if (checkFontAwesome(image))
        return _iconBuilder(formatFontAwesomeText(image));

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
    
    if (size==null) size=getSize(image);

    if (arr.length>0) 
      img = Image.file(File('${globals.dir}${arr[0]}'), width: size?.width, height: size?.height,);

    return img;
  }

  Icon _iconBuilder(Map data) {
    double widgetSize;
    if (data['size']!=null && size==null) {
      List<String> arr = data['size'].split(',');
      if (arr.length>0 && double.tryParse(arr[0]) != null) 
        widgetSize =  double.parse(arr[0]);
    } else {
      widgetSize = size?.height;
    }

    Icon icon = new Icon(
      data['icon'],
      size: widgetSize,
      color: UIData.ui_kit_color_2,
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }
}