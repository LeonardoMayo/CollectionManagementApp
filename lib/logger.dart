class Logger {

  String _className;

  Logger(String className){
    _className = className;
  }

  void log(String message){
    print(_className +":"+message);
  }

  void logError(String error){
    print ("ERROR! "+_className+":"+error);
  }

}