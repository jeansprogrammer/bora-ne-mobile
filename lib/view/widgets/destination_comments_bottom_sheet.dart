import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_comments_controller.dart';
import '../../models/destination_comment.dart';
import 'confirm_delete_comment_dialog.dart';

const String _uidUsuarioAtual = "usuario_teste";
const String _nomeUsuarioAtual = "Usuário Teste";

class CommentsBottomSheet extends StatefulWidget {
  final String destinationId;

  const CommentsBottomSheet({super.key, required this.destinationId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final commentsController =
        Provider.of<CommentsController>(context, listen: false);

    _controller.clear();

    await commentsController.addComment(
      destinationId: widget.destinationId,
      userId: _uidUsuarioAtual,
      userName: _nomeUsuarioAtual,
      message: text,
    );

    if (!mounted) return;
    if (commentsController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(commentsController.errorMessage!)),
      );
    }
  }

  Future<void> _excluirComentario(DestinationComment comentario) async {
    final confirmou = await ConfirmDeleteCommentDialog.show(context);
    if (!confirmou) return;

    if (!mounted) return;
    final commentsController =
        Provider.of<CommentsController>(context, listen: false);

    await commentsController.deleteComment(comentario.id!);

    if (!mounted) return;
    if (commentsController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(commentsController.errorMessage!)),
      );
    }
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) return '';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final commentsController = context.watch<CommentsController>();

    return Container(
      height: MediaQuery.of(context).size.height * .50,
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF1B81A),
            ),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<List<DestinationComment>>(
              stream: commentsController.getComments(widget.destinationId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Não foi possível carregar os comentários.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                final comentarios = snapshot.data!;

                if (comentarios.isEmpty) {
                  return const Center(child: Text("Nenhum comentário ainda."));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: comentarios.length,
                  itemBuilder: (_, index) {
                    final comentario = comentarios[index];
                    final ehAutor = comentario.userId == _uidUsuarioAtual;

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                      title: Text(
                        comentario.userName.isNotEmpty
                            ? comentario.userName
                            : "Usuário",
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comentario.message,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatarDataHora(comentario.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: ehAutor
                          ? PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.black,
                              ),
                              onSelected: (value) {
                                if (value == 'excluir') {
                                  _excluirComentario(comentario);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'excluir',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          color: Colors.black),
                                      SizedBox(width: 8),
                                      Text('Excluir comentário'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : null,
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
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Digite um comentário...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                icon: commentsController.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.send, color: const Color(0xFFF1B81A)),
                onPressed: commentsController.isSending ? null : _sendComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
