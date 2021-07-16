import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mku_gossip/models/user.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  // final picker = ImagePicker();

  handleTakePhoto() async {
    File pickedFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      file = pickedFile;
    });
    Navigator.pop(context);
  }

  // Future handleChooseFromGallery() async {
  //   Navigator.pop(context);
  //   final file = await picker.getImage(source: ImageSource.gallery);
  //
  //   setState(() {
  //     if (file != null) {
  //       this.file = File(file.path);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

  handleChooseFromGallery() async {
    File pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file = pickedFile;
    });
    Navigator.pop(context);
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create post'),
            children: [
              SimpleDialogOption(
                child: Text('Take with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Pick from gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 250,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () {
                selectImage(context);
              },
              child: Text('Upload Item'),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage(),
        ),
        title: Text(
          'Create post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Posting');
            },
            child: Text(
              'POST',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 220,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.redAccent,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Where was this picture taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            width: 200,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Location');
              },
              icon: Icon(
                Icons.my_location,
              ),
              label: Text(
                'Use current location',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
