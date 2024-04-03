class Utils {

  static bool controlBool(dynamic data) {
    bool result = false;
    if(data != null) {
      if(data == 1 || data == '1' || data == true || data == 'true') {
        result = true;
      }
    }
    return result;
  }
}
