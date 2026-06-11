import 'package:flutter/material.dart';

/// Widget de foto com botão "Ver fotos" que abre um visualizador fullscreen.
class PhotoCarousel extends StatelessWidget {
  final String coverPhoto;
  final List<String> photos;
  final double height;
  final BorderRadius? borderRadius;

  const PhotoCarousel({
    super.key,
    required this.coverPhoto,
    this.photos = const [],
    this.height = 300,
    this.borderRadius,
  });

  List<String> get _todasFotos {
    final lista = <String>[];
    if (coverPhoto.isNotEmpty) lista.add(coverPhoto);
    for (final url in photos) {
      if (url.isNotEmpty && url != coverPhoto) lista.add(url);
    }
    return lista.isEmpty ? [''] : lista;
  }

  @override
  Widget build(BuildContext context) {
    final fotos   = _todasFotos;
    final temMais = fotos.length > 1;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Imagem de capa ─────────────────────────────────────────────
            coverPhoto.isNotEmpty
                ? Image.network(
                    coverPhoto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),

            // ── Botão "Ver fotos" (só se houver mais de 1) ─────────────────
            if (temMais)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _abrirVisualizador(context, fotos),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Ver ${fotos.length} fotos',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _abrirVisualizador(BuildContext context, List<String> fotos) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => _PhotoViewer(fotos: fotos),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFFF9E7),
      child: const Center(
        child: Icon(Icons.image_outlined,
            color: Colors.orangeAccent, size: 48),
      ),
    );
  }
}

// ── Visualizador fullscreen ───────────────────────────────────────────────────

class _PhotoViewer extends StatefulWidget {
  final List<String> fotos;
  const _PhotoViewer({required this.fotos});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  int _index = 0;

  void _anterior() {
    if (_index > 0) setState(() => _index--);
  }

  void _proximo() {
    if (_index < widget.fotos.length - 1) setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.fotos.length;
    final url   = widget.fotos[_index];

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      body: Stack(
        children: [

          // ── Imagem central ────────────────────────────────────────────────
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: url.isNotEmpty
                  ? Image.network(
                      url,
                      key: ValueKey(url),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 64),
                    )
                  : const Icon(Icons.image_outlined,
                      color: Colors.white54, size: 64),
            ),
          ),

          // ── Seta esquerda (aparece a partir da 2ª foto) ───────────────────
          if (_index > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CircleBtn(
                  icon: Icons.chevron_left,
                  onTap: _anterior,
                ),
              ),
            ),

          // ── Seta direita (some na última foto) ────────────────────────────
          if (_index < total - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CircleBtn(
                  icon: Icons.chevron_right,
                  onTap: _proximo,
                ),
              ),
            ),

          // ── Botão fechar (topo direito) ───────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _CircleBtn(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // ── Contador (parte de baixo, centralizado) ───────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Bolinhas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(total, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Texto contador
                Text(
                  '${_index + 1} / $total',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}