import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  // ─── Configure aqui ──────────────────────────────────────────────────────
  static const String _cloudName   = 'dnp6fvcht';    // ex: dxyz123abc
  static const String _uploadPreset = 'borane_unsigned'; // ex: borane_unsigned
  // ─────────────────────────────────────────────────────────────────────────

  static const int _maxWidth     = 1080;
  static const int _maxHeight    = 1080;
  static const int _qualidade    = 75;
  static const int _tamanhoMaxKb = 800;   // 800KB → bem abaixo do 10MB do Cloudinary

  // ── Comprime progressivamente até atingir o limite ────────────────────────

  Future<File> _comprimir(File imagem) async {
    final tamanhoKb = await imagem.length() / 1024;
    print('📦 Tamanho original: ${tamanhoKb.toStringAsFixed(1)}KB');

    // Primeiro redimensiona para 1080px independente do tamanho
    File? resultado = await _redimensionar(imagem, _maxWidth, _maxHeight, _qualidade);
    resultado ??= imagem;

    double kb = await resultado.length() / 1024;
    print('🗜️ Após redimensionar: ${kb.toStringAsFixed(1)}KB');

    // Se ainda grande, reduz qualidade progressivamente
    int qualidade = _qualidade - 10;
    while (kb > _tamanhoMaxKb && qualidade >= 10) {
      resultado = await _redimensionar(imagem, _maxWidth, _maxHeight, qualidade) ?? resultado!;
      kb = await resultado.length() / 1024;
      print('🗜️ Qualidade $qualidade% → ${kb.toStringAsFixed(1)}KB');
      qualidade -= 10;
    }

    // Se ainda muito grande, reduz resolução também
    int resolucao = 800;
    while (kb > _tamanhoMaxKb && resolucao >= 400) {
      resultado = await _redimensionar(imagem, resolucao, resolucao, 30) ?? resultado!;
      kb = await resultado.length() / 1024;
      print('🗜️ Resolução ${resolucao}px → ${kb.toStringAsFixed(1)}KB');
      resolucao -= 200;
    }

    print('✅ Tamanho final: ${kb.toStringAsFixed(1)}KB');
    return resultado!;
  }

  Future<File?> _redimensionar(File imagem, int maxW, int maxH, int qualidade) async {
    try {
      final dir  = await getTemporaryDirectory();
      final dest = path.join(
          dir.path, '${DateTime.now().millisecondsSinceEpoch}_comp.jpg');
      final xfile = await FlutterImageCompress.compressAndGetFile(
        imagem.absolute.path,
        dest,
        minWidth: maxW,   // flutter_image_compress usa minWidth como max de fato
        minHeight: maxH,
        quality: qualidade,
        format: CompressFormat.jpeg,
        keepExif: false,  // remove metadados EXIF (reduz tamanho)
      );
      return xfile != null ? File(xfile.path) : null;
    } catch (e) {
      print('Erro na compressão: $e');
      return null;
    }
  }

  // ── Upload único → retorna URL pública do Cloudinary ─────────────────────

  Future<String?> uploadImagem(File imagem) async {
    try {
      final comprimida = await _comprimir(imagem);
      final kb = await comprimida.length() / 1024;
      print('📤 Enviando: ${kb.toStringAsFixed(1)}KB');

      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
            await http.MultipartFile.fromPath('file', comprimida.path));

      final response = await request.send();
      final body     = await response.stream.bytesToString();
      final data     = jsonDecode(body);

      if (response.statusCode == 200) {
        final url = data['secure_url'] as String;
        print('✅ Upload OK: $url');
        return url;
      }
      print('❌ Cloudinary erro: ${data['error']}');
      return null;
    } catch (e) {
      print('❌ Erro no upload: $e');
      return null;
    }
  }

  // ── Upload de múltiplas imagens ───────────────────────────────────────────

  Future<List<String>> uploadImagens(List<File> imagens) async {
    final urls = <String>[];
    for (int i = 0; i < imagens.length; i++) {
      print('📸 Imagem ${i + 1}/${imagens.length}...');
      final url = await uploadImagem(imagens[i]);
      if (url != null) urls.add(url);
    }
    print('✅ ${urls.length}/${imagens.length} enviadas');
    return urls;
  }
}