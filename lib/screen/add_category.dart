import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:new_admin/http/custom_http_request.dart';
import 'package:new_admin/widget/brand_colors.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? fildName;
  bool onProgress = false;
  bool isVisiable = false;
  bool isImageVisiable = false;

  File? icon, image;
  final picker = ImagePicker();

  Future getIconformGallery() async {
    print('on the way of gallery');
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        icon = File(pickedImage.path);
        print('image found');
        print('$icon');
        setState(() {
          isVisiable = true;
        });
      } else {
        print('no image found');
      }
    });
  }

  Future getImageformGallery() async {
    print('on the way of gallery');
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        image = File(pickedImage.path);
        print('image found');
        print('$image');
        setState(() {
          isImageVisiable = true;
        });
      } else {
        print('no image found');
      }
    });
  }

  Future createCategory() async {
    setState(() {
      onProgress = true;
    });
    final uri =
        Uri.parse("https://apihomechef.antopolis.xyz/api/admin/category/store");
    var request = http.MultipartRequest("POST", uri);
    request.headers.addAll(
      await CustomHttpRequest.getHeaderWithToken(),
    );
    request.fields['name'] = fildName.toString();
    if (image != null) {
      var photo = await http.MultipartFile.fromPath('image', image!.path);
      print('processing');
      request.files.add(photo);
    }
    if (icon != null) {
      var _icon = await http.MultipartFile.fromPath('icon', icon!.path);
      print('processing');
      request.files.add(_icon);
    }
    var response = await request.send();
    print("${response.statusCode}");

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var data = jsonDecode(responseString);
    if (response.statusCode == 201) {
      print("responseBody1 $responseData");
      print('oooooooooooooooooooo');
      print(data['message']);
      setState(() {
        onProgress = false;
      });
      showInToast(data['message']);
      Navigator.pop(context);
      print("${response.statusCode}");
    } else {
      print("responseBody1 $responseString");
      print(data['errors']['image'][0]);
      showInToast(data["errors"]['image'][0]);
      setState(() {
        onProgress = false;
      });
    }
  }

  showInToast(String value) {
    Fluttertoast.showToast(
        msg: "$value",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: aPrimaryColor,
        textColor: aNavBarColor,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double weidth = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: onProgress,
      opacity: 0.1,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: aNavBarColor,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: aTextColor,
            ),
          ),
          title: Text('Add new category'),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Name',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: nameController,
                    onSaved: (name) {
                      fildName = name;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "*Write Category Name";
                      }
                      if (value.length < 3) {
                        return "*Write more then three word";
                      }
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            gapPadding: 5.0,
                            borderSide:
                                BorderSide(color: aTextColor, width: 2.5)),
                        hintText: 'Enter Category Name'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Category Icon',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Stack(
                    //      overflow: Overflow.visible,
                    children: [
                      Container(
                        height: height * 0.2,
                        width: weidth * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: icon == null
                            ? InkWell(
                                onTap: () {
                                  getIconformGallery();
                                },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: aTextColor.withOpacity(0.3),
                                        size: 40,
                                      ),
                                      Text(
                                        "UPLOAD",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: aTextColor.withOpacity(0.5)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(icon!),
                                )),
                              ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: weidth * 0.15,
                        child: Visibility(
                          visible: isVisiable,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                color: Colors.black,
                                border: Border.all(
                                    color: aNavBarColor, width: 1.5)),
                            child: TextButton(
                              onPressed: () {
                                print('click');
                                getIconformGallery();
                              },
                              child: Center(
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  child: Icon(Icons.add_alarm_outlined),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    '* 320x320 is the Recommended Size',
                    style: TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Category Image',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Stack(
                    // overflow: Overflow.visible,
                    children: [
                      Container(
                        height: height * 0.3,
                        width: weidth * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: image == null
                            ? InkWell(
                                onTap: () {
                                  getImageformGallery();
                                },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: aTextColor.withOpacity(0.3),
                                        size: 40,
                                      ),
                                      Text(
                                        "UPLOAD",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: aTextColor.withOpacity(0.5)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(image!),
                                )),
                              ),
                      ),
                      Positioned(
                        bottom: -25,
                        left: weidth * 0.4,
                        child: Visibility(
                          visible: isImageVisiable,
                          child: TextButton(
                            onPressed: () {
                              getImageformGallery();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.black,
                                  border: Border.all(
                                      color: aNavBarColor, width: 1.5)),
                              child: Center(
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.black,
                        border: Border.all(color: aTextColor, width: 0.5),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (icon == null) {
                              showInToast(
                                  'Please upload category icon from your mobile');
                            } else if (image == null) {
                              showInToast(
                                  'Please upload category image from your mobile');
                            } else {
                              createCategory();
                            }
                          }
                        },
                        child: Center(
                          child: Text(
                            'Publish Category',
                            style: TextStyle(
                                color: aPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
