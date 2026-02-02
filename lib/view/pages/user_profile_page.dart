import 'package:boranemobile/view/pages/edit_profile_page.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool temaClaro = true;
  bool notificacoes = true;
  bool sons = true;
  bool vibracoes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header(context),
              sectionTitle('PREFERÊNCIAS'),
              switchTile('Tema Claro', temaClaro, (v) {
                setState(() {
                  temaClaro = v;
                });
              }),
              switchTile('Notificações Push', notificacoes, (v) {
                setState(() => notificacoes = v);
              }),
              switchTile('Sons', sons, (v) {
                setState(() => sons = v);
              }),
              switchTile('Vibrações', vibracoes, (v) {
                setState(() => vibracoes = v);
              }),
              sectionTitle('PRIVACIDADE E SEGURANÇA'),
              navigationTile('Gerenciamento de dados pessoais'),
              sectionTitle('INFORMAÇÕES DO APLICATIVO'),
              navigationTile('Termos de Uso e Política de Privacidade'),
              navigationTile('Perguntas Frequentes'),
              navigationTile(
                'Sair da conta',
                showIcon: false,
                textColor: Colors.grey,
              ),
              navigationTile(
                'Versão do aplicativo: 0.0.1',
                showIcon: false,
                textColor: Colors.grey,
              ),
              navigationTile(
                'Excluir conta',
                showIcon: false,
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget header(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jean Mendes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Garanhuns - PE', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Editar perfil'),
        ),
      ],
    ),
  );
}

Widget sectionTitle(String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Colors.grey.shade200,
    child: Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}

Widget switchTile(String title, bool value, ValueChanged<bool> onChanged) {
  return SwitchListTile(
    title: Text(title),
    value: value,
    onChanged: onChanged,
    activeThumbColor: Colors.amber,
  );
}

Widget navigationTile(String title, {Color? textColor, bool showIcon = true}) {
  return ListTile(
    title: Text(title, style: TextStyle(color: textColor ?? Colors.black)),
    trailing: showIcon ? const Icon(Icons.chevron_right) : null,
    onTap: () {},
  );
}
