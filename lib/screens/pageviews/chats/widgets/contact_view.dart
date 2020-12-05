import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skype/models/contact.dart';
import 'package:skype/models/user.dart';

import 'package:skype/provider/user_provider.dart';

import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/chat_methods.dart';

import 'package:skype/screens/chatscreens/widgets/cashed_image.dart';
import 'package:skype/screens/pageviews/chats/widgets/last_message_container.dart';
import 'package:skype/screens/pageviews/chats/widgets/online_dot_indicator.dart';
import 'package:skype/widgets/custom_tile.dart';

import 'package:skype/screens/chatscreens/chat_screen.dart';



class ContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context , snapshot){
        if(snapshot.hasData){
          AppUser user = snapshot.data;

          return ViewLayout(contact: user,);
        }
        return Center(child: CircularProgressIndicator(),);
      },
    );
  }
}



class ViewLayout extends StatelessWidget {
  final AppUser contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({@required this.contact});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
     
    return CustomTile(
      mini: false,

      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(receiver: contact)
        )
      ),

      title: Text(
        contact?.name ?? "..",
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontFamily: "Arial"
        ),
      ),

      subTitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userProvider.getUser.uid,
          receiverId: contact.uid
        ),
      ),

      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: [
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true
            ),

            OnlineDotIndicator(uid: contact.uid),
          ],
        ),
      ),
    );
  }
}