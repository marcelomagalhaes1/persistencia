import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'tarefa.dart';

class CadastroScreen extends StatefulWidget {
  final Tarefa? tarefaEdicao;

  const CadastroScreen({super.key, this.tarefaEdicao});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _contatoController;

  String _caminhoImagem = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.tarefaEdicao?.titulo ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.tarefaEdicao?.descricao ?? '',
    );
    _precoController = TextEditingController(
      text: widget.tarefaEdicao != null
          ? widget.tarefaEdicao!.preco.toStringAsFixed(2)
          : '',
    );
    _contatoController = TextEditingController(
      text: widget.tarefaEdicao?.contato ?? '',
    );
    _caminhoImagem = widget.tarefaEdicao?.imagem ?? '';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _contatoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _caminhoImagem = pickedFile.path;
      });
    }
  }

  void _exibirOpcoesImagem() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF0086FF)),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarImagem(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_camera, color: Color(0xFF0086FF)),
                title: const Text('Tirar Foto com a Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarImagem(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewImagem() {
    if (_caminhoImagem.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 48, color: Color(0xFF0086FF)),
          SizedBox(height: 8),
          Text(
            'Toque para anexar foto do anúncio',
            style: TextStyle(
              color: Color(0xFF0086FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (_caminhoImagem.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(_caminhoImagem, fit: BoxFit.cover),
      );
    }

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(_caminhoImagem, fit: BoxFit.cover),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(File(_caminhoImagem), fit: BoxFit.cover),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final double? precoParsed = double.tryParse(
        _precoController.text.replaceAll(',', '.'),
      );

      final novaTarefa = Tarefa(
        id: widget.tarefaEdicao?.id,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: precoParsed ?? 0.0,
        contato: _contatoController.text.trim(),
        imagem: _caminhoImagem,
      );

      Navigator.pop(context, novaTarefa);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.tarefaEdicao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditando ? 'Editar Anúncio' : 'Anunciar Produto no Magalu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF0086FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto do Produto',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _exibirOpcoesImagem,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _buildPreviewImagem(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Título do Anúncio',
                          hintText: 'Ex: Smartphone Samsung Galaxy S23',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe o título do produto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Preço à vista (R\$)',
                          border: OutlineInputBorder(),
                          prefixText: 'R\$ ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe o preço';
                          }
                          final valorFormatado = value.replaceAll(',', '.');
                          if (double.tryParse(valorFormatado) == null) {
                            return 'Informe um preço válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contatoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone / WhatsApp',
                          hintText: 'Ex: (11) 99999-9999',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.contact_phone),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe um contato';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição detalhada',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe a descrição';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0086FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isEditando ? 'SALVAR ALTERAÇÕES' : 'CONCLUIR ANÚNCIO',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
