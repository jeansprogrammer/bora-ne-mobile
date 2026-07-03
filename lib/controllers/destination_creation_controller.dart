import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/destination_model.dart';
import '../services/destination_service.dart';
import '../services/geoapify_service.dart';
import '../services/image_upload_service.dart';

class DestinationCreationController extends ChangeNotifier {
  final DestinationService _service = DestinationService();
  final ImageUploadService _imageService = ImageUploadService();
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
  String city = '';
  String uf = '';

  // Coordenadas
  double latitude = 0.0;
  double longitude = 0.0;

  // ── Modo edição ──────────────────────────────────────────────────────────
  // Quando != null, estamos editando um destino existente (id do Firestore).
  // Na edição, só título, categorias e descrição mudam; os demais campos
  // (fotos, endereço, coordenadas, favoritos) são preservados.
  String? editingId;
  List<String> _photosExistentes = [];
  String _coverExistente = '';
  List<String> _favoritedByExistente = [];
  // true quando a capa escolhida está entre as fotos novas (locais)
  bool _capaEhNova = false;

  bool get isEditing => editingId != null;

  // ── Estados ──────────────────────────────────────────────────────────────
  bool isSaving = false;
  bool isBuscandoCoordenadas = false;
  bool isBuscandoCep = false;
  bool enderecoVerificado = false; // true quando Geoapify confirmou o endereço
  String? erroMensagem;
  String? erroCep;
  String? erroEndereco;

  // Controllers para atualizar os campos de texto via código
  final TextEditingController ruaController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();

  bool get isValid =>
      nome.isNotEmpty &&
      categoriasSelecionadas.isNotEmpty &&
      city.isNotEmpty &&
      uf.isNotEmpty;

  // Limpa coordenadas ao trocar estado/cidade para forçar nova verificação
  void _resetarEndereco() {
    latitude = 0.0;
    longitude = 0.0;
    enderecoVerificado = false;
    erroEndereco = null;
  }

 List<DestinationModel> _destinos = [];
  bool _isLoading = false;

  List<DestinationModel> get destinos => _destinos;
  bool get isLoading => _isLoading;

