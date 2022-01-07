import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/blocs/superhero_bloc.dart';

import '../shared/test_helpers.dart';
import 'model/mocked_models.dart';
import 'task_8.mocks.dart';

///
/// 8. Добавить метод void retry() в Superhero
///    1. При вызове этого метода должен осуществляться новый запрос на
///       получение данных о текущем супергерое в API.
///    2. В начале запроса выдавать состояние в observeSuperheroPageState()
///       SuperheroPageState.loading
///    3. В случае успешного запроса (получили правильные коды, получили модель
///       супергероя) выдавать состояние в observeSuperheroPageState()
///       SuperheroPageState.loaded и передавать полученного супергероя в методе
///       observeSuperhero()
///    4. В случае неуспешного запроса (код с ошибкой или же успешный ответ, но
///       с ошибкой) выдавать состояние в observeSuperheroPageState()
///       SuperheroPageState.error
///
@GenerateMocks([http.Client])
void runTestLesson4Task8() {

  testWidgets('module8', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        final client = MockClient();
        final uriCreator = (superheroId) =>
            Uri.parse("https://superheroapi.com/api/${dotenv.env["SUPERHERO_TOKEN"]}/$superheroId");

        SharedPreferences.setMockInitialValues({"favorite_superheroes": []});

        ///
        /// CASE 1:
        /// First request returns error.
        /// Retry returns successful response.
        /// Checking SuperheroPageState
        ///

        bool shouldReturnError1 = true;

        when(client.get(uriCreator(superhero1.id))).thenAnswer(
          (_) async {
            if (shouldReturnError1) {
              shouldReturnError1 = false;
              return http.Response(json.encode({}), 400);
            } else {
              await Future.delayed(Duration(milliseconds: 100));
              return http.Response(json.encode(superheroResponse1.toJson()), 200);
            }
          },
        );

        final bloc1 = SuperheroBloc(client: client, id: superhero1.id);

        await Future.delayed(Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.idle();

        bool needToRetry1 = true;

        await expectEmitsInOrderWithTimeoutAndThenDone(
          bloc1.observeSuperheroPageState().doOnData((event) {
            if (needToRetry1) {
              needToRetry1 = false;
              bloc1.retry();
            }
          }),
          [SuperheroPageState.error, SuperheroPageState.loading, SuperheroPageState.loaded],
          reason: "You come to page and get error from api. Then you call retry method. "
              "It should change state to SuperheroPageState.loading. You get successful response. "
              "After that you should change state to SuperheroPageState.loaded",
        );

        ///
        /// CASE 2:
        /// First request returns error.
        /// Retry returns error response.
        /// Checking SuperheroPageState
        ///

        when(client.get(uriCreator(superhero2.id))).thenAnswer(
          (_) async {
            await Future.delayed(Duration(milliseconds: 100));
            return http.Response(json.encode({}), 400);
          },
        );

        final bloc2 = SuperheroBloc(client: client, id: superhero2.id);

        await Future.delayed(Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.idle();

        bool needToRetry2 = true;

        await expectEmitsInOrderWithTimeoutAndThenDone(
          bloc2.observeSuperheroPageState().doOnData((event) {
            if (needToRetry2) {
              needToRetry2 = false;
              bloc2.retry();
            }
          }),
          [SuperheroPageState.error, SuperheroPageState.loading, SuperheroPageState.error],
          reason: "You come to page and get error from api. Then you call retry method. "
              "It should change state to SuperheroPageState.loading. You get error response. "
              "After that you should change state to SuperheroPageState.error",
        );

        ///
        /// CASE 3:
        /// First request returns error.
        /// First retry returns error response.
        /// Second retry returns successful response.
        /// Checking SuperheroPageState
        ///

        int retries = 0;
        final responsesWithError = 2;
        when(client.get(uriCreator(superhero3.id))).thenAnswer(
          (_) async {
            await Future.delayed(Duration(milliseconds: 100));
            if (retries < responsesWithError) {
              retries++;
              return http.Response(json.encode({}), 400);
            } else {
              return http.Response(json.encode(superheroResponse3.toJson()), 200);
            }
          },
        );

        final bloc3 = SuperheroBloc(client: client, id: superhero3.id);

        await Future.delayed(Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.idle();

        await expectEmitsInOrderWithTimeoutAndThenDone(
          bloc3.observeSuperheroPageState().doOnData((state) {
            if (state == SuperheroPageState.error) {
              bloc3.retry();
            }
          }),
          [
            SuperheroPageState.error,
            SuperheroPageState.loading,
            SuperheroPageState.error,
            SuperheroPageState.loading,
            SuperheroPageState.loaded,
          ],
          reason: "You come to page and get error from api. Then you call retry method. "
              "It should change state to SuperheroPageState.loading. You get error response. "
              "After that you should change state to SuperheroPageState.error. "
              "Then you retry one more time. You got successful response. "
              "After that you should change state to SuperheroPageState.loaded",
        );

        ///
        /// CASE 4:
        /// First request returns error.
        /// Retry returns error response.
        /// Checking Superhero
        ///

        bool shouldReturnError4 = true;

        when(client.get(uriCreator(superhero4.id))).thenAnswer(
          (_) async {
            if (shouldReturnError4) {
              shouldReturnError4 = false;
              return http.Response(json.encode({}), 400);
            } else {
              await Future.delayed(Duration(milliseconds: 100));
              return http.Response(json.encode(superheroResponse4.toJson()), 200);
            }
          },
        );

        final bloc4 = SuperheroBloc(client: client, id: superhero4.id);

        await Future.delayed(Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.idle();

        bloc4.retry();

        await expectEmitsInOrderWithTimeoutAndThenDone(
          bloc4.observeSuperhero(),
          [superhero4],
          reason: "You come to page and get error from api. Then you call retry method. "
              "You get successful response. After that you should add superhero to "
              "observeSuperhero() method",
        );
      });
    });
  });
}
