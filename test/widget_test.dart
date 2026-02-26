import 'package:first_flutter/data/models/sentence.dart';
import 'package:first_flutter/data/repositories/authentication_repository.dart';
import 'package:first_flutter/data/services/authentication_service.dart';
import 'package:first_flutter/presentation/viewmodels/login_vm.dart';
import 'package:first_flutter/presentation/viewmodels/profile_vm.dart';
import 'package:first_flutter/presentation/viewmodels/sentence_creation_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:first_flutter/main.dart';
import 'package:first_flutter/data/repositories/sentence_repository.dart';
import 'package:first_flutter/data/services/sentence_service.dart';

void main() {
  Widget creadorProviders() {
    return MultiProvider(
      providers: [
        Provider<ISentenceService>(
          create: (context) =>
              FakeSentenceService(), // ISentenceService instance
        ),
        Provider<IAuthenticationService>(
          create: (context) =>
              AuthenticationService(), // ILoginService instance
        ),
        Provider<ISentenceRepository>(
          create: (context) => SentenceRepository(
            sentenceService: context.read(),
          ), //ISentenceRepository instance
        ),
        ChangeNotifierProvider<IAuthenticationRepository>(
          create: (context) => AuthenticationRepository(
            authenticationService: context.read(),
          ), //ILoginRepository instance
        ),
        ChangeNotifierProvider<SentenceCreationVM>(
          create: (context) =>
              SentenceCreationVM(sentenceRepository: context.read()),
        ),
        ChangeNotifierProvider<LoginVM>(
          create: (context) =>
              LoginVM(authenticationRepository: context.read()),
        ),
        ChangeNotifierProvider<ProfileVM>(
          create: (context) =>
              ProfileVM(authenticationRepository: context.read()),
        ),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('Test mostra frase inicial', (WidgetTester tester) async {
    // Creem l'aplicació amb els providers
    await tester.pumpWidget(creadorProviders());

    await tester.pumpAndSettle();

    expect(find.text('Test sentence'), findsOneWidget);
  });

  testWidgets('Test clicar botó Next', (WidgetTester tester) async {
    await tester.pumpWidget(creadorProviders());
    await tester.pumpAndSettle();

    // Busquem el botó Next i el cliquem
    final nextButton = find.text('Next');
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    //La frase encara hi és (perquè el mock sempre retorna el mateix)
    expect(find.text('Test sentence'), findsNWidgets(2));
  });

  testWidgets('Test troba botó fav i icona', (WidgetTester tester) async {
    await tester.pumpWidget(creadorProviders());
    await tester.pumpAndSettle();

    final favoriteButton = find.text('Like');
    expect(favoriteButton, findsOneWidget);
    final favoriteIcon = find.byIcon(Icons.favorite_border);
    expect(favoriteIcon, findsOneWidget);
  });

  testWidgets('Clica botó favorit', (WidgetTester tester) async {
    await tester.pumpWidget(creadorProviders());
    await tester.pumpAndSettle();

    final favoriteButton = find.text('Like');
    expect(favoriteButton, findsOneWidget);
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    // The icon should change to favorite (filled).
    // There are 2 instance of Icons.favorite (one in nav, one in button)
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));
  });

  testWidgets('Actualització historial de paraules', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(creadorProviders());
    await tester.pumpAndSettle();

    //Fem clic al botó de next
    final nextButton = find.text('Next');
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    //Comprovem si a l'historial de paraules hi han icones de favorits
    final historyTile = find.byType(ListTile);
    expect(historyTile, findsOneWidget);
  });
}

class FakeSentenceService implements ISentenceService {
  final _sentence = Sentence(text: 'Test sentence');

  @override
  Future<Sentence> getNext() async {
    // Retornem una frase fixa, sense HTTP!
    return _sentence; // Return same instance
  }

  @override
  Future<Sentence> createSentence(String text) async {
    return Sentence(text: text);
  }
}
