import 'package:chat_app/helper/dilog.dart';
import 'package:chat_app/helper/timesetup.dart';
import 'package:chat_app/modles/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class messagecard extends StatefulWidget {
  const messagecard({super.key, required this.message});
  final Message message;
  @override
  State<messagecard> createState() => _messagecardState();
}

class _messagecardState extends State<messagecard> {
  @override
  Widget build(BuildContext context) {
    //bool isMe = apis.user.uid==widget.message.
    bool isMe = apis.user.uid == widget.message.fromId;
       return InkWell(
           onLongPress: () {
          //   _showBottomSheet(isMe,context);
           },
           child: isMe ? _greenmessage():
    _bluemessage()
       );
  }

  Widget _bluemessage(){
    if(widget.message.read.isEmpty){
      apis.updateMessageReadStatus(widget.message);
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Expanded(child:
      Container(
      padding: EdgeInsets.all(mq.width*.04),
      margin: EdgeInsets.symmetric(
      horizontal: mq.width *.04,vertical: mq.height*0.1
      ),
      decoration: BoxDecoration(color:
      Color.fromARGB(255,221,245,255),
        border:Border.all(color: Colors.lightBlue),
        borderRadius: BorderRadius.only(topRight: Radius.circular(30),
        topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30)
        )
      ),
      
      child:Text(MyDateUtil.getFormattedTime(context:
      context, time: widget.message.sent), style:
      TextStyle(fontSize: 13,color: Colors.black54),
      ),
    )),
      Padding(padding:EdgeInsets.only(right: mq.width*.04),
    child: Text(widget.message.sent, style:
        TextStyle(fontSize: 13,color: Colors.black54),
      ),
      )]);
  }

  Widget _greenmessage(){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
Row(children:[
  SizedBox(width: mq.width *.04),
         // Padding(padding:EdgeInsets.only(left: mq.width*.04),
  if(widget.message.read.isNotEmpty)
  Icon(Icons.done_all_rounded, color: Colors.blue,size: 20,),
           SizedBox(width: 2,),
            Text(MyDateUtil.getFormattedTime(context:
                context, time: widget.message.sent), style:
            TextStyle(fontSize: 13,color: Colors.black54),
            ),
          ]),
          Expanded(child:
          Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width *.04,vertical: mq.height*0.1
            ),
            decoration: BoxDecoration(color:
            Color.fromARGB(255,218,255,176),
                border:Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)
                )
            ),

            child: Text(widget.message.msg, style:
            TextStyle(fontSize: 14, color: Colors.black87),),
          )),
        ]);
  }
}

