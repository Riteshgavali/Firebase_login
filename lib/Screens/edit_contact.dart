import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../model/contact.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditContact extends StatefulWidget {
  late final String id;
  EditContact(this.id);

  @override
  State<EditContact> createState() => _EditContactState(id);
}

class _EditContactState extends State<EditContact> {
  late String id;
  _EditContactState(this.id);

  String _firstName = '';
  String _email = '';
  String _lastName = '';
  String _phone = '';
  String _address = '';
  String _photoUrl;

  // handle text editing controller

  TextEditingController _fnController = TextEditingController();
  TextEditingController _lnController = TextEditingController();
  TextEditingController _poController = TextEditingController();
  TextEditingController _emController = TextEditingController();
  TextEditingController _adController = TextEditingController();

  bool isLoading = true;

  // firebase/db helper

  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getContact(id);
  }

  getContact(id) async {
    Contact contact;
    _databaseReference.child(id).onValue.listen((event) {
      contact = Contact.fromSnapshot(event.snapshot);

      _fnController.text = contact.firstName;
      _lnController.text = contact.lastName;
      _poController.text = contact.phone;
      _emController.text = contact.email;
      _adController.text = contact.address;

      setState(() {
        _firstName = contact.firstName;
        _lastName = contact.lastName;
        _phone = contact.phone;
        _address = contact.address;
        _email = contact.email;
        _photoUrl = contact.photoUrl;

        isLoading = false;
      });
    });
  }

//pickImage
  Future pickImages() async {
    File file = await jpg.pickImages(
      source: ImageSource.gallery,
    );
    String fileName = basename(file.path);
    uploadImage(file, fileName);
  }

//Upload Image

  void uploadImage(File file, String fileName) async {
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    //uplad Image
    reference.putFile(file).whenComplete(() {
      var url;
      url = reference.getDownloadURL();
      setState(() {
        _photoUrl = url;
      });
    }); // oncomplete.then((FirebaseFile)async{var downloadUrl})
  }

  navigateToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }

  //updateContact
  updateContact(BuildContext context) async {
    if (_firstName.isNotEmpty &&
        _lastName.isNotEmpty &&
        _email.isNotEmpty &&
        _phone.isNotEmpty &&
        _address.isNotEmpty) {
      Contact contact = Contact.withId(
          this.id, _firstName, _lastName, _phone, _email, _address, _photoUrl);

      await _databaseReference.child(id).set(contact.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Field Required"),
              content: Text("All Fields are required"),
              actions: [
                FloatingActionButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

@override
Widget build(BuildContext context) {
  var isLoading;
  return Scaffold(
    appBar: AppBar(
      title: Text("Edit Contact"),
    ),
    body: Container(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  //image view
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          this.pickImage();
                        },
                        child: Center(
                          child: Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: _photoUrl == "empty"
                                        ? AssetImage("images/placeholder.png")
                                        : NetworkImage(_photoUrl),
                                  ))),
                        ),
                      )),
                  //
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _firstName = value;
                        });
                      },
                      controller: _fnController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  //
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _lastName = value;
                        });
                      },
                      controller: _lnController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  //
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _phone = value;
                        });
                      },
                      controller: _poController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  //
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                      controller: _emController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  //
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _address = value;
                        });
                      },
                      controller: _adController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  // update button
                  Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: RaisedButton(
                      padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 20.0),
                      onPressed: () {
                        updateContact(context);
                      },
                      color: Colors.red,
                      child: Text(
                        "Update",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    ),
  );
}
