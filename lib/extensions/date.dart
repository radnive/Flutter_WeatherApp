class Date {
  static final List <String> weekDaysEn =
  ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  static final List <String> monthsEn =
  ['January','February','March','April','May','June','July','August','September','October','November','December'];

  static final List <String> weekDaysPer =
  ['دوشنبه','سه شنبه','چهارشنبه','پنجشنبه','جمعه','شنبه','یکشنبه'];
  static final List <String> monthsPer =
  ['ژانویه','فوریه','مارس','آوریل','مه','ژوئن','جولای','آگوست','سپتامبر','اکتبر','نوامبر','دسامبر'];

  final DateTime dateTime;
  const Date(this.dateTime);
  factory Date.epoch(int epochTime) => Date(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000, isUtc: true));

  String weekDayStr(bool isEn) => (isEn)? weekDaysEn[dateTime.weekday - 1] : weekDaysPer[dateTime.weekday - 1];
  String monthStr(bool isEn) => (isEn)? monthsEn[dateTime.month - 1] : monthsPer[dateTime.month - 1];
  String toStr(bool isEn) => '${weekDayStr(isEn)}${(isEn)? ',' : '،'} ${dateTime.day} ${monthStr(isEn)}';
  String toStrWithoutWeekDay(bool isEn) => '${dateTime.day} ${monthStr(isEn)}';

  String _formatNumForTime(int num) => (num <= 9)? '0$num' : '$num';
  String get timeStr => '${_formatNumForTime(dateTime.hour)}:${_formatNumForTime(dateTime.minute)}';
  String get hourStr => '${_formatNumForTime(dateTime.hour)}:00';
}
