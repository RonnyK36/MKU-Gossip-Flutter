import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:mku_gossip/models/user.dart';
import 'package:mku_gossip/pages/home.dart';
import 'package:mku_gossip/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  // final picker = ImagePicker();

  handleTakePhoto() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      // maxHeight: 675,
      // maxWidth: 960,
    );
    setState(() {
      this.file = pickedFile;
    });
  }

  Future handleChooseFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = pickedFile;
    });
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

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFIle = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFIle;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({
    String mediaUrl,
    String location,
    String description,
  }) {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "location": location,
      "description": description,
      "timestamp": timestamp,
      "likes": {},
    });
    locationController.clear();
    captionController.clear();
    setState(() {
      file = null;
      isUploading = false;
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
  }

  doNothing() {}

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
            onPressed: isUploading ? doNothing() : () => handleSubmit(),
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
          isUploading ? linearProgress() : Text(''),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 240,
            child: Center(
              child: Container(
                height: 230,
                width: 350,
                child: file == null
                    ? Center(
                        child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/Screenshot (27).png'))),
                      ))
                    : Image.file(file),
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
                controller: captionController,
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
                controller: locationController,
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
              onPressed: getUserLocation,
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

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subLocality},${placemark.locality},${placemark.subAdministrativeArea},${placemark.administrativeArea},${placemark.country},${placemark.postalCode},${placemark.position}';
    print(completeAddress);
  }

  @override
  Widget build(BuildContext context) {
    //
    return file == null ? buildSplashScreen() : buildUploadForm();
    // Text('We have a file')
  }
}
