import 'package:flutter/material.dart';
import '../models/route_comment.dart';
import '../services/route_comments_service.dart';

class RouteCommentsController extends ChangeNotifier {
  final RouteCommentsService _service = RouteCommentsService();

  bool isSending = false;
  String? errorMessage;

  Stream<List<RouteComment>> getComments(String routeId) {
    return _service.getComments(routeId);
  }

  Future<void> addComment({
    required String routeId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.addComment(
        routeId: routeId,
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
