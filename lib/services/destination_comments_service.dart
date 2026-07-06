import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_comment.dart';

/// Serviço dedicado aos comentários de destinos.
///
/// Os comentários ficam numa coleção de nível superior "destination_comments"
/// (criada automaticamente pelo Firestore no primeiro `addComment`) e cada
/// documento referencia o destino a que pertence via `destinationId`.
class DestinationCommentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'destination_comments';

  CollectionReference<Map<String, dynamic>> get _commentsRef =>
      _firestore.collection(_collectionPath);

  /// Stream com os comentários de um destino, mais recentes primeiro.
  ///
  /// A ordenação é feita no cliente (não via `orderBy` do Firestore) de
  /// propósito: assim a consulta usa apenas um filtro de igualdade em
  /// `destinationId`, que não exige a criação manual de nenhum índice
  /// composto no Firestore antes de funcionar.
  Stream<List<DestinationComment>> getComments(String destinationId) {
    return _commentsRef
        .where('destinationId', isEqualTo: destinationId)
        .snapshots()
        .map((snapshot) {
      final comentarios = snapshot.docs
          .map((doc) => DestinationComment.fromMap(doc.data(), id: doc.id))
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
    required String destinationId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    final comment = DestinationComment(
      destinationId: destinationId,
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
