import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';

import 'package:skype/models/log.dart';

import 'package:skype/resources/local_db/repository/log_repository.dart';
import 'package:skype/screens/chatscreens/widgets/cashed_image.dart';

import 'package:skype/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:skype/utils/utilities.dart';
import 'package:skype/widgets/custom_tile.dart';

class LogListContainer extends StatelessWidget {
  getIcon(String callStatus){
    Icon _icon;
    double _iconSize = 15;

    switch(callStatus){
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case CALL_STATUS_MISSED: 
        _icon = Icon(
          Icons.call_missed,
          size: _iconSize,
          color: Colors.red,
        );
        break;

      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
        break;
    }

    return Container(
      margin: EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future:  LogRepository.getLogs(),
      builder: (context , AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.hasData){
          List<dynamic> logList = snapshot.data;

          if(logList.isNotEmpty){
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context , index){
                Log _log = logList[index];
                bool hasDialled = _log.callStatus == CALL_STATUS_DIALLED;

                return CustomTile(
                  leading: CachedImage(
                    hasDialled ? _log.receiverPic : _log.callerPic,
                    isRound: true,
                    radius: 45,
                  ),

                  mini: false,

                  title: Text(
                    hasDialled ? _log.receiverName : _log.callerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  icon:  getIcon(_log.callStatus),
                  subTitle: Text(
                    Utils.formatDateString(_log.timestamp), 
                    style: TextStyle(
                      fontSize: 13,
                    )
                  ),
                );
              },
            );
          }

          return QuietBox(
            heading: "This is where all your call logs are listed",
            subtitle: "Calling people all over the world with just one click",
          );
        }

        return QuietBox(
          heading: "This is where all your call logs are listed",
          subtitle: "Calling people all over the world with just one click",
        );
      },
    );
  }
}