import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewRouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ESTE É O MÉTODO QUE ESTAVA FALTANDO (Erro da imagem 462009)
  Future<List<String>> uploadImages(List<File> images) async {
    List<String> downloadUrls = [];

    for (var image in images) {
      try {
        String fileName = 'rota_${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(image)}.jpg';
        Reference ref = _storage.ref().child('rotas_fotos').child(fileName);
        
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        
        String url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      } catch (e) {
        print("Erro ao fazer upload de imagem: $e");
      }
    }
    return downloadUrls;
  }

  // Método para salvar a rota final
  Future<bool> saveRouteToFirestore(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('routes').add({
        ...data,
        'data_criacao': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Erro ao salvar no Firestore: $e");
      return false;
    }
  }
}