import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/destino_model.dart';
import '../services/destino_service.dart';
import '../services/geoapify_service.dart';

class DestinoCreationController extends ChangeNotifier {
  final DestinoService _service = DestinoService();
  final ImagePicker _picker = ImagePicker();

  // ── Fotos ────────────────────────────────────────────────────────────────
  List<File> fotos = [];
  int indiceFotoCapa = 0;
  String urlImagemManual = '';

  // ── Campos do formulário ─────────────────────────────────────────────────
  String nome = '';
  String descricao = '';
  List<String> categoriasSelecionadas = [];

  // Endereço
  String rua = '';
  String numero = '';
  String bairro = '';
  String cep = '';
  String cidade = '';
  String uf = '';

  // Coordenadas
  double latitude = 0.0;
  double longitude = 0.0;

  // ── Estados ──────────────────────────────────────────────────────────────
  bool isSaving = false;
  bool isBuscandoCoordenadas = false;
  bool isBuscandoCep = false; // ← loading do CEP
  String? erroMensagem;
  String? erroCep; // ← erro específico do CEP

  // Controllers para atualizar os campos de texto via código
  final TextEditingController ruaController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();

  bool get isValid =>
      nome.isNotEmpty &&
      categoriasSelecionadas.isNotEmpty &&
      cidade.isNotEmpty &&
      uf.isNotEmpty;

  // ── Busca CEP via ViaCEP ─────────────────────────────────────────────────

  Future<void> buscarCep(String cepDigitado) async {
    final cepLimpo = cepDigitado.replaceAll(RegExp(r'\D'), '');
    if (cepLimpo.length != 8) return;

    cep = cepLimpo;
    isBuscandoCep = true;
    erroCep = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['erro'] == true || data['erro'] == 'true') {
          erroCep = 'CEP não encontrado';
        } else {
          // Preenche os campos automaticamente
          rua = data['logradouro'] ?? '';
          bairro = data['bairro'] ?? '';
          cidade = data['localidade'] ?? '';
          uf = data['uf'] ?? '';

          // Atualiza os TextEditingControllers para refletir na tela
          ruaController.text = rua;
          bairroController.text = bairro;
          cidadeController.text = cidade;

          erroCep = null;
        }
      } else {
        erroCep = 'Erro ao buscar CEP';
      }
    } catch (e) {
      erroCep = 'Sem conexão';
    }

    isBuscandoCep = false;
    notifyListeners();
  }

  // ── Fotos ────────────────────────────────────────────────────────────────

  Future<void> selecionarFotos() async {
    final List<XFile> imagens = await _picker.pickMultiImage();
    if (imagens.isNotEmpty) {
      fotos.addAll(imagens.map((x) => File(x.path)));
      notifyListeners();
    }
  }

  void removerFoto(int index) {
    fotos.removeAt(index);
    if (indiceFotoCapa >= fotos.length) {
      indiceFotoCapa = fotos.isEmpty ? 0 : fotos.length - 1;
    }
    notifyListeners();
  }

  void definirFotoCapa(int index) {
    indiceFotoCapa = index;
    notifyListeners();
  }

  // ── Setters ──────────────────────────────────────────────────────────────

  void setNome(String v) {
    nome = v;
    notifyListeners();
  }

  void setDescricao(String v) {
    descricao = v;
    notifyListeners();
  }

  void setRua(String v) {
    rua = v;
    notifyListeners();
  }

  void setNumero(String v) {
    numero = v;
    notifyListeners();
  }

  void setBairro(String v) {
    bairro = v;
    notifyListeners();
  }

  void setCep(String v) {
    cep = v;
    notifyListeners();
  }

  void setCidade(String v) {
    cidade = v;
    notifyListeners();
  }

  void setUf(String v) {
    uf = v.toUpperCase();
    notifyListeners();
  }

  void setUrlImagem(String v) {
    urlImagemManual = v;
    notifyListeners();
  }

  void toggleCategoria(String cat) {
    if (categoriasSelecionadas.contains(cat)) {
      categoriasSelecionadas.remove(cat);
    } else {
      categoriasSelecionadas.add(cat);
    }
    notifyListeners();
  }

  // ── Busca coordenadas pelo endereço via Geoapify ─────────────────────────

  // destino_creation_controller.dart — método buscarCoordenadas()
  Future<void> buscarCoordenadas() async {
    if (rua.isEmpty || cidade.isEmpty) return;

    isBuscandoCoordenadas = true;
    notifyListeners();

    // Monta sem campos vazios
    final partes = [
      if (rua.isNotEmpty) rua,
      if (numero.isNotEmpty) numero,
      if (bairro.isNotEmpty) bairro,
      if (cidade.isNotEmpty) cidade,
      if (uf.isNotEmpty) uf,
      'Brasil',
    ];
    final endereco = partes.join(', ');
    print('🔍 Buscando coordenadas para: $endereco'); // ← veja no terminal

    final resultado = await GeoapifyService().geocodificarEndereco(endereco);

    if (resultado != null) {
      latitude = resultado['lat']!;
      longitude = resultado['lon']!;
      print('✅ Coordenadas: $latitude, $longitude');
    } else {
      print('❌ Nenhum resultado encontrado');
    }

    isBuscandoCoordenadas = false;
    notifyListeners();
  }

  // ── Salvar ───────────────────────────────────────────────────────────────

  // Mude o retorno de Future<bool> para Future<DestinoModel?>
  Future<DestinoModel?> salvar() async {
    if (!isValid) return null;

    isSaving = true;
    erroMensagem = null;
    notifyListeners();

    try {
      List<String> urls = [];
      String urlCapa = '';

      if (fotos.isNotEmpty) {
        urls = await _service.uploadFotos(fotos);
        urlCapa = urls.isNotEmpty
            ? urls[indiceFotoCapa.clamp(0, urls.length - 1)]
            : urlImagemManual;
      } else {
        urlCapa = urlImagemManual;
        if (urlCapa.isNotEmpty) urls = [urlCapa];
      }

      final destino = DestinoModel(
        nome: nome,
        descricao: descricao,
        fotos: urls,
        fotoCapa: urlCapa,
        categorias: List.from(categoriasSelecionadas),
        rua: rua,
        numero: numero,
        bairro: bairro,
        cep: cep,
        cidade: cidade,
        uf: uf,
        latitude: latitude,
        longitude: longitude,
        favoritadoPor: [],
      );

      final id = await _service.salvarDestino(destino);

      if (id != null) {
        final destinoCriado = destino.copyWith(id: id); // ← retorna com ID
        _resetar();
        isSaving = false;
        notifyListeners();
        return destinoCriado; // ← retorna o modelo
      }

      isSaving = false;
      notifyListeners();
      return null;
    } catch (e) {
      erroMensagem = e.toString();
      isSaving = false;
      notifyListeners();
      return null;
    }
  }

  void _resetar() {
    fotos = [];
    indiceFotoCapa = 0;
    nome = '';
    descricao = '';
    categoriasSelecionadas = [];
    rua = '';
    numero = '';
    bairro = '';
    cep = '';
    cidade = '';
    uf = '';
    latitude = 0.0;
    longitude = 0.0;
    ruaController.clear();
    bairroController.clear();
    cidadeController.clear();
  }

  @override
  void dispose() {
    ruaController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    super.dispose();
  }
}
