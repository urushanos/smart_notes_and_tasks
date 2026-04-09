import 'package:intl/intl.dart';

String formatDateDdMmYyyy(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}
