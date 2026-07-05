import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/route_comments_controller.dart';
import '../../models/route_comment.dart';
import 'confirm_delete_comment_dialog.dart';
import 'login_required_view.dart';

class RouteCommentsBottomSheet extends StatefulWidget {
  final String routeId;

  const RouteCommentsBottomSheet({super.key, required this.routeId});

  @override
  State<RouteCommentsBottomSheet> createState() =>
      _RouteCommentsBottomSheetState();
}

class _RouteCommentsBottomSheetState extends State<RouteCommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, String> _nomeAtualCache = {};

  String get _uidUsuarioAtual => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Busca o nome cadastrado na coleção "users" do Firestore (perfil do app),
  // que pode ser diferente do displayName do FirebaseAuth.
  Future<String> _obterNomeUsuario() async {
    final uid = _uidUsuarioAtual;
    if (uid.isEmpty) return 'Usuário';

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final nome = doc.data()?['name'] as String?;
      if (nome != null && nome.isNotEmpty) return nome;
    } catch (_) {}

    return FirebaseAuth.instance.currentUser?.displayName ??
        FirebaseAuth.instance.currentUser?.email ??
        'Usuário';
  }

  // Busca o nome atual do autor do comentário na coleção "users", em vez de
  // confiar apenas no "userName" salvo no comentário (que é só uma cópia do
  // nome no momento em que ele foi escrito e não é atualizada depois).
  Future<String> _resolverNomeAutor(String userId, String userNameSalvo) async {
    final fallback = userNameSalvo.isNotEmpty ? userNameSalvo : 'Usuário';
    if (userId.isEmpty) return fallback;
    if (_nomeAtualCache.containsKey(userId)) return _nomeAtualCache[userId]!;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final nome = doc.data()?['name'] as String?;
      final resultado = (nome != null && nome.isNotEmpty) ? nome : fallback;
      _nomeAtualCache[userId] = resultado;
      return resultado;
    } catch (_) {
      return fallback;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    if (_uidUsuarioAtual.isEmpty) {
      showLoginRequiredSheet(
        context,
        icon: Icons.comment_outlined,
        title: 'Faça login para comentar',
        message: 'Entre na sua conta para deixar seu comentário.',
      );
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final routeCommentsController =
        Provider.of<RouteCommentsController>(context, listen: false);

    _controller.clear();
    final nomeUsuario = await _obterNomeUsuario();

    await routeCommentsController.addComment(
      routeId: widget.routeId,
      userId: _uidUsuarioAtual,
      userName: nomeUsuario,
      message: text,
    );

    if (!mounted) return;
    if (routeCommentsController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(routeCommentsController.errorMessage!)),
      );
    }
  }

  Future<void> _excluirComentario(RouteComment comentario) async {
    final confirmou = await ConfirmDeleteCommentDialog.show(context);
    if (!confirmou) return;

    if (!mounted) return;
    final routeCommentsController =
        Provider.of<RouteCommentsController>(context, listen: false);

    await routeCommentsController.deleteComment(comentario.id!);

    if (!mounted) return;
    if (routeCommentsController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(routeCommentsController.errorMessage!)),
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
    final routeCommentsController = context.watch<RouteCommentsController>();

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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF1B81A),
            ),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<List<RouteComment>>(
              stream: routeCommentsController.getComments(widget.routeId),
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
                      title: FutureBuilder<String>(
                        future: _resolverNomeAutor(
                          comentario.userId,
                          comentario.userName,
                        ),
                        builder: (context, nomeSnapshot) {
                          final nome = nomeSnapshot.data ??
                              (comentario.userName.isNotEmpty
                                  ? comentario.userName
                                  : "Usuário");
                          return Text(
                            nome,
                            style: const TextStyle(color: Colors.black),
                          );
                        },
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
                icon: routeCommentsController.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.send, color: Color(0xFFF1B81A)),
                onPressed:
                    routeCommentsController.isSending ? null : _sendComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
