class Anuncio {
  int? id;
  final String titulo;
  final String descricao;
  final double preco;
  final String contato;
  final String imagem;

  Anuncio({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.contato,
    required this.imagem,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'contato': contato,
      'imagem': imagem,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Anuncio.fromMap(Map<String, dynamic> map) {
    return Anuncio(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      preco: (map['preco'] is num)
          ? (map['preco'] as num).toDouble()
          : double.tryParse(map['preco']?.toString() ?? '0') ?? 0.0,
      contato: map['contato']?.toString() ?? '',
      imagem: map['imagem']?.toString() ?? '',
    );
  }
}