import 'package:flutter/material.dart';

class TextMenssage extends StatelessWidget {
 TextMenssage({super.key, required this.data, required this.mine});
  final Map<String, dynamic> data;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          //se for meu, coloca o avatar na esquerda
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  data["senderName"],
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
                //se for uma imagem, mostra a imagem, se não, mostra o texto
                data["imgUrl"] != null
                    ? Image.network(
                        data["imgUrl"],
                        width: 250,
                      )
                    : Text(
                        data["text"],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(fontSize: 16),
                      ),
                Text(data["time"],
                    style: const TextStyle(fontSize: 9)),
              ],
            ),
          ),
          //se for meu, coloca o avatar na direita
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}