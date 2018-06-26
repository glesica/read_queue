class SnoozedPage {
  final int epochMs;

  final String url;

  SnoozedPage({this.epochMs, this.url});

  factory SnoozedPage.fromMap(Map<String, String> map) {
    final epochMs = int.parse(map['epochMs']);
    final url = map['url'];
    return new SnoozedPage(
      epochMs: epochMs,
      url: url,
    );
  }

  Map<String, String> toMap() => {
        'epochMs': epochMs.toString(),
        'url': url,
      };

  @override
  String toString() => '{"epochMs": "$epochMs", "url": "$url"}';
}
