import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:superheroes/blocs/superhero_bloc.dart';
import 'package:superheroes/model/superhero.dart';

import '../shared/test_helpers.dart';
import 'model/mocked_models.dart';
import 'model/superhero_response.dart';
import 'task_6.mocks.dart';

///
/// 6. Обновлять модель superhero в сторедже в методе request в SuperheroBloc
///    1. Модель нужно обновлять только если супергерой в данный момент
///       находится в избранном
///    2. Модель нужно именно обновлять, а не добавлять новую запись в список
///       избранных супергероев. Поле, по которому должен производиться поиск и
///       которое должно быть уникальным — superhero.id
///    3. Необходим сохранить позицию избранного супергероя при обновлении в
///       списке избранных супергероев. То есть если у нас было сохранено 2
///       супергероя в избранном, первый с id=70, а второй с id=90, то после
///       обновления супергероя с id=70 он также должен остаться первым в
///       списке.
///    4. Подсказка. Добавьте toString в Superhero, чтобы понимать результаты
///       ошибок в тестировании
///
@GenerateMocks([http.Client])
void runTestLesson4Task6() {
  late BehaviorSubject<List<String>> superheroesSubject;

  setUp(() {
    final reactiveInMemorySP = ReactiveInMemorySharedPreferencesStore.withData(
        {"flutter.favorite_superheroes": <String>[]});

    superheroesSubject = BehaviorSubject<List<String>>.seeded([]);
    reactiveInMemorySP.observeValues().listen((values) {
      final items = values["flutter.favorite_superheroes"] as List<Object?>;
      superheroesSubject.add(items.map((e) => e as String).toList());
    });

    SharedPreferencesStorePlatform.instance = reactiveInMemorySP;
  });

  testWidgets('module6', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        final client = MockClient();
        final uriCreator = (superheroId) => Uri.parse(
            "https://superheroapi.com/api/${dotenv.env["SUPERHERO_TOKEN"]}/$superheroId");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList("favorite_superheroes", []);

        //
        // CASE 1:
        // The superhero is not in favorites before creating SuperheroBloc
        //

        when(client.get(uriCreator(superhero1.id))).thenAnswer(
          (_) async {
            await Future.delayed(Duration(milliseconds: 200));
            return http.Response(json.encode(superheroResponse1.toJson()), 200);
          },
        );

        SuperheroBloc(client: client, id: superhero1.id);

        await expectEmitsInOrderWithTimeoutAndThenDone<List<Superhero>>(
          superheroesSubject.map((rawSuperheroes) => rawSuperheroes
              .map((rawSuperhero) =>
                  Superhero.fromJson(json.decode(rawSuperhero)))
              .toList()),
          [<Superhero>[]],
          reason:
              "If superhero is not in favorite — do not add new models after getting it from API",
        );

        //
        // CASE 2:
        // The superhero is in favorites before creating SuperheroBloc
        //

        await prefs.setStringList("favorite_superheroes", [
          json.encode(superhero2.toJson()),
          json.encode(superhero1.toJson()),
        ]);

        SuperheroBloc(client: client, id: superhero2.id);

        final fakeSuperhero2 = Superhero(
          id: superhero2.id,
          name: superhero3.name,
          biography: superhero3.biography,
          image: superhero3.image,
          powerstats: superhero3.powerstats,
        );

        final fakeSuperheroResponse2 = SuperheroResponse(
          response: "success",
          id: fakeSuperhero2.id,
          name: fakeSuperhero2.name,
          biography: fakeSuperhero2.biography,
          image: fakeSuperhero2.image,
          powerstats: fakeSuperhero2.powerstats,
        );

        when(client.get(uriCreator(superhero2.id))).thenAnswer(
          (_) async {
            await Future.delayed(Duration(milliseconds: 200));
            return http.Response(
                json.encode(fakeSuperheroResponse2.toJson()), 200);
          },
        );

        await expectEmitsInOrderWithTimeoutAndThenDone<List<Superhero>>(
          superheroesSubject.map((rawSuperheroes) => rawSuperheroes
              .map((rawSuperhero) =>
                  Superhero.fromJson(json.decode(rawSuperhero)))
              .toList()),
          [
            <Superhero>[superhero2, superhero1],
            <Superhero>[fakeSuperhero2, superhero1]
          ],
          reason:
              "If superhero is in favorite — replace old model with new one and keep its position",
        );
      });
    });
  });
}

class ReactiveInMemorySharedPreferencesStore
    extends SharedPreferencesStorePlatform {
  /// Instantiates an empty in-memory preferences store.
  ReactiveInMemorySharedPreferencesStore.empty()
      : _subject = BehaviorSubject.seeded(<String, Object>{});

  /// Instantiates an in-memory preferences store containing a copy of [data].
  ReactiveInMemorySharedPreferencesStore.withData(Map<String, Object> data)
      : _subject = BehaviorSubject.seeded(Map<String, Object>.from(data));

  final BehaviorSubject<Map<String, Object>> _subject;

  Stream<Map<String, Object>> observeValues() => _subject;

  @override
  Future<bool> clear() async {
    _subject.add({});
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    print("GET ALL CALLED");
    return Map<String, Object>.from(_subject.value);
  }

  @override
  Future<bool> remove(String key) async {
    _subject.add(Map<String, Object>.from(_subject.value)..remove(key));
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    print("SET VALUE CALLED: $key, $value");
    _subject.add(Map<String, Object>.from(_subject.value)..[key] = value);
    return true;
  }
}
