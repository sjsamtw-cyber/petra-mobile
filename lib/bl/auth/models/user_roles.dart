/* 
    User Roles in  Petra EMS(For reference)
    public static $UNDEFINED = -1; //NOBODY
    public static $ADMIN = 0;
    public static $STUDENT = 1;
    public static $PARENT = 2;
    public static $TEACHER = 3;
    public static $GUARDIAN = 4;
    public static $NONTEACHINGSTAFF = 5;
    public static $PRINCIPAL = 6;
    public static $CANDTEACHER = 7;
    public static $FINADMIN = 8; 
    */

// A User type can have multiple roles
/*
 * User Roles can be dynamically added. so there are limitatation in setting it this way.
 * Instead we may have to query those from the database.
 */
enum UserRole {
  admin,
  financialAdmin,
  student,
  parent,
  teacher,
  guardian,
  nonTeachingStaff,
  principal,
  candidateTeacher,
  nobody,
}
