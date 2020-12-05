import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:skype/constants/strings.dart';
import 'package:skype/models/contact.dart';

import 'package:skype/models/message.dart';
import 'package:skype/models/user.dart';

class ChatMethods{
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  final CollectionReference _messageCollection = _firestore.collection(MESSGES_COLLECTION);
  final CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

  Future<void> addMessageToDb(Message message , AppUser sender , AppUser receiver) async{
    var map = message.toMap();
    await _messageCollection
      .doc(sender.uid)
      .collection(receiver.uid)
      .add(map);

    addToContacts(senderId: message.senderId , receiverId: message.receiverId);
    
    return await _messageCollection
      .doc(receiver.uid)
      .collection(sender.uid)
      .add(map);
  }

  DocumentReference getContactsDocument({String of , String forContact}) =>
    _userCollection
      .doc(of)
      .collection(CONTACTS_COLLECTION)
      .doc(forContact);
  

  addToContacts({String senderId , String receiverId}) async{
    Timestamp currentTime = Timestamp.now();

    await addToSenderContact(senderId , receiverId , currentTime);
    await addToReceiverContact(senderId , receiverId , currentTime);
  }

  Future<void> addToSenderContact(String senderId ,  String receiverId , currentTime) async{
    DocumentSnapshot senderSnapshot = 
      await getContactsDocument(of: senderId , forContact: receiverId).get();
    
    if(!senderSnapshot.exists || senderSnapshot == null){
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime
      );
      
      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId , forContact: receiverId).set(receiverMap);
    }
  }

  Future<void> addToReceiverContact(String senderId ,  String receiverId , currentTime) async{
    DocumentSnapshot receiverSnapshot = 
      await getContactsDocument(of: receiverId , forContact: senderId).get();
    
    if(!receiverSnapshot.exists || receiverSnapshot == null){
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime
      );
      
      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId , forContact: senderId).set(senderMap);
    }
  }

  void setImageMsg(String url , String senderId , String receiverId) async{
    Message _message;

    _message = Message.imageMessage(
       message: "IMAGE",
       senderId: senderId,
       receiverId: receiverId,
       photoUrl: url,
       timestamp: Timestamp.now(),
       type: 'image'
    );

    var map = _message.toImageMap();

    await _firestore
      .collection(MESSGES_COLLECTION)
      .doc(_message.senderId)
      .collection(_message.receiverId)
      .add(map);
    
    await _firestore
      .collection(MESSGES_COLLECTION)
      .doc(_message.receiverId)
      .collection(_message.senderId)
      .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
    .doc(userId)
    .collection(CONTACTS_COLLECTION)
    .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({@required String senderId ,@required String receiverId}) =>
    _messageCollection
    .doc(senderId)
    .collection(receiverId)
    .orderBy('timestamp')
    .snapshots();
}

