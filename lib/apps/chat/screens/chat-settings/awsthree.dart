// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:aws_s3/aws_s3.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "AWS S3 file upload demo",
//       home: Scaffold(body: CreateMessage()),
//     );
//   }
// }

// class CreateMessage extends StatefulWidget {
//   @override
//   CreateMessageState createState() => CreateMessageState();
// }

// class CreateMessageState extends State<CreateMessage> {
//   final formKey = new GlobalKey<FormState>();
//   final TextEditingController _textController1 = new TextEditingController();
//   final TextEditingController _textController2 = new TextEditingController();

//   //To hold image paths after uploading to s3 for adding to db
//   File selectedFile;

//   //to ensure image is uploading from the native android
//   bool isFileUploading = false;

//   String poolId;
//   String awsFolderPath;
//   String bucketName;

//   @override
//   void initState() {
//     super.initState();
//     readEnv();
//   }

//   void readEnv() async {
//     final str = await rootBundle.loadString(".env");
//     if (str.isNotEmpty) {
//       final decoded = jsonDecode(str);
//       poolId = decoded["poolId"];
//       awsFolderPath = decoded["awsFolderPath"];
//       bucketName = decoded["bucketName"];
//     }
//   }

//   // Pick image
//   pickerModal(ctx) {
//     showModalBottomSheet<void>(context: context, builder: _bottomSheetBuilder);
//   }

//   Widget _bottomSheetBuilder(BuildContext context) {
//     return new Container(
//       height: 260.0,
//       child: new Padding(
//         padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
//         child: new Column(
//           children: <Widget>[
//             _renderBottomMenuItem(Icons.image, "Gallery photo",
//                 type: FileType.image),
//             new Divider(
//               height: 2.0,
//             ),
//             _renderBottomMenuItem(Icons.video_label, "Video",
//                 type: FileType.video),
//           ],
//         ),
//       ),
//     );
//   }

//   _renderBottomMenuItem(icon, title, {FileType type}) {
//     var item = new Container(
//       height: 60.0,
//       child: Row(
//         children: <Widget>[
//           new Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: new Icon(icon,
//                   size: 40.0, color: Theme.of(context).primaryColorLight)),
//           new Center(
//               child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 8.0, horizontal: 20.0),
//                   child: new Text(
//                     title,
//                     style: new TextStyle(
//                         fontSize: 22.0, fontStyle: FontStyle.normal),
//                   ))),
//         ],
//       ),
//     );
//     return new InkWell(
//       child: item,
//       onTap: () async {
//         Navigator.of(context).pop();

//         if (type == FileType.video) {
//           // selectedFile =
//           //     await FilePicker.platform.pickFiles(type: FileType.video);

//           FilePickerResult result =
//               await FilePicker.platform.pickFiles(type: FileType.video);
//           if (result != null) {
//             selectedFile = File(result.files.single.path);
//           }
//         } else if (type == FileType.image) {
//           FilePickerResult result =
//               await FilePicker.platform.pickFiles(type: FileType.image);
//           if (result != null) {
//             selectedFile = File(result.files.single.path);
//           }
//         }
//       },
//     );
//   }

//   Widget buildGridView(BuildContext context) {
//     return Wrap(
//       children: List.generate(2, (index) {
//         var content;
//         if (index == 0) {
//           // Add picture button
//           var addCell = InkWell(
//             onTap: () => pickerModal(context),
//             child: Container(
//               width: 70,
//               height: 72,
//               child: Icon(
//                 Icons.add,
//                 size: 50.0,
//                 color: Theme.of(context).primaryColorLight,
//               ),
//             ),
//           );
//           content = addCell;
//         } else {
//           // Selected image
//           content = Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFECECEC),
//               border: Border.all(color: Colors.transparent),
//             ),
//             child: (selectedFile != null)
//                 ? Image.file(
//                     selectedFile,
//                     fit: BoxFit.cover,
//                     width: 70.0,
//                     height: 70.0,
//                   )
//                 : SizedBox(),
//           );
//         }
//         return new Container(
//           margin: const EdgeInsets.all(2.0),
//           color: const Color(0xFFECECEC),
//           child: content,
//         );
//       }),
//     );
//   }

