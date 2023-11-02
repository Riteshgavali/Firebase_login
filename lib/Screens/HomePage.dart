import 'package:flutter/material.dart';
import 'add_contact.dart';
import 'view_contact.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  navigateToAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddContact();
        },
      ),
    );
  }

  navigateToViewScreen(String? key) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          //ToDo add id
          return ViewContact(id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddScreen,
        child: Icon(Icons.add),
      ),
      body: Container(
        child: FirebaseAnimatedList(
            query: _databaseReference,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return GestureDetector(
                onTap: () {
                  navigateToViewScreen(snapshot.key);
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: snapshot.value['photoUrl'] == "empty"
                                  ? AssetImage("assets/logo.png")
                                  : NetworkImage(snapshot.value['photoUrl']),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${snapshot.value['firstName']} $Text(${snapshot.value['lastName']} ",
                              ),
                              Text(
                                "${snapshot.value['phone']}",
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
      appBar: AppBar(
        title: Text("Home Page"),
      ),
    );
  }
}
