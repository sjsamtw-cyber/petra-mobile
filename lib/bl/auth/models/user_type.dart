// ignore_for_file: constant_identifier_names

import 'package:petrasoft_school_management_solutions/bl/auth/models/user_roles.dart';

enum UserType {
  ADMIN, // Will have a human readable name of 'Admin' and ID of 0
  STUDENT, // Will have a human readable name of 'Student' and ID of 1
  PARENT, // Will have a human readable name of 'Parent' and ID of 2
  TEACHER, // Will have a human readable name of 'Teacher' and ID of 3
  GUARDIAN, // Will have a human readable name of 'Guardian' and ID of 4
  NONTEACHINGSTAFF, // Will have a human readable name of 'Nonteachingstaff' and ID of 5
  NOBODY, // Will have a human readable name of 'Nobody' and ID of -1
}
/*
    User Types in Petra EMS(For reference)
    public static $UNDEFINED = -1; // Substituted by Nobody.
    public static $ADMIN = 0;
    public static $STUDENT = 1;
    public static $PARENT = 2;
    public static $TEACHER = 3;
    public static $GUARDIAN = 4;
    public static $NONTEACHINGSTAFF = 5;
*/

extension UserTypeDetails on UserType {
  String get name {
    switch (this) {
      case UserType.ADMIN:
        return "Admin";
      case UserType.STUDENT:
        return "Student";
      case UserType.PARENT:
        return "Parent";
      case UserType.TEACHER:
        return "Teacher";
      case UserType.GUARDIAN:
        return "Guardian";
      case UserType.NONTEACHINGSTAFF:
        return "Non-Teachnig Staff";
      case UserType.NOBODY:
        return "Nobody";
    }
  }

  int get index {
    switch (this) {
      case UserType.ADMIN:
        return 0;
      case UserType.STUDENT:
        return 1;
      case UserType.PARENT:
        return 2;
      case UserType.TEACHER:
        return 3;
      case UserType.GUARDIAN:
        return 4;
      case UserType.NONTEACHINGSTAFF:
        return 5;
      case UserType.NOBODY:
        return -1;
      // ignore: unreachable_switch_default
      default:
        return -1;
    }
  }

  List<UserRole> get roles {
    switch (this) {
      case UserType.ADMIN:
        return [UserRole.admin, UserRole.financialAdmin];
      case UserType.PARENT:
        return [UserRole.parent];
      default:
        return [UserRole.nobody];
    }
  }
}
