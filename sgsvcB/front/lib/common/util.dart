Uri getUri(String addr, String path) {
  var url = '$addr/$path';

  while (url.contains("//")) {
    url = url.replaceAll('//', "/");
  }

  return Uri.parse(url);
}
