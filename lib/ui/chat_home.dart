import 'dart:io';

import 'package:chat_app/components/message_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/text_card_chat.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
//variaveis

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _currentUser;
  bool isLoading = false;

//funções
//função para chamar o usuario ao iniciar o app
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

//função para pegar o usuario no google
  Future<User?> _getUser() async {
    //se o usuario ja estiver logado
    if (_currentUser != null) return _currentUser;
    //se o usuario nao estiver logado
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      //pegando as credenciais do usuario
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
      //fazendo o login com as credenciais
      final UserCredential userCredential = await auth.signInWithCredential(credential);
      //retornando o usuario logado
      user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  Future<void> sendMessage({String? text, File? imgpicker}) async {
    final User? user = await _getUser();
    //se o usuario nao estiver logado
    if (user == null) {
      showSnackBar();
    }
    //se o usuario estiver logado
    Map<String, dynamic> data = {
      //pegando informações do usuario
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now(),
    };
    //se o usuario enviar uma imagem
    if (imgpicker != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgpicker);

      loading(isLoading);

      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;

      loading(isLoading);
    }
    //se o usuario enviar um texto
    if (text != null) {
      data['text'] = text;
    }
    //enviando as informações para o firebase
    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null ? 'Olá, ${_currentUser!.displayName}' : 'Chat App'),
        centerTitle: true,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Você saiu com sucesso!'),
                    ));
                  },
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('messages').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return TextMenssage(
                        data: documents[index].data() as Map<String, dynamic>,
                        mine: _currentUser != null ? true : false,
                      );
                    },
                  );
              }
            },
          )),
          isLoading ? const LinearProgressIndicator() : Container(),
          TextChat(
            send: sendMessage,
          ),
        ],
      ),
    );
  }

  void loading(bool loading) {
    setState(() {
      loading = !loading;
    });
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Não foi possível fazer o login. Tente novamente.'),
      backgroundColor: Colors.red,
    ));
  }
}
