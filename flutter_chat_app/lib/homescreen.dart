import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/methods.dart';
import 'package:flutter_chat_app/screens/chatroom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> userMap;
  bool isLoading = false;
  bool showList = false;

  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String chatRoomId(String user1, String user2) {
    if (user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]) {
      return '$user1$user2';
    } else {
      return '$user2$user1';
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection('users')
        .where('email', isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        showList = true;
        userMap = value.docs[0].data();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
          actions: [
            IconButton(
                onPressed: () => logOut(context),
                icon: const Icon(Icons.logout))
          ],
        ),
        body: Center(
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: size.height / 20,
                    width: size.height / 20,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: size.height / 20),
                    SizedBox(
                      height: size.height / 14,
                      width: size.width / 1.2,
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                            hintText: 'search',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                    ),
                    SizedBox(height: size.height / 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_search.text.isNotEmpty) {
                            onSearch();
                          }
                        },
                        child: const Text('Search'),
                      ),
                    ),
                    SizedBox(height: size.height / 10),
                    (showList)
                        ? ListTile(
                            onTap: () {
                              String roomId = chatRoomId(
                                  _auth.currentUser!.displayName!,
                                  userMap['name']);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoom(
                                      chatRoomId: roomId, userMap: userMap),
                                ),
                              );
                            },
                            leading: const Icon(
                              Icons.account_box,
                              color: Colors.black,
                            ),
                            title: Text(
                              userMap['name'],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(userMap['email']),
                          )
                        : Container(),
                  ],
                ),
        ),
      ),
    );
  }
}
