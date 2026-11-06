import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anuncio.dart';
import '../databases/sqlite/anuncio_helper.dart';
import 'cadastro.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnuncioHelper _anuncioHelper = AnuncioHelper();
  List<Anuncio> _anuncios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
  }

  Future<void> _carregarAnuncios() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
    });

    try {
      final dados = await _anuncioHelper.listarAnuncios();
      if (mounted) {
        setState(() {
          _anuncios = dados;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar anúncios: $e');
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _adicionarOuEditarAnuncio({Anuncio? anuncio}) async {
    final resultado = await Navigator.push<Anuncio>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroScreen(tarefaEdicao: anuncio),
      ),
    );

    if (resultado != null) {
      if (anuncio != null && anuncio.id != null) {
        await _anuncioHelper.atualizarAnuncio(resultado);
      } else {
        await _anuncioHelper.salvarAnuncio(resultado);
      }
      await _carregarAnuncios();
    }
  }

  Future<void> _removerAnuncio(Anuncio anuncio) async {
    if (anuncio.id != null) {
      await _anuncioHelper.deletarAnuncio(anuncio.id!);
      await _carregarAnuncios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anúncio "${anuncio.titulo}" removido.'),
            backgroundColor: const Color(0xFF0086FF),
            action: SnackBarAction(
              label: 'Desfazer',
              textColor: Colors.yellow,
              onPressed: () async {
                await _anuncioHelper.salvarAnuncio(anuncio);
                await _carregarAnuncios();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _abrirWhatsApp(
      String contato, String titulo, double preco) async {
    final numero = contato.replaceAll(RegExp(r'\D'), '');
    final texto = Uri.encodeComponent(
      'Olá! Tenho interesse no anúncio "$titulo" (R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}).',
    );

    final Uri urlApp = Uri.parse('whatsapp://send?phone=55$numero&text=$texto');
    final Uri urlWeb = Uri.parse('https://wa.me/55$numero?text=$texto');

    if (await canLaunchUrl(urlApp)) {
      await launchUrl(urlApp);
    } else if (await canLaunchUrl(urlWeb)) {
      await launchUrl(urlWeb, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _enviarSMS(String contato, String titulo) async {
    final numero = contato.replaceAll(RegExp(r'\D'), '');
    final texto =
        Uri.encodeComponent('Olá! Tenho interesse no anúncio "$titulo".');
    final Uri url = Uri.parse('sms:$numero?body=$texto');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _enviarEmail(
      String titulo, String descricao, double preco) async {
    final assunto = Uri.encodeComponent('Interesse no anúncio: $titulo');
    final corpo = Uri.encodeComponent(
      'Olá,\n\nTenho interesse no anúncio "$titulo" no valor de R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}.\n\nDescrição: $descricao',
    );
    final Uri url = Uri.parse('mailto:?subject=$assunto&body=$corpo');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget _buildImagem(String imagemPath) {
    if (imagemPath.isEmpty) {
      return const Icon(Icons.image, size: 40, color: Colors.grey);
    }

    if (imagemPath.startsWith('data:image')) {
      try {
        final base64Str = imagemPath.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image, size: 40, color: Colors.grey),
        );
      } catch (_) {
        return const Icon(Icons.image, size: 40, color: Colors.grey);
      }
    }

    if (imagemPath.startsWith('assets/')) {
      return Image.asset(
        imagemPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    if (kIsWeb ||
        imagemPath.startsWith('blob:') ||
        imagemPath.startsWith('http')) {
      return Image.network(
        imagemPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    return Image.file(
      File(imagemPath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: const Color(0xFF0086FF),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'magalu ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.yellow,
                            size: 22,
                          ),
                        ],
                      ),
                      Text(
                        'Tem no Magalu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF0086FF)),
                        SizedBox(width: 8),
                        Text(
                          'Busca no Magalu',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _anuncios.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_shopping_cart,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Nenhum produto anunciado no momento.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _anuncios.length,
                        itemBuilder: (context, index) {
                          final anuncio = _anuncios[index];
                          final parcelas = (anuncio.preco / 10)
                              .toStringAsFixed(2)
                              .replaceAll('.', ',');

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.05),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey.shade100,
                                          child: _buildImagem(anuncio.imagem),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              anuncio.titulo,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              anuncio.descricao,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Frete Grátis',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'R\$ ${anuncio.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0086FF),
                                              ),
                                            ),
                                            Text(
                                              'ou 10x de R\$ $parcelas sem juros',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _adicionarOuEditarAnuncio(
                                              anuncio: anuncio,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _removerAnuncio(anuncio),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () => _abrirWhatsApp(
                                          anuncio.contato,
                                          anuncio.titulo,
                                          anuncio.preco,
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.chat_bubble_outline,
                                                color: Colors.green, size: 18),
                                            SizedBox(width: 4),
                                            Text(
                                              'WhatsApp',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _enviarSMS(
                                          anuncio.contato,
                                          anuncio.titulo,
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.sms_outlined,
                                                color: Color(0xFF0086FF),
                                                size: 18),
                                            SizedBox(width: 4),
                                            Text(
                                              'SMS',
                                              style: TextStyle(
                                                color: Color(0xFF0086FF),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _enviarEmail(
                                          anuncio.titulo,
                                          anuncio.descricao,
                                          anuncio.preco,
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.email_outlined,
                                                color: Colors.deepOrange,
                                                size: 18),
                                            SizedBox(width: 4),
                                            Text(
                                              'E-mail',
                                              style: TextStyle(
                                                color: Colors.deepOrange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _adicionarOuEditarAnuncio(),
        backgroundColor: const Color(0xFF0086FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'ANUNCIAR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
