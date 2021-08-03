import 'dart:io';

import 'package:flutter/material.dart';

typedef OnTap = void Function();

class ListItemWidget extends StatelessWidget {
  final bool selected;
  final String imagePath;
  final Widget title, subtitle;
  final Widget trailing;
  final OnTap onTap;
  final Widget leading;

  ListItemWidget(
      {required this.title,
      required this.subtitle,
      required this.leading,
      required this.imagePath,
      required this.trailing,
      required this.onTap,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: selected ? BoxDecoration(color: Colors.amberAccent) : null,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: (this.leading == null)
                ? CircleAvatar(
                    backgroundImage: AssetImage("assets/cover.jpg"),
                    // backgroundImage: (imagePath == null)
                    // ? Image.asset("assets/cover.jpg")
                    // : FileImage(File(imagePath)),
                  )
                : leading,
            onTap: onTap,
            title: title,
            subtitle: subtitle,
            trailing:
                trailing, //Text("${Utility.parseToMinutesSeconds(int.parse(song.duration))}",
          ),
          Container(
            height: 1.0,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
