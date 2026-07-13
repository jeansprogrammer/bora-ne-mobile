import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:boranemobile/controllers/profile_controller.dart';
import 'package:boranemobile/models/profile_model.dart';
import 'package:boranemobile/services/image_upload_service.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/view/widgets/city_selector_sheet.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileController _profileController;
  final LocationService _locationService = LocationService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final TextEditingController _nomeController = TextEditingController();

  File? _fotoSelecionada;
  bool _dadosCarregados = false;
  bool _estaSalvando = false;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();
    _locationService.addListener(_onServiceChanged);
    _profileController.addListener(_onServiceChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _profileController.carregarPerfil();
      _preencherFormulario();
    });
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _preencherFormulario() {
    final usuario = _profileController.currentUser;
    if (usuario == null || _dadosCarregados) return;
    _nomeController.text = usuario.name;
    _dadosCarregados = true;
    setState(() {});
  }

  @override
  void dispose() {
    _locationService.removeListener(_onServiceChanged);
    _profileController.removeListener(_onServiceChanged);
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final arquivo =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (arquivo == null) return;
    setState(() => _fotoSelecionada = File(arquivo.path));
  }

  Future<void> _salvar() async {
    final usuario = _profileController.currentUser;
    if (usuario == null) return;

    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome de usuário.')),
      );
      return;
    }

    setState(() => _estaSalvando = true);
    try {
      String photoUrl = usuario.photoUrl;
      if (_fotoSelecionada != null) {
        final url = await _imageUploadService.uploadImagem(_fotoSelecionada!);
        if (url == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Falha ao enviar a foto. Tente novamente.')),
            );
          }
          return;
        }
        photoUrl = url;
      }

      final usuarioAtualizado = UserModel(
        uid: usuario.uid,
        name: nome,
        email: usuario.email,
        photoUrl: photoUrl,
        city: _locationService.cidadeAtiva ?? usuario.city,
      );
      await _profileController.atualizarPerfil(usuarioAtualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _estaSalvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _profileController.currentUser;
    final carregando = _profileController.isLoading || usuario == null;

    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.perfil),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color.fromRGBO(245, 183, 10, 1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Editar Perfil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _escolherFoto,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                backgroundImage: _fotoSelecionada != null
                                    ? FileImage(_fotoSelecionada!)
                                    : (usuario.photoUrl.isNotEmpty
                                        ? NetworkImage(usuario.photoUrl)
                                        : null) as ImageProvider?,
                                child: _fotoSelecionada == null &&
                                        usuario.photoUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 50, color: Colors.white)
                                    : null,
                              ),
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black,
                                child: Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _label('Nome de usuário'),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      hintText: 'Seu nome de usuário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _label('Cidade'),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => showCitySelectorSheet(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      child: Text(
                        _locationService.cidadeAtiva ??
                            'Toque para definir sua cidade',
                        style: TextStyle(
                          color: _locationService.cidadeAtiva != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _estaSalvando ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _estaSalvando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : const Text(
                                'Salvar Alterações',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
