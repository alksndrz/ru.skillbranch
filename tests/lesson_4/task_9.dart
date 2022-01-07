import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';

import 'model/mocked_models.dart';
import 'task_9.mocks.dart';

///
/// 9. Сверстать состояния SuperheroPageState на экране SuperheroPage
///    1. Добавить обработку состояний, приходящих из метода
///       observeSuperheroPageState()
///    2. Для состояния SuperheroPageState.loaded показывать то, что
///       показывается сейчас
///    3. Для состояния SuperheroPageState.loading показывать AppBar (или
///       SliverAppBar), в котором находится только автоматически проставленная
///       кнопка назад. Показывать indeterminate CircularProgressWidget с
///       отступом сверху (см макеты)
///    4. Для состояния SuperheroPageState.error также показывать AppBar (или
///       SliverAppBar), в котором находится только автоматически проставленная
///       кнопка назад. Кроме этого показывать такой же виджет с Суперменом,
///       текстом и кнопкой, как и на главном экране в состоянии
///       MainPageState.error (см макеты). При нажатии на кнопку с текстом retry
///       должен вызываться метод retry в SuperheroBloc.
///
@GenerateMocks([http.Client])
void runTestLesson4Task9() {
  testWidgets('module9', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final client = MockClient();
      final uriCreator = (superheroId) =>
          Uri.parse("https://superheroapi.com/api/${dotenv.env["SUPERHERO_TOKEN"]}/$superheroId");
      SharedPreferences.setMockInitialValues({"favorite_superheroes": []});

      bool shouldReturnError = true;

      when(client.get(uriCreator(superhero1.id))).thenAnswer(
        (_) async {
          await Future.delayed(Duration(milliseconds: 100));
          if (shouldReturnError) {
            shouldReturnError = false;
            return http.Response(json.encode(superheroResponseWithError.toJson()), 200);
          } else {
            return http.Response(json.encode(superheroResponse1.toJson()), 200);
          }
        },
      );
      await tester.pumpWidget(
        MaterialApp(home: SuperheroPage(id: superhero1.id, client: client)),
      );

      await tester.pump();

      final circularProgressIndicatorFinder = find.byType(CircularProgressIndicator);

      expect(
        circularProgressIndicatorFinder,
        findsOneWidget,
        reason: "There should be a CircularProgressIndicator widget on SuperheroPageState.loading",
      );

      final iconBackFinder1 = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.adaptive.arrow_back);
      expect(
        iconBackFinder1,
        isNotNull,
        reason:
            "There should be an AppBar (or SliverAppBar) with automatically added leading back button",
      );

      await Future.delayed(Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      await tester.idle();

      final infoWithButtonFinder = find.byType(InfoWithButton);
      expect(
        infoWithButtonFinder,
        findsOneWidget,
        reason: "There should be a InfoWithButton widget on the main screen",
      );
      expect(
        tester.widget<InfoWithButton>(infoWithButtonFinder).title,
        "Error happened",
        reason: "There should be a InfoWithButton with title 'Error happened'",
      );

      final actionButtonFinder = find.byType(ActionButton);
      expect(
        actionButtonFinder,
        findsOneWidget,
        reason: "There should be an ActionButton widget on the main screen",
      );
      expect(
        tester.widget<ActionButton>(actionButtonFinder).text,
        "Retry",
        reason: "There should be an ActionButton with test 'Retry'",
      );

      final iconBackFinder2 = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.adaptive.arrow_back);

      expect(
        iconBackFinder2,
        isNotNull,
        reason:
            "There should be an AppBar (or SliverAppBar) with automatically added leading back button",
      );

      await tester.tap(find.text("RETRY"));

      await Future.delayed(Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      await tester.idle();

      final superheroAppBarFinder = find.byType(SuperheroAppBar);

      expect(
        superheroAppBarFinder,
        findsOneWidget,
        reason: "SuperheroAppBar shouldn't be null",
      );
    });
  });
}
