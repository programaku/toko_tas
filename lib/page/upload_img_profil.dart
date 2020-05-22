import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tas_murah/model/api.dart';

class UploadImageProfile extends StatefulWidget {
  final String title = "Upload Image Profile";
  @override
  UploadImageProfileState createState() => UploadImageProfileState();
}

class UploadImageProfileState extends State<UploadImageProfile> {
  //
  Future<File> file;
  String status = '', iduserx="";
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduserx = preferences.getString("iduser");
    }
    );
  }

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }
  @override
  initState(){
    super.initState();
    getPref();
  }
  setStatus(String message)async {
    setState(() {
      status = message;
      cekbalik();
    });

  }

  cekbalik() async{
    if(status=="Image Uploaded Successfully."){
      await new Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop();
    }
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    upload(fileName);
  }

  upload(String fileName) {
    http.post(BaseUrl.upload_profile, body: {
      "image": base64Image,
      "name": fileName,
      "iduser": iduserx,
    }).then((result) {
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      setStatus(error);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
            child: Image.file(
              snapshot.data,
              fit: BoxFit.fill,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Unggah Gambar Profile",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            OutlineButton(
                onPressed: chooseImage,
                child: FlatButton.icon(
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    icon: Icon(Icons.camera_alt), //`Icon` to display
                    label: Text("Ambil Gambar"), //`Text` to display
                    onPressed: (){
                      chooseImage();
                    }
                )
            ),
            SizedBox(
              height: 20.0,
            ),
            showImage(),
            SizedBox(
              height: 20.0,
            ),
            OutlineButton(
                onPressed: startUpload,
                child: FlatButton.icon(
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    icon: Icon(Icons.file_upload), //`Icon` to display
                    label: Text("Upload Gambar"), //`Text` to display
                    onPressed: (){
                      startUpload();
                    }
                )
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}