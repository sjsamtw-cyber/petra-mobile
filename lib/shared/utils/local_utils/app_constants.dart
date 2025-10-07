// This widget is the root of your application.

//import 'package:petra_school_app/models/dashboard_loading_type.dart';
//const DEBUG_ENDPOINT = 'https://petra.test/public/index.php/user/login';
// Easily switch between a secure and a plain text connection
const bool httpsEnabled = true;
/*
 * A clean url takes the form  'https://petra.test'
 * instead of 
 * 'https://petra.test/public/index.php'
 */
const bool clearUrlEnabled = false;

// Special school codes.
const String schoolCodeQA = 'qa';
const String schoolCodeTest = 'test';

// Special domains
const String testDomainSecureClean = 'https://petra.test';
const String testDomainSecureUnclean = 'https://petra.test/public/index.php';
const String testDomainPlainClean = 'http://petra.test';
const String testDomainPlainUnclean = 'http://petra.test/public/index.php';
const String qaDomain = 'https://demo.qa.petrasoft.co.in/public/index.php';

// Timeout app-wide values
const int timeoutSeconds = 300;