// void _showBottomSheet(bool isMe,BuildContext context) {
//   showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//       builder: (BuildContext context) {
//         return ListView(
//           shrinkWrap: true,
//           children: [
//             //black divider
//             Container(
//               height: 4,
//               margin: EdgeInsets.symmetric(
//                   vertical: mq.height * .015, horizontal: mq.width * .4),
//               decoration: BoxDecoration(
//                   color: Colors.grey, borderRadius: BorderRadius.circular(8)),
//             ),
//
//             widget.message.type == Type.text
//                 ?
//             //copy option
//             _OptionItem(
//                 icon: const Icon(Icons.copy_all_rounded,
//                     color: Colors.blue, size: 26),
//                 name: 'Copy Text',
//                 onTap: () async {
//                   await Clipboard.setData(
//                       ClipboardData(text: widget.message.msg))
//                       .then((value) {
//                     //for hiding bottom sheet
//                     Navigator.pop(context);
//
//                     dilog.showSnackbar(context, 'Text Copied!');
//                   });
//                 })
//                 :
//             //save option
//             _OptionItem(
//                 icon: const Icon(Icons.download_rounded,
//                     color: Colors.blue, size: 26),
//                 name: 'Save Image',
//                 onTap: () async {
//                   try {
//                     print('Image Url: ${widget.message.msg}');
//                     await GallerySaver.saveImage(widget.message.msg,
//                         albumName: 'Chat App')
//                         .then((success) {
//                       //for hiding bottom sheet
//                       Navigator.pop(context);
//                       if (success != null && success) {
//                         dilog.showSnackbar(
//                             context, 'Image Successfully Saved!');
//                       }
//                     });
//                   } catch (e) {
//                     print('ErrorWhileSavingImg: $e');
//                   }
//                 }),
//
//             //separator or divider
//             if (isMe)
//               Divider(
//                 color: Colors.black54,
//                 endIndent: mq.width * .04,
//                 indent: mq.width * .04,
//               ),
//
//             //edit option
//             if (widget.message.type == Type.text && isMe)
//               _OptionItem(
//                   icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
//                   name: 'Edit Message',
//                   onTap: () {
//                     //for hiding bottom sheet
//                     Navigator.pop(context);
//
//                     _showMessageUpdateDialog();
//                   }),
//
//             //delete option
//             if (isMe)
//               _OptionItem(
//                   icon: const Icon(Icons.delete_forever,
//                       color: Colors.red, size: 26),
//                   name: 'Delete Message',
//                   onTap: () async {
//                     await apis.deleteMessage(widget.message).then((value) {
//                       //for hiding bottom sheet
//                       Navigator.pop(context);
//                     });
//                   }),
//
//             //separator or divider
//             Divider(
//               color: Colors.black54,
//               endIndent: mq.width * .04,
//               indent: mq.width * .04,
//             ),
//
//             //sent time
//             _OptionItem(
//                 icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
//                 name:
//                 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
//                 onTap: () {}),
//
//             //read time
//             _OptionItem(
//                 icon: const Icon(Icons.remove_red_eye, color: Colors.green),
//                 name: widget.message.read.isEmpty
//                     ? 'Read At: Not seen yet'
//                     : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
//                 onTap: () {}),
//           ],
//         );
//       });
// }
//
// //dialog for updating message content
// void _showMessageUpdateDialog(BuildContext context) {
//   String updatedMsg = widget.message.msg;
//
//   showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         contentPadding: const EdgeInsets.only(
//             left: 24, right: 24, top: 20, bottom: 10),
//
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20)),
//
//         //title
//         title: Row(
//           children: const [
//             Icon(
//               Icons.message,
//               color: Colors.blue,
//               size: 28,
//             ),
//             Text(' Update Message')
//           ],
//         ),
//
//         //content
//         content: TextFormField(
//           initialValue: updatedMsg,
//           maxLines: null,
//           onChanged: (value) => updatedMsg = value,
//           decoration: InputDecoration(
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15))),
//         ),
//
//         //actions
//         actions: [
//           //cancel button
//           MaterialButton(
//               onPressed: () {
//                 //hide alert dialog
//                // Navigator.pop(context);
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.blue, fontSize: 16),
//               )),
//
//           //update button
//           MaterialButton(
//               onPressed: () {
//                 //hide alert dialog
//                 Navigator.pop(context);
//                 apis.updateMessage(widget.message ,updatedMsg);
//               },
//               child: const Text(
//                 'Update',
//                 style: TextStyle(color: Colors.blue, fontSize: 16),
//               ))
//         ],
//       ));
// }
// }
//
// //custom options card (for copy, edit, delete, etc.)
// class _OptionItem extends StatelessWidget {
//   final Icon icon;
//   final String name;
//   final VoidCallback onTap;
//
//   const _OptionItem(
//       {required this.icon, required this.name, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//         onTap: () => onTap(),
//         child: Padding(
//           padding: EdgeInsets.only(
//               left: mq.width * .05,
//               top: mq.height * .015,
//               bottom: mq.height * .015),
//           child: Row(children: [
//             icon,
//             Flexible(
//                 child: Text('    $name',
//                     style: const TextStyle(
//                         fontSize: 15,
//                         color: Colors.black54,
//                         letterSpacing: 0.5)))
//           ]),
//         ));
//   }
// }
