   import 'package:flutter/material.dart';
   import 'package:firebase_database/firebase_database.dart';

   class ChatScreen extends StatefulWidget {
     @override
     _ChatScreenState createState() => _ChatScreenState();
   }

   class _ChatScreenState extends State<ChatScreen> {
     final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('messages');
     final TextEditingController _controller = TextEditingController();
     List<String> _messages = [];

     @override
     void initState() {
       super.initState();
       _messagesRef.onChildAdded.listen((event) {
         setState(() {
           _messages.add(event.snapshot.value.toString());
         });
       });
     }

     void _sendMessage() {
       if (_controller.text.isNotEmpty) {
         _messagesRef.push().set(_controller.text);
         _controller.clear();
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text('Chat')),
         body: Column(
           children: [
             Expanded(
               child: ListView.builder(
                 itemCount: _messages.length,
                 itemBuilder: (context, index) {
                   return ListTile(title: Text(_messages[index]));
                 },
               ),
             ),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _controller,
                       decoration: InputDecoration(hintText: 'Nhập tin nhắn'),
                     ),
                   ),
                   IconButton(
                     icon: Icon(Icons.send),
                     onPressed: _sendMessage,
                   ),
                 ],
               ),
             ),
           ],
         ),
       );
     }
   }