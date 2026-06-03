import 'package:boranemobile/models/profile_model.dart';

class ProfileLoadDadosService {
  // Simula a busca de dados no banco de dados
  Future<UserModel> fetchUserData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula o tempo de requisição
    
    // Na integração real com o Firebase, seria algo como:
    // var doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    // return UserModel.fromMap(doc.data()!, doc.id);

    return UserModel(
      uid: "user_999",
      name: "João Silva",
      email: "joao.silva@email.com",
      photoUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde",
    );
  }

  // Simula o processo de deslogar
  Future<void> logoutAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print("Sessão encerrada no Firebase.");
  }
}