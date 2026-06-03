import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  // ─── Configure aqui ──────────────────────────────────────────────────────
  static const String _cloudName   = 'dnp6fvcht';
  static const String _uploadPreset = 'borane_unsigned';
  // ─────────────────────────────────────────────────────────────────────────

  static const int _maxWidth    = 1080;
  static const int _maxHeight   = 1080;
  static const int _qualidade   = 80;
  static const int _tamanhoMaxKb = 500;

  // ── Comprime imagem progressivamente até atingir o limite ────────────────

  Future<File> _comprimir(File imagem) async {
    final tamanhoKb = await imagem.length() / 1024;
    if (tamanhoKb <= _tamanhoMaxKb) {
      return await _redimensionar(imagem, _qualidade) ?? imagem;
    }

    int qualidade = _qualidade;
    File? resultado;
    while (qualidade >= 20) {
      resultado = await _redimensionar(imagem, qualidade);
      if (resultado == null) break;
      final kb = await resultado.length() / 1024;
      print('🗜️ Compressão ${qualidade}% → ${kb.toStringAsFixed(1)}KB');
      if (kb <= _tamanhoMaxKb) break;
      qualidade -= 10;
    }
    return resultado ?? imagem;
  }

  Future<File?> _redimensionar(File imagem, int qualidade) async {
    try {
      final dir  = await getTemporaryDirectory();
      final dest = path.join(
          dir.path, '${DateTime.now().millisecondsSinceEpoch}_comp.jpg');
      final xfile = await FlutterImageCompress.compressAndGetFile(
        imagem.absolute.path,
        dest,
        minWidth: _maxWidth,
        minHeight: _maxHeight,
        quality: qualidade,
        format: CompressFormat.jpeg,
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
