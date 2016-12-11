#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

const char* ssid = "paprika2";
const char* password = "XXX";

const char* newssid = "soft_ap";
const char* newpassword = "12345678";

const char* host = "jsonplaceholder.typicode.com";
const int host_port = 80;

ESP8266WebServer gWebServer(80);

int count = 0;

void setup(void){
  Serial.begin(115200);
  Serial.println("");

  // set both access point and station
  WiFi.mode(WIFI_AP_STA);
  
  WiFi.softAP(newssid, newpassword);

  Serial.print(newssid);
  Serial.print(" server ip: ");
  Serial.println(WiFi.softAPIP());

  gWebServer.on("/", handleRoot);  
  gWebServer.onNotFound(handleNotFound);  
  gWebServer.begin();
  Serial.println("HTTP server started");

  if (strcmp (WiFi.SSID().c_str(),ssid) != 0) {
      Serial.print("Connecting to ");
      Serial.println(ssid);
      WiFi.begin(ssid, password);
  }

  while (WiFi.status() != WL_CONNECTED) {
    yield();
  }

  Serial.print("Connected to: ");
  Serial.print(WiFi.SSID());
  Serial.print(", IP address: ");
  Serial.println(WiFi.localIP());
}
 
void loop(void){
  gWebServer.handleClient();
}

void handleRoot() {
  Serial.print("handleRoot: ");
  Serial.println(count);
  String s = "request count: ";
  s += ++count;
  gWebServer.send(200, "text/plain", s);

  // test redirect to some website ?

  
}

void handleNotFound() {
  Serial.print("proxy request to ");
  Serial.println(host);
  
  count++;

  WiFiClient client;
  while (!client.connect(host, host_port )) {
    Serial.println("connection failed, retrying...");
    delay(500);
  }

  Serial.print("Requesting uri: ");
  String requestUri = gWebServer.uri();

  // TODO: an easier way to get the request url?
  if (gWebServer.args() > 0) {
     requestUri += "?";
     for (int i = 0; i < gWebServer.args(); i++) {
        requestUri += gWebServer.argName(i);
        requestUri += "=";
        requestUri += gWebServer.arg(i);
        if (i+1 < gWebServer.args()) {
           requestUri += "&";
        }
     }
  }
  Serial.println(requestUri);

  client.print(String("GET ") + requestUri);
  
  client.print(String(" HTTP/1.1\r\n") +
               "Host: " + host + "\r\n" + 
               "Connection: close\r\n\r\n");



  // protect against timeout
  unsigned long timeout = millis();
  while (client.available() == 0) {
    if (millis() - timeout > 5000) {
      Serial.println(">>> Client Timeout !");
      client.stop();
      return;
    }
  }

  // Read all the lines of the reply from server and print them to Serial
  String response = "";
  while(client.available()) {
    String line = client.readStringUntil('\r');
    response += line;
    //Serial.print(line);
  }

  Serial.println(response);

  String body = response.substring(response.indexOf("\n\n"));
  Serial.println("====== BODY ==========");
  Serial.println(body);
  gWebServer.send(200, "application/json; charset=utf-8", body);

  client.stop();
}
