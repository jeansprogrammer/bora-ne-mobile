import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/destination_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/controllers/auth_controller.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String destinationId;

  const CommentsBottomSheet({super.key, required this.destinationId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  final DestinationService _service = DestinationService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    print("Entrou no _sendComment");

    final text = _controller.text.trim();

    if (text.isEmpty) {
      print("Mensagem vazia");
      return;
    }

    const uid = "usuario_teste";
    const nome = "Usuário Teste";

    print("UID: $uid");
    print("Nome: $nome");

    print("Vai salvar");

    await _service.addComment(
      destinationId: widget.destinationId,
      userId: uid,
      userName: nome,
      message: text,
    );

    print("Salvou");

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .70,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Comentários",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.getComments(widget.destinationId),
              builder: (context, snapshot) {
                print(snapshot.connectionState);

                if (snapshot.hasError) {
                  print(snapshot.error);
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("Nenhum comentário ainda."));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(data["userName"] ?? "Usuário"),
                      subtitle: Text(data["message"] ?? ""),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Digite um comentário...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                icon: const Icon(Icons.send, color: Colors.orange),
                onPressed: _sendComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
