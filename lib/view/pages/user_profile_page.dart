import 'package:boranemobile/view/pages/faq_page.dart';
import 'package:boranemobile/view/pages/report_problem_page.dart';
import 'package:flutter/material.dart';
import 'package:boranemobile/controllers/profile_controller.dart';
import 'package:boranemobile/view/pages/edit_profile_page.dart';
import 'package:boranemobile/view/pages/login_page.dart';
import 'package:boranemobile/view/pages/terms_page.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.carregarPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.perfil),
          body: _controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color.fromRGBO(245, 183, 10, 1)))
              : Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _controller.isLoggedIn
                            ? _buildLoggedInBody(context)
                            : _buildLoggedOutBody(context),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final usuario  = _controller.currentUser;
    final isLogged = _controller.isLoggedIn;
    final fbUser   = _controller.firebaseUser;

    final String? fotoUrl = (usuario?.photoUrl.isNotEmpty == true)
        ? usuario!.photoUrl
        : fbUser?.photoURL;

    final String nome = (usuario?.name.isNotEmpty == true)
        ? usuario!.name
        : (fbUser?.displayName ?? '');

    final String cidade = usuario?.city ?? '';

    return Container(
      width: double.infinity,
      color: Colors.amber,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Image.asset('assets/images/LOGO_V2_3.png', height: 36),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isLogged
                ? () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()))
                : null,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white,
              backgroundImage: (isLogged && fotoUrl != null && fotoUrl.isNotEmpty)
                  ? NetworkImage(fotoUrl)
                  : null,
              child: (fotoUrl == null || fotoUrl.isEmpty)
                  ? Icon(Icons.person, size: 46, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isLogged ? nome : 'Visitante',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (isLogged && cidade.isEmpty && fbUser?.email != null) ...[
            const SizedBox(height: 4),
            Text(fbUser!.email!,
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
          if (isLogged && cidade.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(cidade,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ],
      ),
    );
  }

  Widget _buildLoggedInBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        _buildSectionTitle('Preferências'),
        _buildTile(icon: Icons.route_outlined, label: 'Minhas rotas', onTap: () {}),
        _buildTile(icon: Icons.place_outlined, label: 'Meus destinos', onTap: () {}),

        const SizedBox(height: 8),

        _buildSectionTitle('Configurações gerais'),
        _buildTile(
          icon: Icons.description_outlined,
          label: 'Termos de uso',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TermsPage())),
        ),
        _buildTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Política de privacidade',
          onTap: () {},
        ),

        const SizedBox(height: 8),

        _buildSectionTitle('Suporte'),
        _buildTile(
          icon: Icons.help_outline,
          label: 'Ajuda / FAQ',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FaqPage())),
        ),
        _buildTile(
          icon: Icons.flag_outlined,
          label: 'Reportar problema',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReportProblemPage())),
        ),

        const SizedBox(height: 8),

        _buildTile(
          icon: Icons.logout,
          label: 'Sair da conta',
          iconColor: Colors.red,
          labelColor: Colors.red,
          showChevron: false,
          onTap: () async {
            await _controller.executarLogout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          },
        ),

        const SizedBox(height: 32),
        Center(
          child: Text('Versão 0.0.1',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoggedOutBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Faça login para acessar seu perfil, rotas salvas e muito mais.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
                if (context.mounted) _controller.carregarPerfil();
              },
              icon: Image.network(
                'https://www.google.com/favicon.ico',
                width: 20, height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 20),
              ),
              label: const Text('Entrar com Google',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        _buildSectionTitle('Configurações gerais'),
        _buildTile(
          icon: Icons.description_outlined,
          label: 'Termos de uso',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TermsPage())),
        ),
        _buildTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Política de privacidade',
          onTap: () {},
        ),

        _buildSectionTitle('Suporte'),
        _buildTile(
          icon: Icons.help_outline,
          label: 'Ajuda / FAQ',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FaqPage())),
        ),
        _buildTile(
          icon: Icons.flag_outlined,
          label: 'Reportar problema',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReportProblemPage())),
        ),

        const SizedBox(height: 32),
        Center(
          child: Text('Versão 0.0.1',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? labelColor,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.black54, size: 22),
        title: Text(label,
            style: TextStyle(color: labelColor ?? Colors.black87, fontSize: 15)),
        trailing: showChevron
            ? const Icon(Icons.chevron_right, color: Colors.black26, size: 20)
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      ),
    );
  }
}