import 'package:boranemobile/models/category_model.dart';
import 'package:boranemobile/models/destino_model.dart'; //Aqui estou importando o modelo já existente
import 'package:cloud_firestore/cloud_firestore.dart'; //Aqui estou importando o Firebase
import 'package:flutter/material.dart';

class CategoryController extends ChangeNotifier {

  // Aqui será a instância do Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Segue à baixo as Novas variáveis de Estado

  List<DestinoModel> destinosFiltrados = [];
bool isLoading = false;

  final List<CategoryModel> categories = [
    CategoryModel(
      title: "Religioso",
      image: "assets/images/bible.png",
      route: "/religioso",
    ),
    CategoryModel(
      title: "Gastronômico",
      image: "assets/images/burger.png",
      route: "/gastronomico",
    ),
    CategoryModel(
      title: "Histórico",
      image: "assets/images/hieroglyph.png",
      route: "/historico",
    ),
    CategoryModel(
      title: "Aventuras",
      image: "assets/images/tent.png",
      route: "/aventuras",
    ),
    CategoryModel(
      title: "Outros",
      image: "assets/images/searching.png",
      route: "/outros",
    ),
  ];

  // Método para puxar do Firebase

  Future<void> carregarDestinosPorCategoria(String nomeCategoria) async {
    isLoading = true;
    destinosFiltrados = [];
    notifyListeners(); // Isso vai servir para avisar a View para mostrar o indicador de carregamento

    try {
      // Segue à baixo o responsável por fazer a busca na coleção "destinos", onde o array "categorias" contém o nome enviado
      QuerySnapshot querySnapshot = await _firestore
        .collection('destinos')
        .where('categorias', arrayContains: nomeCategoria)
        .get();

      // Agora segue à baixo o responsável por mapeiar os documentos usando o DestinoModel.fromMap que já possuímos
      destinosFiltrados = querySnapshot.docs.map((doc) {
        return DestinoModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      print("Erro ao buscar destinos por categorias: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Este vai avisar a View para renderizar os destinos ou parar loading
    }
  }


  void navigateToCategory(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}
