import '../../models/anuncio.dart';
import 'database_helper.dart';

class AnuncioHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> salvarAnuncio(Anuncio anuncio) async {
    final db = await _dbHelper.db;
    return await db.insert('anuncios', anuncio.toMap());
  }

  Future<List<Anuncio>> listarAnuncios() async {
    final db = await _dbHelper.db;
    var resultado = await db.query('anuncios', orderBy: 'id DESC');

    if (resultado.isEmpty) {
      final padroes = [
        Anuncio(
          titulo: 'Smart TV 50" Crystal UHD 4K Samsung',
          descricao:
              'Processador Crystal 4K, Tela sem limites, Alexa built-in.',
          preco: 2299.00,
          imagem: 'assets/tv.png',
          contato: '(11) 99999-8888',
        ),
        Anuncio(
          titulo: 'Smartphone Samsung Galaxy A54 128GB',
          descricao: '5G 8GB RAM Câmera Tripla Traseira de 50MP.',
          preco: 1499.00,
          imagem: 'assets/celular.jpg',
          contato: '(11) 98888-7777',
        ),
        Anuncio(
          titulo: 'Notebook Dell Inspiron 15 Intel Core i5',
          descricao: '8GB RAM 256GB SSD Tela 15.6" Full HD Windows 11.',
          preco: 2899.90,
          imagem: 'assets/notebook.jpg',
          contato: '(11) 97777-6666',
        ),
      ];

      for (final item in padroes) {
        await db.insert('anuncios', item.toMap());
      }
      resultado = await db.query('anuncios', orderBy: 'id DESC');
    }

    return resultado.map((map) => Anuncio.fromMap(map)).toList();
  }

  Future<int> atualizarAnuncio(Anuncio anuncio) async {
    final db = await _dbHelper.db;
    return await db.update(
      'anuncios',
      anuncio.toMap(),
      where: 'id = ?',
      whereArgs: [anuncio.id],
    );
  }

  Future<int> deletarAnuncio(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'anuncios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
