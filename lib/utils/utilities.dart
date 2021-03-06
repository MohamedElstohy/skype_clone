import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:skype/enum/user_state.dart';

final ImagePicker _picker = ImagePicker();

class Utils{
  static String getUsername(String email){
    return "live:${email.split('@')[0 ]}";
  }

  static String getInitials(String name){
    List<String> nameSplit = name.split(" "); 
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }
  
  static Future<File> pickImage({@required ImageSource source}) async{
    PickedFile selectedImage = await _picker.getImage(source: source);

    return await compressImage(File(selectedImage.path));
  }

  static Future<File> compressImage(File imageToCompress) async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int random = Random().nextInt(1000);

    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync());
    Im.copyResize(image, width: 500 , height: 500);

    return new File('$path/img_$random.jpg')..writeAsBytesSync(Im.encodeJpg(image , quality: 85));
  }

  static int stateToNum(UserState userState){
    switch(userState){
      case UserState.Offline:
        return 0;
        break;
      case UserState.Online:
        return 1;
        break;
      default:
        return 2;
        break;
    }
  }

  static UserState numToState(int number){
    switch(number){
      case 0:
        return UserState.Offline;
        break;
      case 1:
        return UserState.Online;
        break;
      default:
        return UserState.Waiting;
        break;
    }
  }

  static String formatDateString(String dateString){
    DateTime dateTime = DateTime.parse(dateString);

    var formatter = DateFormat('dd/MM/yy'); 

    return formatter.format(dateTime);
  }
} 