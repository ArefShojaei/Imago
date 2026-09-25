import 'package:river/river.dart';

void logger(Request req, Response res) {
  Console.debug("Method: ${req.method} - Path: ${req.path}");
}
