/* Losowe błądzenie w obcym środowisku ;-) */
/* PRZETŁUMACZONE Z APLIKACJI Delphi NA Processing ZA POMOCĄ GEMINI */

int s = 500;
int last = 100;

int x, y, r, g, b, i, licznik, min, max, sum;
boolean finished = false;

void settings() {
  size(s + 10, s + 100);
}

void setup() {
  background(255);
  frameRate(2999);
  sum = 0;
  max = 0;
  min = 0;
  i = 1;

  ellipseMode(CORNER);
  stroke(0);
  noFill();
  ellipse(0, 0, s - 1, s - 1); /* obszar pomiaru [cite: 8] */

  resetWalk();
}

void resetWalk() {
  licznik = 0;
  r = int(random(256));
  g = int(random(256));
  b = int(random(256));

  x = s / 2;
  y = s / 2;
}

double distance(double x1, double y1, double x2, double y2) {
  return sqrt(sq((float)(x1 - x2)) + sq((float)(y1 - y2)));
}

void draw() {
  if (finished) return;

  if (i <= last) {
    /* Rysowanie punktu b\u0142\u0105dzenia */
    stroke(r, g, b);
    point(x, y);

    /* Wyczyszczenie i wypisanie licznika krok�w u g�ry */
    fill(255);
    noStroke();
    rect(0, 0, 150, 20);
    fill(0);
    textSize(12);
    text("Krok: " + licznik, 0, 15); /* write('Krok: ',licznik,' '); [cite: 8] */

    /* Losowy krok */
    x = x + int(random(3)) - 1;
    y = y + int(random(3)) - 1;
    licznik = licznik + 1;

    /* Sprawdzenie czy wyszed\u0142 poza obszar pomiaru */
    if (distance(x, y, s / 2.0, s / 2.0) > s / 2.0) {
      sum = sum + licznik;
      if (i == 1) {
        min = licznik;
      }
      if (licznik < min) {
        min = licznik;
      }
      if (licznik > max) {
        max = licznik;
      }

      /* Wypisanie statystyk w dolnej cz\u0119\u015bci okna */
      fill(255);
      noStroke();
      rect(0, 510, s + 10, 90);

      stroke(r, g, b);
      fill(r, g, b);
      text("Po " + i + " przebiegach na " + last + ":", 0, 525); /* writeln('Po ', i, ' przebiegach na ', last, ':'); */
      text("min = " + min, 0, 545); /* writeln('min = ', min,' '); */
      text("średnia = " + round((float)sum / i), 0, 565); /* writeln('średnia = ', round(sum/i),' '); */
      text("max = " + max, 0, 585); /* writeln('max = ', max,' '); */

      i = i + 1;
      if (i <= last) {
        ellipseMode(CORNER);
        noFill();
        stroke(0);
        ellipse(0, 0, s - 1, s - 1);
        resetWalk();
      } else {
        finished = true;
      }
    }
  }
}
