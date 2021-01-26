import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:blog/services/crud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_core/firebase_core.dart';

class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  String authorName, title, desc;
  File selectedImage;
  bool _isLoading = false; //
  CrudMethods crudMethods = new CrudMethods();

  // Future getImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (pickedFile != null) {
  //       selectedImage = File(pickedFile.path);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

  Future<void> getImage() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      selectedImage = imageFile;
    });
  }

  uploadBlog() async {
    if (selectedImage != null) {
      setState(() {
        _isLoading = true;
      });
      await Firebase.initializeApp();

      /// sending to FIRESTORE !!!!!
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg");
      final UploadTask task = firebaseStorageRef.putFile(selectedImage);
      String downloadURL = await FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg")
          .getDownloadURL();
      Map<String, String> blogMap = {
        "title": title,
        "authorName": authorName,
        "desc": desc,
        "download": downloadURL,
      };
      crudMethods.addData(blogMap).then((result) {
        Navigator.pop(context);
      });

      //TODO fix this man >:(

      // var downloadUrl;
      // await task.whenComplete(await );
      // Uri downloadUrl = (await task.future).downloadUrl;
      //var downloadURl = await (await task.whenComplete(then((result{await taks.downloadUrl}))));
      // print("this is urlDownload: $downloadUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Flutter",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            Text(
              "Blog",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              uploadBlog();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.file_upload),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    print('tapped ooo');
                    getImage();
                  },
                  child: selectedImage != null
                      ? Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(selectedImage, fit: BoxFit.cover),
                          ),
                        )
                      : Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.add_a_photo, color: Colors.blue),
                        ),
                ),
                SizedBox(height: 20),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Author",
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              authorName = val;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Title",
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              title = val;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Desc",
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              desc = val;
                            },
                          ),
                        )
                      ],
                    ))
              ],
            )),
    );
  }
}
