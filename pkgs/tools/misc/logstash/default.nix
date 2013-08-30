{ fetchurl }:

let version = "1.1.13"; in

fetchurl {
  url = "https://logstash.objects.dreamhost.com/release/logstash-${version}-flatjar.jar";

  name = "logstash-${version}.jar";

  sha256 = "1wa73rg8bdhhwa8kd7c5fdjpm6di0rqbs13a9wm4q1nsyjgn782v";
}
