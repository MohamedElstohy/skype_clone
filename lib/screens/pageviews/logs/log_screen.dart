import 'package:flutter/material.dart';

import 'package:skype/utils/universal_variables.dart';

import 'package:skype/screens/pageviews/logs/widgets/floating_column.dart';
import 'package:skype/screens/pageviews/logs/widgets/log_list_container.dart';
import 'package:skype/widgets/skype_appbar.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,

      appBar: SkypeAppBar(
        title: "Calls",
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.pushNamed(context, '/search_screen'); 
            },
          ),
        ],
      ),

      floatingActionButton: FloatingColumn(),

      body: Padding(
        padding: EdgeInsets.only(left: 15),
        child: LogListContainer(),
      ),
    );
  }
}