import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/blocs/superhero_bloc.dart';
import 'package:superheroes/model/superhero.dart';

import '../shared/test_helpers.dart';
import 'model/mocked_models.dart';
import 'model/search_response.dart';
import 'model/superhero_response.dart';
import 'task_5.mocks.dart';

///
/// 5. Дорабатываем логику с обновлением супергероев в SuperheroBloc
///    1. Если мы переходим на страницу избранного супергероя, а затем получаем
///       модель с супергероем через API, то сейчас метод observeSuperhero()
///       вернет нам два супергероя, хотя они на самом деле одинаковые.
///    2. Сделать так, чтобы если супергерой вернулся из API такой же, то метод
///       observeSuperhero() не выдавал еще одну модель
///    3. Если из API вернулся другой (хотя бы одно поле другое), то метод
///       observeSuperhero() должен выдать обновленную модель
///
@GenerateMocks([http.Client])
void runTestLesson4Task5() {

  testWidgets('module5', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        final client = MockClient();
        final uriCreator = (superheroId) =>
            Uri.parse("https://superheroapi.com/api/${dotenv.env["SUPERHERO_TOKEN"]}/$superheroId");

        //
        // CASE 1: server returns the same superhero response
        //
        SharedPreferences.setMockInitialValues({
          "favorite_superheroes": [json.encode(superhero1.toJson())],
        });

        when(client.get(uriCreator(superhero1.id))).thenAnswer(
              (_) async => http.Response(json.encode(superheroResponse1.toJson()), 200),
        );

        final bloc1 = SuperheroBloc(client: client, id: superhero1.id);

        await expectEmitsInOrderWithTimeoutAndThenDone(
          bloc1.observeSuperhero().map((superhero) =>superhero.toJson().toString()),
          [superhero1.toJson().toString()],
          reason: "If API returns the same superhero as already saved in the storage,"
              " observeSuperhero() method should not push new model",
        );

        //
        // CASE 2: server returns different superhero response
        //

        SharedPreferences.setMockInitialValues({
          "favorite_superheroes": [json.encode(superhero1.toJson())],
        });

        final fakeSuperhero = Superhero(
          id: superhero1.id,
          name: superhero2.name,
          biography: superhero2.biography,
          image: superhero2.image,
          powerstats: superhero2.powerstats,
        );

        final fakeSuperheroResponse = SuperheroResponse(
          response: "success",
          id: fakeSuperhero.id,
          name: fakeSuperhero.name,
          biography: fakeSuperhero.biography,
          image: fakeSuperhero.image,
          powerstats: fakeSuperhero.powerstats,
        );

        when(client.get(uriCreator(fakeSuperhero.id))).thenAnswer(
              (_) async => http.Response(json.encode(fakeSuperheroResponse.toJson()), 200),
        );

        final bloc2 = SuperheroBloc(client: client, id: superhero1.id);

        await expectEmitsInOrderWithTimeoutAndThenDone(
          bloc2.observeSuperhero().map((superhero) =>superhero.toJson().toString()),
          [superhero1.toJson().toString(), fakeSuperhero.toJson().toString()],
          reason: "If API returns different to already saved in the storage superhero,"
              " observeSuperhero() method should push new model",
        );
      });
    });
  });
}
