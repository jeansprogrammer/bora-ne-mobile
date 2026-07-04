import 'package:flutter/material.dart';
import '../models/destination_comment.dart';
import '../services/destination_comments_service.dart';

class CommentsController extends ChangeNotifier {
  final DestinationCommentsService _service = DestinationCommentsService();

  bool isSending = false;
  String? errorMessage;

  Stream<List<DestinationComment>> getComments(String destinationId) {
    return _service.getComments(destinationId);
  }

  Future<void> addComment({
    required String destinationId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.addComment(
        destinationId: destinationId,
        userId: userId,
        userName: userName,
        message: message,
      );
    } catch (e) {
      errorMessage = 'Erro ao enviar comentário: $e';
      debugPrint(errorMessage);
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment(String commentId) async {
    errorMessage = null;

    try {
      await _service.deleteComment(commentId);
    } catch (e) {
      errorMessage = 'Erro ao excluir comentário: $e';
      debugPrint(errorMessage);
      notifyListeners();
    }
  }
}
