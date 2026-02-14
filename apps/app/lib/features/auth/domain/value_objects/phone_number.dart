class PhoneNumber {
  PhoneNumber._();

  static final RegExp _iraqE164 = RegExp(r'^\+9647[0-9]{9}$');

  static String? normalize(String input) {
    var value = input.trim();
    if (value.isEmpty) {
      return null;
    }

    value = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (value.startsWith('00')) {
      value = '+${value.substring(2)}';
    } else if (value.startsWith('964')) {
      value = '+$value';
    } else if (value.startsWith('07') && value.length == 11) {
      value = '+964${value.substring(1)}';
    } else if (value.startsWith('7') && value.length == 10) {
      value = '+964$value';
    }

    if (!_iraqE164.hasMatch(value)) {
      return null;
    }
    return value;
  }
}
