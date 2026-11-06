import 'package:flutter_test/flutter_test.dart';
import 'package:app_anuncio/main.dart';

void main() {
  testWidgets('Carregamento inicial do aplicativo Magalu', (WidgetTester tester) async {
    // Carrega o widget principal correto do projeto
    await tester.pumpWidget(const MeuAppListas());

    // Aguarda a renderização da interface
    await tester.pumpAndSettle();

    // Verifica se o texto do topo da HomeScreen é exibido na tela
    expect(find.text('Tem no Magalu!'), findsOneWidget);
  });
}