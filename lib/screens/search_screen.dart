import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/custom_tile.dart';

import 'chatscreens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods _authMethods = AuthMethods();

  List<AppUser> userList;
  String query = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _authMethods.getCurrentUser().then((User user){
      _authMethods.fetchAllUsers(user).then((List<AppUser> list){
        setState(() {
          userList = list;
        });
      });
    });
  }

  searchAppBar(BuildContext context){
    return GradientAppBar(
      gradient: LinearGradient(
        colors: [UniversalVariables.gradientColorStart , UniversalVariables.gradientColorEnd]
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged:  (val){
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close , color: Colors.white),
                onPressed: (){
                  WidgetsBinding.instance
                    .addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0x88ffffff ),
                fontSize: 35
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildSuggetions(String query){
    final List<AppUser> suggestionList = query.isEmpty 
      ? [] 
      : userList.where(
          (AppUser user){
            String _getUsername = user.username.toLowerCase();
            String _query = query.toLowerCase();
            String _getName = user.name.toLowerCase();
            bool matchesUsername = _getUsername.contains(_query);
            bool matchesName = _getName.contains(_query);

            return (matchesUsername || matchesName);
          }
        ).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index){
        AppUser searchedUser = AppUser(
          uid: suggestionList[index].uid,
          profilePhoto: suggestionList[index].profilePhoto,
          name: suggestionList[index].name,
          username: suggestionList[index].username,
        );

        return CustomTile(
          mini: false,
          onTap: (){
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiver: searchedUser
                )
              )
            );
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(searchedUser.profilePhoto),
            backgroundColor: Colors.grey, 
          ), 
          title: Text(
            searchedUser.username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ), 
          subTitle: Text(
            searchedUser.name,
            style: TextStyle(
              color: UniversalVariables.greyColor,
            ),
          )
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,

      appBar:  searchAppBar(context),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggetions(query),
      ),
    );
  }
}