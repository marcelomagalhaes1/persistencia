import 'package:flutter_test/flutter_test.dart';
import 'package:app_anuncios_correcao/main.dart';

void main() {
  testWidgets('Carregamento inicial do aplicativo Magalu',
      (WidgetTester tester) async {
    // Garantir a inicialização dos bindings de teste
    TestWidgetsFlutterBinding.ensureInitialized();

    // Carrega o widget principal correto do projeto (MyApp)
    await tester.pumpWidget(const MyApp());

    // Processa a renderização do primeiro frame da interface
    await tester.pump();

    // Verifica se o texto do topo da HomeScreen é exibido na tela
    expect(find.text('Tem no Magalu!'), findsOneWidget);
  });
}
