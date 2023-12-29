import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/dilog.dart';
import 'package:chat_app/helper/timesetup.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/modles/chatuser.dart';
import 'package:chat_app/modles/message.dart';
import 'package:chat_app/screen/auth_screen/chatscreen.dart';
import 'package:chat_app/widgets/profile_dialog.dart';
import 'package:flutter/material.dart';
//chat user card
class chat_user extends StatefulWidget {
  final ChatUser user;
  const chat_user({super.key, required this.user});

  @override
  State<chat_user> createState() => _chat_userState();
}

class _chat_userState extends State<chat_user> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    mq =MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*.03,vertical:3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: InkWell(
        onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder:(_) =>ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
        stream: apis.getlastMessages(widget.user),
        builder: (context, snapshot) {
          final data=snapshot.data?.docs;
          final list =
              data?.map((e) => Message.fromJson(e.data())).toList()??[];
          if(data!= null && data.first.exists){
            _message =Message.fromJson(data.first.data());
          }

          return ListTile(

            leading: InkWell(onTap: (){
            showDialog(context: context, builder: (_)=>
            ProfileDialog(user: widget.user));
          },

            child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child:
                CachedNetworkImage(
                  imageUrl: widget.user.image,
                  width: mq.height * .05,
                  height: mq.height * .05,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ))),
            title: Text(widget.user.name, maxLines: 1,),
            subtitle: Text(_message!=null ?
                _message!.type== Type.image?
                    'image'
            : _message!.msg

                : widget.user.about),
            // trailing: Text('1.11',//widget.user.lastActivity,
            //   style: TextStyle(color: Colors.black54),),
            trailing: _message == null?null :
            _message!.read.isEmpty && _message!.fromId!= apis.user.uid?
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                  color: Colors.greenAccent.shade700,
                  borderRadius: BorderRadius.circular(10)
              ),
            ):Text(MyDateUtil.getLastMessageTime(context: context,
                time: _message!.sent),
              style: TextStyle(color: Colors.black54),),
          );
        }
    ),
      )

    );
  }
}
