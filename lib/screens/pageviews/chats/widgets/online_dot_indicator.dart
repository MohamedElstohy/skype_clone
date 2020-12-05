import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({
    @required this.uid
  });
  
  @override
  Widget build(BuildContext context) {
    getColor(int state){
      switch(Utils.numToState(state)){
        case UserState.Offline:
          return Colors.red;
          break;
        case UserState.Online:
          return Colors.green;
          break;
        default:
          return Colors.orange;
          break;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _authMethods.getUserStream(uid: uid),
      builder: (context , snapshot){
        AppUser user;

        if(snapshot.hasData && snapshot.data.data() != null){
          user = AppUser.fromMap(snapshot.data.data());

          return Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.only(top: 8 , right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(user?.state)
            ),
          );
        }
      },
    );
  }
}