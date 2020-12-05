import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/models/user.dart';
import 'package:skype/utils/utilities.dart';

class AuthMethods{
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  final FirebaseAuth _auth = FirebaseAuth.instance; 
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance; 

  static final CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

  Future<User> getCurrentUser() async{
    User _currentUser;
    _currentUser = await _auth.currentUser; 
    return _currentUser;
  }

  Future<AppUser> getUserDetails() async{
    User currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot = await _userCollection.doc(currentUser.uid).get();

    return AppUser.fromMap(documentSnapshot.data());
  }

  Future<AppUser> getUserDetailsById(id) async{
    try{
      DocumentSnapshot documentSnapshot = await  _userCollection.doc(id).get();
      
      return AppUser.fromMap(documentSnapshot.data());
    } catch(e){
      print(e);
      return null;
    }
  }

  Future<User> signin() async{
    GoogleSignInAccount _signinAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signinAuthentication = await _signinAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _signinAuthentication.accessToken,
      idToken: _signinAuthentication.idToken
    );

    User user = (await _auth.signInWithCredential(credential)).user;

    return user; 
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await firestore
      .collection(USERS_COLLECTION)
      .where(EMAIL_FIELD, isEqualTo: user.email)
      .get();
    
    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async{
    String username = Utils.getUsername(currentUser.email);

    AppUser user = AppUser(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoURL,
      username: username
    );

    firestore
      .collection(USERS_COLLECTION)
      .doc(currentUser.uid)
      .set(user.toMap(user));
  }

  Future<List<AppUser>> fetchAllUsers(User currentUser) async{
    List<AppUser> usersList = List<AppUser>();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(USERS_COLLECTION).get();

    for(var i = 0 ; i < querySnapshot.docs.length ; i++){
      if(querySnapshot.docs[i].id != currentUser.uid){
        usersList.add(AppUser.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return usersList;
  }

  Future<bool> signOut() async{
    try{
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();

      return true;
    } catch(e){
      return false;
    }
  }

  void setUserState({@required String userId , @required UserState userState}){
    int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({
      "state": stateNum
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) => _userCollection.doc(uid).snapshots();
}