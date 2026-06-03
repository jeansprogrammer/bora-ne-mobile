import 'package:flutter/material.dart';
import 'package:boranemobile/view/pages/edit_profile_page.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/controllers/profile_controller.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ProfileController _controller = ProfileController();

  bool temaClaro = true;
  bool notificacoes = true;
  bool sons = true;
  bool vibracoes = true;

  @override
  void initState() {
    super.initState();
    // Executa com segurança garantindo que o ciclo de renderização inicial terminou
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.carregarPerfil(() {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Se o CustomBottomNav continuar quebrando por conta do AuthController interno dele,
      // comente a linha abaixo temporariamente para testar a tela isolada!
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: _controller.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    _buildSectionTitle('PREFERÊNCIAS'),
                    _buildSwitchTile('Tema Claro', temaClaro, (v) {
                      setState(() => temaClaro = v);
                    }),
                    _buildSwitchTile('Notificações Push', notificacoes, (v) {
                      setState(() => notificacoes = v);
                    }),
                    _buildSwitchTile('Sons', sons, (v) {
                      setState(() => sons = v);
                    }),
                    _buildSwitchTile('Vibrações', vibracoes, (v) {
                      setState(() => vibracoes = v);
                    }),
                    _buildSectionTitle('PRIVACIDADE E SEGURANÇA'),
                    _buildNavigationTile(
                      'Gerenciamento de dados pessoais',
                      onTap: () {},
                    ),
                    _buildSectionTitle('INFORMAÇÕES DO APLICATIVO'),
                    _buildNavigationTile(
                      'Termos de Uso e Política de Privacidade',
                      onTap: () {},
                    ),
                    _buildNavigationTile('Perguntas Frequentes', onTap: () {}),
                    _buildNavigationTile(
                      'Sair da conta',
                      showIcon: false,
                      textColor: Colors.grey,
                      onTap: () async {
                        try {
                          await _controller.executarLogout();
                          if (context.mounted) {
                            // Volta voltando até não ter mais nenhuma tela para fechar (raiz do app)
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                        } catch (e) {
                          print("Erro ao deslogar: $e");
                        }
                      },
                    ),
                    _buildNavigationTile(
                      'Versão do aplicativo: 0.0.1',
                      showIcon: false,
                      textColor: Colors.grey,
                    ),
                    _buildNavigationTile(
                      'Excluir conta',
                      showIcon: false,
                      textColor: Colors.red,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final usuario = _controller.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
                usuario?.photoUrl != null && usuario!.photoUrl.isNotEmpty
                ? NetworkImage(usuario.photoUrl)
                : null,
            child: usuario?.photoUrl == null || usuario!.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            usuario?.name ?? 'Jean Mendes', // Fallback caso o banco falte
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            child: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.amber,
    );
  }

  Widget _buildNavigationTile(
    String title, {
    Color? textColor,
    bool showIcon = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black)),
      trailing: showIcon ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
