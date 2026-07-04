import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_comment.dart';

/// Serviço dedicado aos comentários de rotas.
///
/// Os comentários ficam numa coleção de nível superior "route_comments"
/// (criada automaticamente pelo Firestore no primeiro `addComment`) e cada
/// documento referencia a rota a que pertence via `routeId`.
class RouteCommentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'route_comments';

  CollectionReference<Map<String, dynamic>> get _commentsRef =>
      _firestore.collection(_collectionPath);

  /// Stream com os comentários de uma rota, mais recentes primeiro.
  ///
  /// A ordenação é feita no cliente (não via `orderBy` do Firestore) de
  /// propósito: assim a consulta usa apenas um filtro de igualdade em
  /// `routeId`, que não exige a criação manual de nenhum índice composto
  /// no Firestore antes de funcionar.
  Stream<List<RouteComment>> getComments(String routeId) {
    return _commentsRef
        .where('routeId', isEqualTo: routeId)
        .snapshots()
        .map((snapshot) {
      final comentarios = snapshot.docs
          .map((doc) => RouteComment.fromMap(doc.data(), id: doc.id))
          .toList();

      comentarios.sort((a, b) {
        final createdAtA = a.createdAt;
        final createdAtB = b.createdAt;
        if (createdAtA == null || createdAtB == null) return 0;
        return createdAtB.compareTo(createdAtA);
      });

      return comentarios;
    });
  }

  Future<void> addComment({
    required String routeId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    final comment = RouteComment(
      routeId: routeId,
      userId: userId,
      userName: userName,
      message: message,
    );
    await _commentsRef.add(comment.toMap());
  }

  Future<void> deleteComment(String commentId) async {
    await _commentsRef.doc(commentId).delete();
  }
}
