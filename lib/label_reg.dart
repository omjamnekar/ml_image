import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class LabelRec extends StatefulWidget {
  const LabelRec({Key? key}) : super(key: key);

  @override
  State<LabelRec> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LabelRec> {
  bool textScanning = false;
  String lsd = "";
  XFile? imageFile;
  List<String> list = [];

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
                if (imageFile != null) Image.file(File(imageFile!.path)),
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
                Text(
                  scannedText,
                  style: TextStyle(fontSize: 20),
                )
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRegcognisedLabel(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;

      scannedText = "Error occured while scenning";
      setState(() {});
    }
  }

  void getRegcognisedLabel(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final barCodeDetector = GoogleMlKit.vision.imageLabeler();

    List labelDec = await barCodeDetector.processImage(inputImage);

    for (ImageLabel label in labelDec) {
      final String text = label.label;

      final double confidance = label.confidence;
      final String per = convertToPercentage(confidance);
      scannedText = "$text - $per";

      print(scannedText);
      list = [...list, scannedText];
    }

    textScanning = false;

    setState(() {
      scannedText = "";
      list.forEach((e) => scannedText += "\n$e ");
      list = [];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  String convertToPercentage(double decimalValue) {
    // Multiply by 100 and format as a percentage
    return '${(decimalValue * 100).toStringAsFixed(0)}%';
  }
}