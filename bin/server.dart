import 'package:imago/app.dart';
import 'package:river/river.dart';

void main(List<String> args) async {
  final app = await River.createHttpServer();

  final controller = ImageController(
    imageService: ImageService(),
    exifService: ExifService(),
  );

  app.use(logger);

  app.get('/', controller.info);
  app.post('/exif', controller.exif);
  app.get('/health', controller.health);
  app.post('/clean', controller.clean);
  app.post('/secure', controller.secure);

  await app.listen();
}
