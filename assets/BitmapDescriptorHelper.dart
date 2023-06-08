import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class BitmapDescriptorHelper {

  static Future<BitmapDescriptor> getBitmapDescriptorFromSvgAsset(
      String assetName, [
        Size size = const Size(48, 48),
      ]) async {
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);

    double devicePixelRatio = ui.window.devicePixelRatio;
    int width = (size.width * devicePixelRatio).toInt();
    int height = (size.height * devicePixelRatio).toInt();

    final scaleFactor = min(
      width / pictureInfo.size.width,
      height / pictureInfo.size.height,
    );

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final rasterPicture = recorder.endRecording();

    final image = rasterPicture.toImageSync(width, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }
}