//   Widget deleteActionIconWidget(Function action) {
//     return FloatingActionButton(
//       child: Icon(
//         Icons.delete,
//         color: Colors.redAccent,
//       ),
//       onPressed: action,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: new Text(
//           "Compose",
//           style: TextStyle(
//             color: Theme.of(context).primaryColor,
//             fontSize: 21.0,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
//         child: SingleChildScrollView(
//           child: Form(
//             key: formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                   padding:
//                       const EdgeInsets.only(left: 13.0, right: 13.0, top: 15.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Container(child: Text("To:")),
//                       Container(width: 5.0),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.only(left: 13.0, right: 13.0, top: 15.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         "Subject " + "*",
//                         style: TextStyle(color: Colors.black87, fontSize: 14.0),
//                       ),
//                       TextFormField(
//                           controller: _textController1,
//                           validator: (String text) {
//                             if (text.length == 0)
//                               return "Title cannot be empty";
//                             else
//                               return null;
//                           },
//                           decoration: InputDecoration(
//                               hintText: "Subject",
//                               border: OutlineInputBorder(),
//                               hintStyle: TextStyle(
//                                   color: Colors.black, fontSize: 11.0))),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.only(left: 13.0, right: 13.0, top: 15.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         "Message *",
//                         style: TextStyle(color: Colors.black87, fontSize: 14.0),
//                       ),
//                       TextFormField(
//                           controller: _textController2,
//                           maxLines: 10,
//                           validator: (String text) {
//                             if (text.length == 0)
//                               return "Type a message";
//                             else
//                               return null;
//                           },
//                           decoration: InputDecoration(
//                               hintText: "Type your message here...",
//                               border: OutlineInputBorder(),
//                               hintStyle: TextStyle(
//                                   color: Colors.black87, fontSize: 11.0))),
//                     ],
//                   ),
//                 ),
//                 new Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10.0, vertical: 5.0),
//                   child: new Builder(
//                     builder: (ctx) {
//                       return buildGridView(context);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(
//           Icons.send,
//           color: Colors.white,
//         ),
//         onPressed: submitMessage,
//       ),
//     );
//   }

//   Future<String> _uploadImage(File file, int number,
//       {String extension = 'jpg'}) async {
//     String result;

//     if (result == null) {
//       // generating file name
//       String fileName =
//           "$number$extension\_${DateTime.now().millisecondsSinceEpoch}.$extension";

//       AwsS3 awsS3 = AwsS3(
//           awsFolderPath: awsFolderPath,
//           file: selectedFile,
//           fileNameWithExt: fileName,
//           poolId: poolId,
//           region: Regions.AP_SOUTHEAST_2,
//           bucketName: bucketName);
//       print('this is awsS3');
//       print(awsS3);
//        print(awsFolderPath);

//       setState(() => isFileUploading = true);
//       displayUploadDialog(awsS3);
//       try {
//         try {
//           result = await awsS3.uploadFile;
//           debugPrint("Result :'$result'.");
//         } on PlatformException {
//           debugPrint("Result :'$result'.");
//         }
//       } on PlatformException catch (e) {
//         debugPrint("Failed :'${e.message}'.");
//       }
//     }
//     Navigator.of(context).pop();
//     return result;
//   }

//   Future displayUploadDialog(AwsS3 awsS3) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => StreamBuilder(
//         stream: awsS3.getUploadStatus,
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           return buildFileUploadDialog(snapshot, context);
//         },
//       ),
//     );
//   }

//   AlertDialog buildFileUploadDialog(
//       AsyncSnapshot snapshot, BuildContext context) {
//     return AlertDialog(
//       title: Container(
//         padding: EdgeInsets.all(6),
//         child: LinearProgressIndicator(
//           value: (snapshot.data != null) ? snapshot.data / 100 : 0,
//           valueColor:
//               AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark),
//         ),
//       ),
//       content: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 6),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(child: Text('Uploading...')),
//             Text("${snapshot.data ?? 0}%"),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> submitMessage() async {
//     await _uploadImage(selectedFile, 1);

//     debugPrint("Subject: " + _textController1.text);
//     debugPrint("Message: " + _textController2.text);
//   }
// }
