
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'lesson_4/task_1.dart';
import 'lesson_4/task_2.dart';
import 'lesson_4/task_3.dart';
import 'lesson_4/task_4.dart';
import 'lesson_4/task_5.dart';
import 'lesson_4/task_6.dart';
import 'lesson_4/task_7.dart';
import 'lesson_4/task_8.dart';
import 'lesson_4/task_9.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  await dotenv.load(fileName: ".env");
  group("l08h01", () => runTestLesson4Task1());
  group("l08h02", () => runTestLesson4Task2());
  group("l08h03", () => runTestLesson4Task3());
  group("l08h04", () => runTestLesson4Task4());
  group("l08h05", () => runTestLesson4Task5());
  group("l08h06", () => runTestLesson4Task6());
  group("l08h07", () => runTestLesson4Task7());
  group("l08h08", () => runTestLesson4Task8());
  group("l08h09", () => runTestLesson4Task9());
}
