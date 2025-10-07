/*
* Below is how it is done in Laravel
    public static $MALE = 1;
    public static $FEMALE = 2;
    public static $TRANSGENDER = 3;
    public static $AGENDER = 4;
    public static $NOTKNOWN = -1;
*/
enum UserGender { male, female, transgender, agender, notKnown }

extension UserGenderDetails on UserGender {
  String get name {
    switch (this) {
      case UserGender.male:
        return "Male";
      case UserGender.female:
        return "Female";
      case UserGender.transgender:
        return "Transgender";
      case UserGender.agender:
        return "Agender";
      case UserGender.notKnown:
        return 'Not Provided';
      // ignore: unreachable_switch_default
      default:
        return 'Not Provided';
    }
  }

  // Convenience Function
  static UserGender getGenderFromNumber(int number) {
    switch (number) {
      case 1:
        return UserGender.male;
      case 2:
        return UserGender.female;
      case 3:
        return UserGender.transgender;
      case 4:
        return UserGender.agender;
      default:
        return UserGender.notKnown;
    }
  }
}
