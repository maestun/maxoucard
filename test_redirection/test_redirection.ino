#include <ESP8266WiFi.h>
 
const char* ssid = "paprika2";
const char* password = "WIFI12Stones";
 
WiFiServer localServer(80);

const char* remoteHost = "www.nytimes.com";

char buffer[1024];
 
void setup() {
  Serial.begin(115200);
  delay(10);
   
  // Connect to WiFi network   
  WiFi.begin(ssid, password);
   
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
   
  // Start the server
  localServer.begin();

  // Print the IP address
  Serial.print("Started. Connect to: http://");
  Serial.print(WiFi.localIP());
    
}
 
void loop() {
  // Check if a client browser has connected
  WiFiClient browserClient = localServer.available();
  if (!browserClient) {
    return;
  }
   
  // Wait until the client browser sends some data
  Serial.println("Serving request");
  while(!browserClient.available()){
    delay(1);
  }

  // Read the first line of the request (and ignore it)
  String request = browserClient.readStringUntil('\r');
  Serial.println("Request is " + request);
  browserClient.flush();
   
  // Connect to the real server
  WiFiClient client;
  Serial.println("Connecting to remote server");
  if (!client.connect(remoteHost, 80)) {
    // Error connecting to real server
    Serial.println("Error contacting remote server");
    return;
  }
  
  Serial.println("connected");
  // Make a HTTP request:
  client.println(String("GET / HTTP/1.1\r\n") +
             "Host: " + remoteHost + "\r\n" + 
             "Connection: close\r\n\r\n");  
  Serial.println("Request sent");
  
  // Wait for response
  while(!client.available()){
    delay(1);
  }
  Serial.println("Client available");

  // And forward it to the browser
  while (client.available()) {
    int bytesRead = client.readBytes(buffer, sizeof(buffer));
    Serial.print(bytesRead);
    Serial.println(" bytes read");
    browserClient.write((const char*)buffer, bytesRead);
  }
  Serial.println("Response sent");
  
  delay(1);
  Serial.println("BrowserClient served"); 
}
 
