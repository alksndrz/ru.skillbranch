import 'package:flutter/material.dart';
import 'package:flutter_fight_club/fight_result.dart';
import 'package:flutter_fight_club/resources/fight_club_colors.dart';
import 'package:flutter_fight_club/resources/fight_club_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FightResultWidget extends StatelessWidget {
  final FightResult fightResult;

  const FightResultWidget({
    Key? key,
    required this.fightResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ColoredBox(color: Colors.white)),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      FightClubColors.darkPurple,
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: ColoredBox(color: FightClubColors.darkPurple)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  "You",
                  style: TextStyle(color: Color(0xFF161616)),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  FightClubImages.youAvatar,
                  width: 92,
                  height: 92,
                ),
              ],
            ),
            SizedBox(
              height: 44,
              width: 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(22),
                    color: FightClubColors.blueButton),
                child: Center(
                  child: FutureBuilder<String?>(
                    future: SharedPreferences.getInstance().then(
                      (sharedPreferences) =>
                          sharedPreferences.getString("last_fight_result"),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return SizedBox();
                      }
                      return Center(
                        child: Container(
                            child: Text(
                          snapshot.data!.toLowerCase(),
                          style: TextStyle(
                              fontSize: 16, color: FightClubColors.whiteText),
                        )),
                      );
                    },
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  "Enemy",
                  style: TextStyle(color: Color(0xFF161616)),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  FightClubImages.enemyAvatar,
                  width: 92,
                  height: 92,
                ),
              ],
            ),
          ],
        )
      ]),
    );
  }
}
