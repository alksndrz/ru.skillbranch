import 'package:flutter/material.dart';
import 'package:flutter_fight_club/resources/fight_club_colors.dart';

class SecondaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SecondaryActionButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          decoration: BoxDecoration(
              color: FightClubColors.transparent,
              border: Border.all(
                color: FightClubColors.darkGreyText,
                width: 2,
              )),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              color: FightClubColors.darkGreyText,
            ),
          ),
        ),
      ),
    );
  }
}
