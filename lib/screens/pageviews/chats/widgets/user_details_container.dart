import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skype/models/user.dart';

import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';

import 'package:skype/screens/chatscreens/widgets/cashed_image.dart';
import 'package:skype/screens/pageviews/chats/widgets/shimmering_logo.dart';
import 'package:skype/widgets/appbar.dart';

import 'package:skype/screens/login_screent.dart';

class UserDetailsContainer extends StatelessWidget {
  signOut(context) async{
    final bool isLoggedOut = await AuthMethods().signOut();

    if(isLoggedOut){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen()
        ),
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: [
          CustomAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: ShimmeringLogo(),
            actions: <Widget>[
              FlatButton(
                onPressed: () => signOut(context),
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white , fontSize: 12),
                ),
              ),
            ],
          ),

          UserDetailsBody(),
        ],
      ),
    );
  }
}


class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final AppUser user = userProvider.getUser;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 , vertical: 20),
      child: Row(
        children: [
          CachedImage(
            user.profilePhoto,
            isRound: true,
            radius: 50,
          ),

          SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18
                ),
              ),

              SizedBox(height: 10),

              Text(
                user.email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}