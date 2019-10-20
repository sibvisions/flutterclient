import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumericTextFormatter extends TextInputFormatter {
  String numberFormat;
  String locale;

  NumericTextFormatter([this.numberFormat, this.locale]) : super();

  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      NumberFormat numberFormatter = NumberFormat(this.numberFormat, this.locale);
      //int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
      //int num = int.parse(newValue.text.replaceAll(numberFormat.symbols.GROUP_SEP, ''));
      String newString = newValue.text;
      try {
      //final newString = numberFormat.format(num);
        if (newString.length>this.numberFormat.length) 
          newString = oldValue.text;
        else
          numberFormatter.format(convertToNumber(newString, numberFormat));
      } catch (e) {
        newString = oldValue.text;
      }
      return newValue.copyWith(text: newString);
      /*TextEditingValue editingValue = TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: newString.length - selectionIndexFromTheRight),
      );
      return editingValue;
      */
    } else {
      return newValue;
    }
  }

  static dynamic convertToNumber(dynamic pValue, String numberFormat) {
    if (pValue is String) {
      dynamic numberValue;
      if (numberFormat.contains("."))
        numberValue = double.tryParse(pValue);
      else
        numberValue = int.tryParse(pValue);
        
      return numberValue;
    }

    return pValue;
  }
}