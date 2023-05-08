import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextChat extends StatefulWidget {
  const TextChat({
    Key? key,
    this.send,
  }) : super(key: key);

  final Function({String? text, File? imgpicker})? send;

  @override
  State<TextChat> createState() => _TextChatState();
}

class _TextChatState extends State<TextChat> {
  bool write = false;
  TextEditingController writecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
              onPressed: () async {
                final XFile? imgpicker = (await ImagePicker().pickImage(source: ImageSource.camera));
                if (imgpicker == null) {
                  return;
                }
              },
              icon: const Icon(
                Icons.camera_alt,
              )),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: writecontroller,
              onChanged: (value) {
                setState(() {
                  write = value.isNotEmpty;
                });
              },
              onSubmitted: (value) {
                widget.send!(text: value);
                writecontroller.clear();
                reset();
              },
              decoration: const InputDecoration.collapsed(
                hintText: "Send a message",
              ),
            ),
          )),
          IconButton(
              onPressed: write
                  ? () {
                      widget.send!(text: writecontroller.text);
                      writecontroller.clear();
                      reset();
                    }
                  : null,
              icon: const Icon(Icons.send)),
        ],
      ),
    );
  }

  void reset() {
    setState(() {
      write = false;
    });
  }
}
