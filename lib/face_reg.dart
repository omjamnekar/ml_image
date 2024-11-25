import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class FaceDec extends StatefulWidget {
  const FaceDec({Key? key}) : super(key: key);

  @override
  State<FaceDec> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<FaceDec> {
  bool textScanning = false;
  String lsd = "";
  var imageFile;
  File? pickedImage;
  List<String> list = [];
  List<Rect> rect = [];
  bool isFaceDected = false;
  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    lsd = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(lsd),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                  ),
                imageFile != null && isFaceDected
                    ? Center(
                        child: Container(
                        child: FittedBox(
                          child: SizedBox(
                            width: imageFile?.width?.toDouble() ?? 0.0,
                            height: imageFile?.height?.toDouble() ?? 0.0,
                            child: CustomPaint(
                              painter: FacePainter(
                                rect: rect,
                                imageFile: imageFile,
                              ),
                            ),
                          ),
                        ),
                      ))
                    : Container(),
                // : Image.file(File(imageFile!.path)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.camera);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                ),
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Text(
                    scannedText,
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      var tempStore = await ImagePicker().pickImage(source: source);

      imageFile = await tempStore!.readAsBytes();
      imageFile = await decodeImageFromList(imageFile);
      if (tempStore != null) {
        textScanning = true;

        setState(() {
          pickedImage = File(tempStore.path);
          imageFile = imageFile;
          isFaceDected = false;
        });

        getRegcognisedLabel(pickedImage!);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;

      scannedText = "Error occured while scenning";
      setState(() {});
    }
  }

  void getRegcognisedLabel(File path) async {
    final inputImage = InputImage.fromFile(path);
    final barCodeDetector = GoogleMlKit.vision.faceDetector();

    final ad = GoogleMlKit.vision.digitalInkRecognizer(languageCode: "en");
    List<Face> faces = await barCodeDetector.processImage(inputImage);

    if (rect.length > 0) {
      rect = [];
    }
    for (Face face in faces) {
      rect.add(face.boundingBox);
    }
    setState(() {
      isFaceDected = true;
      textScanning = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }
}

class FacePainter extends CustomPainter {
  List<Rect>? rect;
  var imageFile;

  FacePainter({@required this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    for (Rect rectangle in rect!) {
      canvas.drawRect(
        rectangle,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    throw UnimplementedError();
  }
}
