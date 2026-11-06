class Tarefa {
  int? id;
  final String titulo;
  final String descricao;
  final double preco;
  final String contato;
  final String imagem;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.contato,
    required this.imagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'contato': contato,
      'imagem': imagem,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      preco: double.tryParse(map['preco']?.toString() ?? '0') ?? 0.0,
      contato: map['contato']?.toString() ?? '',
      imagem: map['imagem']?.toString() ?? '',
    );
  }
}
