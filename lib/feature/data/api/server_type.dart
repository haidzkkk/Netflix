
enum ServerType{
  kkPhim("kkPhim"),
  oPhim("oPhim")
  ;

  final String id;
  const ServerType(this.id);

  static ServerType? getServerType(String id){
    switch(id){
      case "kkPhim": {
        return ServerType.kkPhim;
      }
      case "oPhim": {
        return ServerType.oPhim;
      }
    }
    return null;
  }
}
