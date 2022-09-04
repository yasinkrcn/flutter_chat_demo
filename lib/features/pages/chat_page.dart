import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/core/shared_widgets/app_text_form_field.dart';
import 'package:flutter_chat_demo/core/shared_widgets/remove_focus_and_bottom_top_padding_container.dart';
import 'package:flutter_chat_demo/features/models/_models_exports.dart';
import 'package:flutter_chat_demo/features/providers/chat_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/shared_widgets/loading_view.dart';
import '../providers/auth_provider.dart';
import '_pages_exports.dart';

class ChatPage extends StatefulWidget {
  final ChatPageArguments? arguments;
  const ChatPage({Key? key, this.arguments}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments({required this.peerId, required this.peerAvatar, required this.peerNickname});
}

class ChatPageState extends State<ChatPage> {
  late String currentUserId;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";
  File? imageFile;
  bool isLoading = false;
  String imageUrl = "";
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    String peerId = widget.arguments!.peerId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId, widget.arguments!.peerId);
      listScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorHelper.greyColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorHelper.backgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.arguments!.peerAvatar,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              widget.arguments!.peerNickname,
              style: const TextStyle(color: ColorHelper.secondaryColor, fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: ColorHelper.secondaryColor,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: AppContainer(
          child: Stack(
            children: [
              Column(
                children: [
                  // List of messages
                  buildListMessage(),

                  // Input content
                  buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                      color: ColorHelper.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: ColorHelper.white, fontSize: 16),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          DateFormat('kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(messageChat.timestamp),
                            ),
                          ),
                          style: const TextStyle(color: ColorHelper.white, fontSize: 10),
                        ),
                      ],
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    // Image
                    ? Container(
                        margin: const EdgeInsets.all(8),
                        height: 228,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorHelper.primaryColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(3),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(
                                        url: messageChat.content,
                                      ),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder:
                                        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: ColorHelper.greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: ColorHelper.themeColor,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, object, stackTrace) {
                                      return Material(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.asset(
                                          'images/img_not_available.jpeg',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8, bottom: 2),
                              child: Text(
                                DateFormat('kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(messageChat.timestamp),
                                  ),
                                ),
                                style: const TextStyle(color: ColorHelper.white, fontSize: 10),
                              ),
                            )
                          ],
                        ),
                      )
                    : const SizedBox.shrink()
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  //left message uı
                  messageChat.type == TypeMessage.text
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration:
                              BoxDecoration(color: ColorHelper.secondaryColor, borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(left: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                messageChat.content,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                DateFormat('kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(messageChat.timestamp),
                                  ),
                                ),
                                style: const TextStyle(color: ColorHelper.white, fontSize: 10),
                              ),
                            ],
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: const EdgeInsets.only(left: 3),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(url: messageChat.content),
                                    ),
                                  );
                                },
                                child: Material(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        messageChat.content,
                                        loadingBuilder:
                                            (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: ColorHelper.greyColor2,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            width: 200,
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: ColorHelper.themeColor,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, object, stackTrace) => Material(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.asset(
                                            'images/img_not_available.jpeg',
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 185,
                                        left: 170,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              stops: const [
                                                0.5,
                                                0.4,
                                              ],
                                              colors: [
                                                Colors.black.withOpacity(.2),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            DateFormat('kk:mm').format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(messageChat.timestamp),
                                              ),
                                            ),
                                            style: const TextStyle(color: ColorHelper.white, fontSize: 11),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: null},
    );
    Navigator.pop(context);

    return Future.value(false);
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const LoadingView() : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorHelper.backgroundColor, width: 0.5)),
          color: ColorHelper.backgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Edit text
          AppTextFormField.chat(
            hintText: 'Type your message...',
            controller: textEditingController,
            suffixIcon: IconButton(
              // Button send image
              icon: const Icon(Icons.image),
              onPressed: getImage,
              color: ColorHelper.primaryColor,
            ),
          ),

          // Button send message
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              child: const CircleAvatar(
                backgroundColor: ColorHelper.primaryColor,
                child: Icon(
                  Icons.send,
                  color: ColorHelper.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(child: Text("No message here yet..."));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorHelper.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: ColorHelper.themeColor,
              ),
            ),
    );
  }
}
