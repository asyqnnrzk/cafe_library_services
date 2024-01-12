class API {
  // need to change the ip address when using different wifi connection
  // home wifi = 192.168.0.120
  // utem wifi = 10.131.76.187
  static const hostConnect = "http://10.131.76.187/cafeLibraryServices-"
      "develop/public/api";
  static const hostConnectUser = "$hostConnect";
  // static const register = "$hostConnect/register";
  // static const login = "$hostConnect/login";
  static const library = "$hostConnect/library.php";
  //static const announcement = "$hostConnect/announcement_listing";
  //static const book = "$hostConnect/book_listing";

  static const register = "$hostConnect/registration.php";
  static const login = "$hostConnect/login.php";
  static const localHost = "http://10.131.76.187/api/";
  static const announcement = "$localHost/announcements.php";
  static const book = "$localHost/books.php";
  static const beverage = "$localHost/beverages.php";
  static const equipment = "$localHost/equipments.php";
  static const room = "$localHost/rooms.php";
  static const table = "$localHost/tables.php";
  static const booking = "$localHost/bookings.php";
  static const penalty = "$localHost/penalties.php";
  static const order = "$localHost/orders.php";
}