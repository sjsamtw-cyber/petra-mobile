/* 
 * EndPointManager class might look like an overkill here, but can
 * come in handy if we have to perform additional tasks/filtering
 * on endpoints before the url is dispatched.
 * This it helps keep the Endpoints enum clean with just enum -> string mapping
 */

import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoints.dart';

class EndPointManager {
  static String getEndpoint(Endpoint action) {
    // Any other filtering can go here.
    return action.endpointURL;
  }
}
