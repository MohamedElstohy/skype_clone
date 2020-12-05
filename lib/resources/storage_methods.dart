import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:skype/models/user.dart';

import 'package:skype/provider/image_upload_provider.dart';

import 'package:skype/resources/chat_methods.dart';

class StorageMethods{
  static final FirebaseFirestore firestore = FirebaseFirestore.instance; 

  Reference _reference;

  AppUser user = AppUser();

  Future<String> uploadImageToStorage(File image) async{
    try{
      _reference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');

      UploadTask _uploadTask = _reference.putFile(image);

      var url = await _uploadTask.then((snapshot) async{
        return await snapshot.ref.getDownloadURL();
      });

      return url;

    } catch(e){
      print(e);
      return null;
    }
  }

  void uploadImage({
    @required File image,
    @required String senderId,
    @required String receiverId,
    @required ImageUploadProvider imageUploadProvider
  }) async{
    final ChatMethods chatMethods = ChatMethods();
    imageUploadProvider.setToLoading();

    String url = await uploadImageToStorage(image); 

    imageUploadProvider.setToIdle();

    chatMethods.setImageMsg(url , senderId , receiverId);
  }
}