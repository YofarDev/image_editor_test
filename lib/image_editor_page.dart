import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ImageEditorPage extends StatefulWidget {
  final String imagePath;

  const ImageEditorPage({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  ImageEditorPageState createState() => ImageEditorPageState();
}

class ImageEditorPageState extends State<ImageEditorPage> {
  double _sliderBrightnessValue = 0;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          Screenshot(
            controller: _screenshotController,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                ColorFilterGenerator.brightnessAdjustMatrix(
                    value: _sliderBrightnessValue),
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _tools(),
        ],
      ),
    );
  }

  Widget _tools() => Row(
        children: [
          Expanded(
            child: Slider(
              value: _sliderBrightnessValue,
              min: -0.5,
              max: 2,
              onChanged: (double value) {
                setState(() {
                  _sliderBrightnessValue = value;
                });
              },
            ),
          ),
          TextButton(onPressed: _applyBrightness, child: Text("Apply")),
        ],
      );

  Future<void> _applyBrightness() async {
    img.Image? image =
        img.decodeImage(File(widget.imagePath).readAsBytesSync());
    if (image == null) return;

    double brightness = _convert();

    img.adjustColor(image, brightness: brightness);

    print("brightness: $brightness // $_sliderBrightnessValue");

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/image_edited_${DateTime.now().toIso8601String()}.jpg');
    File(file.path).writeAsBytesSync(img.encodeJpg(image));

    final file2 = File(
        '${dir.path}/image_edited_${DateTime.now().toIso8601String()}.jpg');

    var bytes = await _takeScreenshot();
    file2.writeAsBytesSync(bytes!);

    Map<String, dynamic> data = {
      "image": file,
      "image2": file2,
    };

    if (mounted) Navigator.of(context).pop(data);
  }

  Future<Uint8List?> _takeScreenshot() async {
    var bytes = await _screenshotController.capture();
    return bytes;
  }

  double _convert() {
    return _sliderBrightnessValue * 2;
  }
}

class ColorFilterGenerator {
  static List<double> brightnessAdjustMatrix({required double value}) {
    value = (value <= 0) ? value * 255 : value * 100;
    return (value == 0)
        ? [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
        : [
            1,
            0,
            0,
            0,
            value,
            0,
            1,
            0,
            0,
            value,
            0,
            0,
            1,
            0,
            value,
            0,
            0,
            0,
            1,
            0
          ];
  }
}
