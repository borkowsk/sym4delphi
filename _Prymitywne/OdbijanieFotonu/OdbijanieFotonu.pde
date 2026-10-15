/* Odbijanie "fotonu" - kliknij w okno żeby przerwać */
/* PRZETŁUMACZONE Z APLIKACJI Delphi NA Processing ZA POMOCĄ GEMINI */

int width_val = 500;
int height_val = 555;
int DELA = 2; /* Nie więcej niż 1000 msec */

int x, y;
int vx, vy;
boolean isRunning = true;

void settings() {
  size(width_val, height_val);
}

void setup() {
  background(255);
  rect(0, 0, width_val, height_val); /* Pudelko - mniej więcej */

  /* Inicjacja pozycji i prędkości */
  x = width_val / 2;
  y = height_val / 2;
  vx = 2 - int(random(5));
  vy = 2 - int(random(5));
  stroke(0);
  point(x, y);
  /* SPOWOLNIENIE DLA OBSERWACJI METODĄ NATURALNĄ DLA Processingu*/
  int fr=int(1000/DELA);
  frameRate(fr); //<>//
}

void draw() {
  if (!isRunning) {
    println("KONIEC");
    noLoop();
    return;
  }

  /* Pętla "dynamiki" */
  x = x + vx; /* przemieszczanie po X */
  y = y + vy; /* przemieszczanie po Y */

  line(x - vx, y - vy, x, y); /* Lineto w Processing wymaga punktu początkowego i końcowego */

  if (int(random(100)) == 0) { /* Czasem zmiana koloru */
     stroke(random(255), random(255), random(255));
  }

  /* Wykrywanie odbicia */
  if ((x <= 0) || (x > width_val)) {
      vx = -vx;
  }
  if ((y <= 0) || (y > height_val)) {
      vy = -vy;
  }

}

void mousePressed() {
  /* Odpowiednik IsEvent / kliknięcia myszą w okno przerywający działanie */
  isRunning = false;
}