  Future<void> carregarDestinos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _destinos = await _service.getAllDestinations();
    } catch (e) {
      print('Erro ao carregar destinos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
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
          rua    = data['logradouro'] ?? '';
          bairro = data['bairro']     ?? '';
          city = data['localidade'] ?? '';
          uf     = data['uf']         ?? '';

          // Atualiza os TextEditingControllers para refletir na tela
          ruaController.text    = rua;
          bairroController.text = bairro;
          cidadeController.text = city;

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
    _capaEhNova = true; // capa escolhida entre as fotos novas (locais)
    notifyListeners();
  }

  // ── Fotos existentes (modo edição) ────────────────────────────────────────
  List<String> get photosExistentes => _photosExistentes;
  String get coverExistente => _coverExistente;
  bool get capaEhNova => _capaEhNova;

  // Define a capa entre as fotos que já estavam salvas (URLs)
  void definirCapaExistente(int index) {
    if (index < 0 || index >= _photosExistentes.length) return;
    _coverExistente = _photosExistentes[index];
    _capaEhNova = false;
    notifyListeners();
  }

  // Remove uma foto já salva (apenas localmente; persiste ao salvar)
  void removerFotoExistente(int index) {
    if (index < 0 || index >= _photosExistentes.length) return;
    final removida = _photosExistentes.removeAt(index);
    if (_coverExistente == removida) {
      _coverExistente =
          _photosExistentes.isNotEmpty ? _photosExistentes.first : '';
    }
    notifyListeners();
  }

  // ── Setters ──────────────────────────────────────────────────────────────

  void setNome(String v)      { nome = v;             notifyListeners(); }
  void setDescricao(String v) { descricao = v;        notifyListeners(); }
  void setRua(String v)       { rua = v;   _resetarEndereco(); notifyListeners(); }
  void setNumero(String v)    { numero = v;           notifyListeners(); }
  void setBairro(String v)    { bairro = v; _resetarEndereco(); notifyListeners(); }
  void setCep(String v)       { cep = v;              notifyListeners(); }
  void setUrlImagem(String v) { urlImagemManual = v;  notifyListeners(); }

  void setCidade(String v) {
    city = v;
    _resetarEndereco();
    // Limpa rua/bairro ao trocar cidade
    rua = '';
    bairro = '';
    numero = '';
    ruaController.clear();
    bairroController.clear();
    notifyListeners();
  }

  void setUf(String v) {
    uf = v.toUpperCase();
    // Reseta cidade ao trocar estado
    city = '';
    cidadeController.clear();
    _resetarEndereco();
    rua = '';
    bairro = '';
    numero = '';
    ruaController.clear();
    bairroController.clear();
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

  Future<void> buscarCoordenadas() async {
    if (city.isEmpty || uf.isEmpty) return;
    // Precisa de pelo menos rua ou bairro para verificar
    if (rua.isEmpty && bairro.isEmpty) return;

    isBuscandoCoordenadas = true;
    enderecoVerificado = false;
    erroEndereco = null;
    notifyListeners();

    final partes = [
      if (rua.isNotEmpty) rua,
      if (numero.isNotEmpty) numero,
      if (bairro.isNotEmpty) bairro,
      city,
      uf,
      'Brasil',
    ];
    final endereco = partes.join(', ');
    print('🔍 Verificando endereço: $endereco');

    final resultado = await GeoapifyService().geocodificarEndereco(endereco);

    if (resultado != null) {
      latitude  = resultado['lat']!;
      longitude = resultado['lon']!;
      enderecoVerificado = true;
      erroEndereco = null;
      print('✅ Endereço confirmado: $latitude, $longitude');
    } else {
      latitude  = 0.0;
      longitude = 0.0;
      enderecoVerificado = false;
      erroEndereco = 'Endereço não encontrado. Verifique os dados.';
      print('❌ Endereço não encontrado');
    }

    isBuscandoCoordenadas = false;
    notifyListeners();
  }

  // ── Carregar destino para EDIÇÃO ──────────────────────────────────────────
  // Preenche o formulário com os dados existentes. Apenas título, categorias e
  // descrição serão editáveis na tela; o restante é preservado para o update.
  void carregarParaEdicao(Map<String, dynamic> data, {String? id}) {
    editingId = id ?? data['id']?.toString();

    // Campos editáveis
    nome = data['name'] ?? '';
    descricao = data['description'] ?? '';
    categoriasSelecionadas = List<String>.from(data['categories'] ?? []);

    // Campos preservados (não editáveis na tela de edição)
    rua = data['street'] ?? '';
    numero = data['number'] ?? '';
    bairro = data['neighborhood'] ?? '';
    cep = data['cep'] ?? '';
    city = data['city'] ?? '';
    uf = data['state'] ?? '';
    latitude = (data['latitude'] ?? 0.0).toDouble();
    longitude = (data['longitude'] ?? 0.0).toDouble();
    enderecoVerificado = true; // já tinha endereço válido salvo

    _photosExistentes = List<String>.from(data['photos'] ?? []);
    _coverExistente = data['coverPhoto'] ?? data['image'] ?? '';
    _favoritedByExistente = List<String>.from(data['favoritedBy'] ?? []);
    _capaEhNova = false;
    fotos = [];
    indiceFotoCapa = 0;

    // Sincroniza os controllers de texto auxiliares
    ruaController.text = rua;
    bairroController.text = bairro;
    cidadeController.text = city;

    notifyListeners();
  }

  // ── Salvar alterações (edição) ────────────────────────────────────────────
  // Atualiza somente os campos editáveis, preservando fotos, endereço,
  // coordenadas e favoritos já existentes.
  Future<bool> salvarEdicao() async {
    if (editingId == null) return false;
    // Na edição exige apenas nome e categoria (endereço já está salvo)
    if (nome.isEmpty || categoriasSelecionadas.isEmpty) return false;

    isSaving = true;
    erroMensagem = null;
    notifyListeners();

    try {
      // ── Fotos: combina as existentes (URLs) com as novas (upload) ──────────
      List<String> fotosFinais = List<String>.from(_photosExistentes);
      String capaFinal = _coverExistente;

      if (fotos.isNotEmpty) {
        final novasUrls = await _imageService.uploadImagens(fotos);
        // Capa entre as novas, OU capa inicial quando o destino não tinha foto
        if ((_capaEhNova || capaFinal.isEmpty) && novasUrls.isNotEmpty) {
          capaFinal = novasUrls[indiceFotoCapa.clamp(0, novasUrls.length - 1)];
        }
        fotosFinais.addAll(novasUrls);
      }

      // Garante uma capa válida
      if (capaFinal.isEmpty && fotosFinais.isNotEmpty) {
        capaFinal = fotosFinais.first;
      }

      final destinoAtualizado = DestinationModel(
        id: editingId,
        name: nome,
        description: descricao,
        photos: fotosFinais,
        coverPhoto: capaFinal,
        categories: List.from(categoriasSelecionadas),
        street: rua,
        number: numero,
        neighborhood: bairro,
        cep: cep,
        city: city,
        state: uf,
        latitude: latitude,
        longitude: longitude,
        favoritedBy: _favoritedByExistente,
      );

      final sucesso =
          await _service.atualizarDestination(editingId!, destinoAtualizado);

      if (sucesso) {
        _resetar();
        await carregarDestinos();
      }

      isSaving = false;
      notifyListeners();
      return sucesso;
    } catch (e) {
      erroMensagem = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── Salvar ───────────────────────────────────────────────────────────────

  Future<bool> salvar() async {
    if (!isValid) return false;

    isSaving = true;
    erroMensagem = null;
    notifyListeners();

    try {
      List<String> urls = [];
      String urlCapa = '';

      if (fotos.isNotEmpty) {
        // Upload via Cloudinary com compressão automática
        urls = await _imageService.uploadImagens(fotos);
        urlCapa = urls.isNotEmpty
            ? urls[indiceFotoCapa.clamp(0, urls.length - 1)]
            : urlImagemManual;
      } else {
        // Usa URL manual se informada
        urlCapa = urlImagemManual;
        if (urlCapa.isNotEmpty) urls = [urlCapa];
      }

      final Destination = DestinationModel(
        name: nome,
        description: descricao,
        photos: urls,
        coverPhoto: urlCapa,
        categories: List.from(categoriasSelecionadas),
        street: rua,
        number: numero,
        neighborhood: bairro,
        cep: cep,
        city: city,
        state: uf,
        latitude: latitude,
        longitude: longitude,
        favoritedBy: [],
      );

      final id = await _service.salvarDestination(Destination);
      print('📋 ID retornado: $id'); // null = falhou no Firestore
      final sucesso = id != null;

      if (sucesso) {
        _resetar();
        await carregarDestinos();
      }

      isSaving = false;
      notifyListeners();
      return sucesso;
    } catch (e) {
      erroMensagem = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── Excluir destino (apenas no modo edição) ──────────────────────────────
  Future<bool> deleteDestination() async {
    if (editingId == null) return false;

    isSaving = true;
    notifyListeners();

    try {
      final sucesso = await _service.excluirDestination(editingId!);
      if (sucesso) resetar();
      isSaving = false;
      notifyListeners();
      return sucesso;
    } catch (e) {
      print('Erro ao excluir destino: $e');
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // Público para uso externo (ex: ao confirmar saída da tela)
  void resetar() {
    fotos = [];
    indiceFotoCapa = 0;
    urlImagemManual = '';
    nome = '';
    descricao = '';
    categoriasSelecionadas = [];
    rua = '';
    numero = '';
    bairro = '';
    cep = '';
    city = '';
    uf = '';
    latitude = 0.0;
    longitude = 0.0;
    enderecoVerificado = false;
    erroMensagem = null;
    erroCep = null;
    erroEndereco = null;
    // Limpa estado de edição
    editingId = null;
    _photosExistentes = [];
    _coverExistente = '';
    _favoritedByExistente = [];
    _capaEhNova = false;
    ruaController.clear();
    bairroController.clear();
    cidadeController.clear();
    notifyListeners();
  }

  void _resetar() => resetar();

  @override
  void dispose() {
    ruaController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    super.dispose();
  }
}