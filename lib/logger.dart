class Logger {

  String _className;

  Logger(String className){
    _className = className;
  }

  void log(String message){
    print(_className +": "+message);
  }

  void logM(String method, Object argumentType,Object arguments){
    String result = method + "Method";
    if (argumentType != null){
      result = result + " with " + argumentType.toString() +" "+ arguments.toString();
    }
    print(result);
  }

  void logError(String error){
    print ("ERROR! "+_className+":"+error);
  }

}