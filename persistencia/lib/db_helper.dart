import 'package:hive_flutter/hive_flutter.dart';
import 'tarefa.dart';

class DBHelper {
  static const String _boxName = 'anuncios_box';

  static Future<Box> _pegarBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static Future<int> salvarAnuncio(Tarefa tarefa) async {
    final box = await _pegarBox();
    if (tarefa.id != null && box.containsKey(tarefa.id)) {
      await box.put(tarefa.id, tarefa.toMap());
      return tarefa.id!;
    } else {
      int id = await box.add(tarefa.toMap());
      tarefa.id = id;
      await box.put(id, tarefa.toMap());
      return id;
    }
  }

  static Future<int> atualizarAnuncio(Tarefa tarefa) async {
    return await salvarAnuncio(tarefa);
  }

  static Future<List<Tarefa>> listarAnuncios() async {
    final box = await _pegarBox();
    List<Tarefa> lista = [];

    for (var key in box.keys) {
      final item = box.get(key);
      if (item != null) {
        try {
          final map = Map<String, dynamic>.from(item as Map);
          map['id'] = key;
          lista.add(Tarefa.fromMap(map));
        } catch (e) {
          // Ignora item inválido
        }
      }
    }

    lista.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return lista;
  }

  static Future<int> deletarAnuncio(int id) async {
    final box = await _pegarBox();
    await box.delete(id);
    return 1;
  }

  static Future<void> limparBanco() async {
    final box = await _pegarBox();
    await box.clear();
  }
}
