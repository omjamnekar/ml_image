import 'package:flutter/material.dart';
import 'package:ml_image/bar_reg.dart';
import 'package:ml_image/face_reg.dart';
import 'package:ml_image/label_reg.dart';
import 'package:ml_image/text_reg.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  List<String> itemList = [
    "Text Recognition",
    "Face Detection",
    "BarCode Scanner",
    "Subject Detection"
  ];

  List<Widget> list = [
    TextRec(),
    FaceDec(),
    BarCodeRec(),
    LabelRec(),
  ];

  void navigationPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => list[index],
        settings: RouteSettings(arguments: itemList[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ML kit_vision"),
      ),
      body: ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                itemList[index],
              ),
              onTap: () {
                navigationPage(index);
              },
            ),
          );
        },
      ),
    );
  }
}
