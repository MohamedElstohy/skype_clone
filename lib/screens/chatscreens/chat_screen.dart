import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:skype/constants/strings.dart';
import 'package:skype/enum/view_state.dart';

import 'package:skype/models/message.dart';
import 'package:skype/models/user.dart';

import 'package:skype/provider/image_upload_provider.dart';

import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/resources/storage_methods.dart';

import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/chatscreens/widgets/cashed_image.dart';

import 'package:skype/utils/call_utilities.dart';
import 'package:skype/utils/permissions.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/utils/utilities.dart';

import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/custom_tile.dart';

 class ChatScreen extends StatefulWidget { 
   final AppUser receiver;

   ChatScreen({this.receiver});

   @override
   _ChatScreenState createState() => _ChatScreenState();
 }
 
 class _ChatScreenState extends State<ChatScreen> {
   TextEditingController textFieldController = TextEditingController();
   AuthMethods _authMethods = AuthMethods();
   ChatMethods _chatMethods = ChatMethods();
   StorageMethods _storageMethods = StorageMethods();

   ScrollController _listScrollController = ScrollController();
   ImageUploadProvider _imageUploadProvider; 

   AppUser sender;
   String _currentUserId;

   FocusNode textFieldFocus = FocusNode();

   bool isWriting = false;
   bool showEmojiPicker = false;

   @override
   void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user){
      _currentUserId = user.uid;

      setState(() {
        sender = AppUser(
          uid: user.uid,
          name: user.displayName, 
          profilePhoto: user.photoURL,
        );
      });
    });
  }

  showKeyoard() => textFieldFocus.requestFocus();

  hideKeyoard() => textFieldFocus.unfocus();

  hideEmojiContainer(){
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer(){
    setState(() {
      showEmojiPicker = true;
    });
  }

   @override
   Widget build(BuildContext context) {
     _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    
     return PickupLayout(
       scaffold: Scaffold(
         backgroundColor: UniversalVariables.blackColor,

         appBar: customAppBar(context),

         body: Column(
           children: [
             Flexible(
               child: messageList(),
             ),

             _imageUploadProvider.getViewState == ViewState.LOADING 
                ? Container(
                    margin: EdgeInsets.only(right: 15),
                    alignment: Alignment.centerRight,
                    child: CircularProgressIndicator(),
                  ) 
                : Container() ,

             chatControls(),

             showEmojiPicker ? Container(child: emojiContainer(),) : Container(),
           ],
         ),
       ),
     );
   }

   emojiContainer(){
     return EmojiPicker(
       bgColor: UniversalVariables.separatorColor,
       indicatorColor: UniversalVariables.blueColor,
       rows: 3,
       columns: 7,
       onEmojiSelected: (emoji , category){
         setState(() {
           isWriting = true;
         });

         textFieldController.text = textFieldController.text + emoji.emoji;
       },
       recommendKeywords: ["face","happy","party","sad"],
       numRecommended: 50,
     );
   }

   Widget messageList(){
     return StreamBuilder(
       stream: FirebaseFirestore.instance
        .collection(MESSGES_COLLECTION)
        .doc(_currentUserId)
        .collection(widget.receiver.uid)
        .orderBy(TIMESTAMP_FIELD, descending: true)
        .snapshots(),

       builder: (context , AsyncSnapshot<QuerySnapshot> snapshot){
         if(snapshot.data == null){
           return Center(child: CircularProgressIndicator(),);
         }

        //  SchedulerBinding.instance.addPostFrameCallback((_){
        //    _listScrollController.animateTo( 
        //      _listScrollController.position.minScrollExtent , 
        //      duration: Duration(milliseconds: 250),
        //      curve: Curves.easeInOut,
        //    );
        //  });

         return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data.docs.length,
            reverse: true,
            controller: _listScrollController,
            itemBuilder: (context , index){
              snapshot.data.docs.reversed;
                return chatMessageItem(snapshot.data.docs[index]);
            },
         );
       },
     );
   }

   Widget chatMessageItem(DocumentSnapshot snapshot){
     Message _message = Message.fromMap(snapshot.data());

     return Container(
       alignment: _message.senderId == _currentUserId ? Alignment.centerRight : Alignment.centerLeft, 
       margin: EdgeInsets.symmetric(vertical: 10),
       child: Container(
         child: _message.senderId == _currentUserId ? senderLayout(_message) : reciverLayout(_message),
       ),
     );
   }

   Widget senderLayout(Message message){
     Radius messageRadius = Radius.circular(10);
     
     return Container(
       margin: EdgeInsets.only(top: 12),
       constraints: BoxConstraints(
         maxWidth: MediaQuery.of(context).size.width * 0.65,
       ),
       decoration: BoxDecoration(
          color: UniversalVariables.senderColor,
          borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius
          ),
       ),
       child: Padding(
         padding: EdgeInsets.all(10),
         child: getMessage(message),
       ),
     );
   }

   getMessage(Message message){
     return message.type != MESSAGE_TYPE_IMAGE  
      ? Text(
          message.message ,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16
          ),
        ) 
      : message.photoUrl != null 
          ? CachedImage(
            message.photoUrl,
            height: 250,
            width: 250,
            radius: 10,
          ) 
          : Text("Url was null");
   }

   Widget reciverLayout(Message message){
    Radius messageRadius = Radius.circular(10);
    
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65
      ),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message)
      ),
    );
   }

   Widget chatControls(){
     setWritingTo(bool value){
       setState(() {
         isWriting = value;
       });
     }
     
     addMediaModel(context){
       showModalBottomSheet(
         context: context,
         elevation: 0,
         backgroundColor: UniversalVariables.blackColor, 
         builder: (context){
           return Column(
             children: [
               Container(
                 padding: EdgeInsets.symmetric(vertical: 15),
                 child: Row(
                   children: [
                     FlatButton(
                       onPressed: () => Navigator.maybePop(context), 
                       child: Icon(Icons.close )
                     ),

                     Expanded(
                       child: Align(
                         alignment: Alignment.centerLeft,
                         child: Text(
                           "Content and tools",
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 20,
                             fontWeight: FontWeight.bold 
                           ),
                         ),
                       )
                     ),
                   ],
                 ),
               ),

               Flexible(
                 child: ListView(
                   children: [
                      ModalTile(
                        title: "Media",
                        subTitle: "Share Photos and Videos",
                        icon: Icons.image,
                        onTap: () {
                          pickImage(source: ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),

                      ModalTile(
                        title: "File",
                        subTitle: "Share files",
                        icon: Icons.tab,
                        onTap: (){},
                      ),

                      ModalTile(
                        title: "Contact",
                        subTitle: "Share contacts",
                        icon: Icons.contacts,
                        onTap: (){},
                      ),

                      ModalTile(
                        title: "Location",
                        subTitle: "Share location",
                        icon: Icons.add_location,
                        onTap: (){},
                      ),

                      ModalTile(
                        title: "Schedule Call",
                        subTitle: "Arrange a skype call and get reminders",
                        icon: Icons.schedule,
                        onTap: (){},
                      ),

                      ModalTile(
                        title: "Create Poll",
                        subTitle: "Share Pols",
                        icon: Icons.poll,
                        onTap: (){},
                      ),
                   ],
                 )
               ),
             ],
           );
         }
       );
     }

     return Container(
       padding: EdgeInsets.all(10),
       child: Row(
         children: [
           GestureDetector(
             onTap: () => addMediaModel(context),
             child: Container(
               padding: EdgeInsets.all(5),
               decoration: BoxDecoration(
                 gradient: UniversalVariables.fabGradient,
                 shape: BoxShape.circle
               ),
               child: Icon(Icons.add),
             ),
           ),

           SizedBox(width: 5,),

           Expanded(
            child: Stack(
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white, 
                  ),
                  onChanged: (val){
                    (val.length > 0 && val.trim() != "")  
                      ? setWritingTo(true) 
                      : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(50 )
                      ),
                      borderSide: BorderSide.none 
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20 , vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: (){
                        if(!showEmojiPicker){
                          hideKeyoard();
                          showEmojiContainer();
                        } 
                        else {
                          showKeyoard();
                          hideEmojiContainer();
                        }
                      },
                      icon: Icon(Icons.face),
                    ),
                  ],
                ),
              
              ],
            )
           ),

           isWriting 
              ? Container() 
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.record_voice_over),
              ),

           isWriting 
              ? Container() 
              : GestureDetector(
                  child: Icon(Icons.camera_alt),
                  onTap: () => pickImage(source: ImageSource.camera),
                ),

           isWriting 
            ? Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send, 
                  size: 15,
                ),
                onPressed: () => sendMessage(),
              ),
            ) 
            : Container(),
         ],
       ),
     );
   }

   sendMessage(){
     var text = textFieldController.text;
     Message message = Message(
       receiverId: widget.receiver.uid,
       senderId: sender.uid,
       message: text,
       timestamp: Timestamp.now(),
       type: 'text'
     );

     setState(() {
       isWriting = false;
     });

     textFieldController.text = "";

     _chatMethods.addMessageToDb(message , sender , widget.receiver); 
   }

   void pickImage({@required ImageSource source}) async{
     File selectedImage = await Utils.pickImage(source: source);
     _storageMethods.uploadImage(
       image: selectedImage,
       senderId: _currentUserId,
       receiverId: widget.receiver.uid,
       imageUploadProvider: _imageUploadProvider
     );
   }

   CustomAppBar customAppBar(context){
     return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        widget.receiver.name
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.video_call),
          onPressed: () async => await Permissions.cameraAndMicrophonePermissionsGranted() 
            ? CallUtils.dial(
              from: sender,
              to: widget.receiver,
              context: context
            )
            : {},
        ),

        IconButton(
          icon: Icon(Icons.phone),
          onPressed: (){},
        ),
      ],
     );
   }
 }


 class ModalTile extends StatelessWidget { 
   final String title;
   final String subTitle;
   final IconData icon;
   final Function onTap;

   const ModalTile({
     @required this.title,
     @required this.subTitle,
     @required this.icon,
     @required this.onTap
   });

   @override
   Widget build(BuildContext context) {
     return Padding(
       padding: EdgeInsets.symmetric(horizontal: 15),
       child: CustomTile(
         mini: false,
         onTap: onTap,
         leading: Container(
           margin: EdgeInsets.only(right: 10),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(15),
             color: UniversalVariables.receiverColor
           ),
           padding: EdgeInsets.all(10),
           child: Icon(
             icon,
             size: 38,
           ),
         ), 
         subTitle: Text(
           subTitle,
           style: TextStyle(
             fontSize: 14,
             color: UniversalVariables.greyColor
           ),
         ),
         title: Text(
           title,
           style: TextStyle(
             fontWeight: FontWeight.bold,
             color: Colors.white,
             fontSize: 18
           ),
         ), 
       ),
     );
   }
 }