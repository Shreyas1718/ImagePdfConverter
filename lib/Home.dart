import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_crop/image_crop.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File image;
  final pdf = pw.Document();
  final cropKey = GlobalKey<CropState>();

  bool setImage=true;

  File _lastCropped;
bool _dialVisible=true;
  pickerCamera() async {
    print('Picker is called');
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      image = img;
      setState(() {

      });
    }
  }
  pickerGallery() async {
    print('Picker is called');
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      image = img;
      setState(() {


      });
    }
  }
  @override
  void dispose() {
    super.dispose();
image?.delete();
    _lastCropped?.delete();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image Picker'),

      ),
      body: new Container(
        child: new Center(
          child: image == null
              ? new Text('No Image to Show ')
              :setImage==true? Stack(children: <Widget>[
            Image.file(image),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: (){
                  print('delete image from List');
                  setState(() {
                    image=null;
                  });
                },
                child: Icon(
                Icons.delete,
              ),),)
          ],):_buildCroppingImage(),
        ),
      ),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: _dialVisible,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.camera),
              backgroundColor: Colors.red,
              label: 'Camera',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: (){

                pickerCamera();

              }
          ),
          SpeedDialChild(
            child: Icon(Icons.photo),
            backgroundColor: Colors.blue,
            label: 'Gallery',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: (){

              pickerGallery();

            }
          ),
          SpeedDialChild(
            child: Icon(Icons.crop),
            backgroundColor: Colors.blue,
            label: 'Crop Image',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                setImage=false;
              });
              _buildCroppingImage();
            }
          ),
          SpeedDialChild(
              child: Icon(Icons.picture_as_pdf),
              backgroundColor: Colors.blue,
              label: 'Share as PDF',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                setState(() {
                  setImage=true;

                });
              pdfConversion();

              }
          ),
        ],
      ),
    );
  }
  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(image, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'Crop Image',
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.black),
                ),
                onPressed: () => _cropImage(),
              ),

            ],
          ),
        )
      ],
    );
  }
  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger

    final file = await ImageCrop.cropImage(
      file: image,
      area: area,
    );


    _lastCropped?.delete();
    _lastCropped = file;
setState(() {
  image=file;
  setImage=true;
});
    debugPrint('$file');
  }
pdfConversion () async {
  final PdfImage assetImage = await pdfImageFromImageProvider(
    pdf: pdf.document,
    image:FileImage(image),
  );
  pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(assetImage),
        ); // Center
      }));
  await Printing.sharePdf(bytes: pdf.save(), filename: 'my-document.pdf');
   SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
}
