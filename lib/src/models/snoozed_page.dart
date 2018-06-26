class SnoozedPage {
  final DateTime alarmTime;

  final String url;

  SnoozedPage({this.alarmTime, this.url});

  factory SnoozedPage.fromMap(Map<String, String> map) {
    final epochTime = int.parse(map['alarmTime']);
    final url = map['url'];
    return new SnoozedPage(
      alarmTime: new DateTime.fromMillisecondsSinceEpoch(epochTime),
      url: url,
    );
  }

  Map<String, String> toMap() => {
        'alarmTime': alarmTime.millisecondsSinceEpoch.toString(),
        'url': url,
      };
}
