import 'package:timeago/timeago.dart' as timeago;

/// 한국어 시간 형식 설정
class TimeagoLocalization {
  static void initialize() {
    timeago.setLocaleMessages('ko', KoreanMessages());
  }
}

/// 한국어 메시지 클래스
class KoreanMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '전';
  @override
  String suffixFromNow() => '후';
  @override
  String lessThanOneMinute(int seconds) => '방금';
  @override
  String aboutAMinute(int minutes) => '1분';
  @override
  String minutes(int minutes) => '${minutes}분';
  @override
  String aboutAnHour(int minutes) => '1시간';
  @override
  String hours(int hours) => '${hours}시간';
  @override
  String aDay(int hours) => '1일';
  @override
  String days(int days) => '${days}일';
  @override
  String aboutAMonth(int days) => '1개월';
  @override
  String months(int months) => '${months}개월';
  @override
  String aboutAYear(int year) => '1년';
  @override
  String years(int years) => '${years}년';
  @override
  String wordSeparator() => ' ';
}