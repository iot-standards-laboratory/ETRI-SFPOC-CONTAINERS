String getURL(String path) {
  var url = '${Uri.base.path}/$path';

  while (url.contains("//")) {
    url = url.replaceAll('//', "/");
  }

  return url;
}
