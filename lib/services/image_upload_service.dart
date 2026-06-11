import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class ImageUploadService {
  // ─── Configure aqui ───────────────────────────────────────────────────────
  static const String _cloudName    = 'dnp6fvcht';
  static const String _uploadPreset = 'borane_unsigned';
  // ─────────────────────────────────────────────────────────────────────────

  static const int _maxDimensao  = 1080; // px máximo
  static const int _tamanhoMaxKb = 800;  // KB máximo antes do upload

  // ── Compressão usando pacote `image` (funciona em todas as plataformas) ───

  Future<File> _comprimir(File imagem) async {
    final tamanhoKb = imagem.lengthSync() / 1024;
    print('📦 Tamanho original: ${tamanhoKb.toStringAsFixed(1)}KB');

    try {
      final bytes = await imagem.readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);

      if (decoded == null) {
        print('⚠️ Não foi possível decodificar, enviando original');
        return imagem;
      }

      // Redimensiona se necessário
      if (decoded.width > _maxDimensao || decoded.height > _maxDimensao) {
        decoded = img.copyResize(
          decoded,
          width:  decoded.width >= decoded.height ? _maxDimensao : null,
          height: decoded.height > decoded.width  ? _maxDimensao : null,
        );
        print('📐 Redimensionado para ${decoded.width}x${decoded.height}px');
      }

      // Comprime progressivamente até atingir o limite
      int qualidade = 85;
      List<int> comprimido = [];

      while (qualidade >= 10) {
        comprimido = img.encodeJpg(decoded, quality: qualidade);
        final kb = comprimido.length / 1024;
        print('🗜️ Qualidade $qualidade% → ${kb.toStringAsFixed(1)}KB');
        if (kb <= _tamanhoMaxKb) break;
        qualidade -= 10;
      }

      // Salva em arquivo temporário
      final dir  = await getTemporaryDirectory();
      final dest = path.join(
          dir.path, '${DateTime.now().millisecondsSinceEpoch}_comp.jpg');
      final arquivo = File(dest);
      await arquivo.writeAsBytes(comprimido);

      final finalKb = comprimido.length / 1024;
      print('✅ Tamanho final: ${finalKb.toStringAsFixed(1)}KB');
      return arquivo;
    } catch (e) {
      print('⚠️ Erro na compressão: $e — enviando original');
      return imagem;
    }
  }

  // ── Upload único → retorna URL pública do Cloudinary ─────────────────────

  Future<String?> uploadImagem(File imagem) async {
    try {
      final comprimida = await _comprimir(imagem);
      final kb = comprimida.lengthSync() / 1024;
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