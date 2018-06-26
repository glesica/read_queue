import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:barback/barback.dart';
import 'package:pubspec/pubspec.dart';

class ManifestTransformer extends Transformer {
  ManifestTransformer.asPlugin();

  @override
  Future apply(Transform transform) async {
    var stringContent = await transform.primaryInput.readAsString();
    var jsonContent = JSON.decode(stringContent);

    // Version
    var pubspec = await PubSpec.load(Directory.current);
    var version = pubspec.version;

    if (jsonContent is Map) {
      jsonContent['version'] = version.toString();
    }

    var id = transform.primaryInput.id;

    var newContent = JSON.encode(jsonContent);
    transform.addOutput(new Asset.fromString(id, newContent));
  }

  @override
  Future<bool> isPrimary(AssetId id) async => id.path.endsWith('manifest.json');
}
