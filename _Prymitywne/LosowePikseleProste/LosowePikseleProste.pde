/* Proste zastosowanie losowania i grafiki */
/* PRZETŁUMACZONE Z APLIKACJI Delphi NA Processing ZA POMOCĄ GEMINI */

int width_val = 400;
int height_val = 400;

void settings() {
  size(width_val + 1, height_val + 1);
}

void setup() {
  background(255); /* Tło, aby punkty były dobrze widoczne */
  frameRate(9999);
}

void dodaj_punkt() {
   int x, y;
   x = int(random(width_val));
   y = int(random(height_val));
   point(x, y);
}

void wylosuj_kolor() {
   int r, g, b;
   r = int(random(256));
   g = int(random(256));
   b = int(random(256));
   stroke(r, g, b); /* Odpowiednik procedury Pen z biblioteki Algo */
}

void draw() {
  /* Zamiast nieskończonej pętli While z procedury Main, wykorzystujemy główną pętlę draw() */
  wylosuj_kolor();
  dodaj_punkt();
}
