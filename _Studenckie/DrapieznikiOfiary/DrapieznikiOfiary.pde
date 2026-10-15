/*
Zmieniłam zupełnie swój program
 - zarowno algorytmy jak i wizualizacje i cała organizacje tego ;)
dodałam też podstawowa wersje zapisu statystyk - i jeszcze nad tym popracuje...
ale wydaje sie że dzała:)

Przewłocka Jaga

szare - ofiary
niebieskie - drapiezniki glodne
granatowe - drap najedzone

!!! trzeba podmienic w głównym programie lokalizacje pliku zapisywanego!!! 
*/

/* PRZETŁUMACZONE Z APLIKACJI Delphi NA Processing ZA POMOCĄ GEMINI */

String NAZWAMODELU = "Predators#7";
int bok = 100;
/* ile pól w poziomie i pionie ma planszy */

double gestosc_drap = 0.2;
/* gestosc drap na planszy */
double gestosc_of = 0.4;
/* gestosc ofiar na planszy */
double p_of_prok = 0.4;
/* p1 z wyk\u0142adu; prawd rozmnozenia sie ofiary */
double p_drap_zjada = 0.2;
/* p2 z wyk\u0142adu; prawd zjedzenia ofiary */
double p_drap_prok = 0.2;
/* p3 z wyk\u0142adu; prawd rozmnozenia sie sytego drapieznika */
double p_of_zdycha = 0.2;
/* p4 z wyk\u0142adu; prawd smierci ofiary */
double p_drap_zdycha = 0.2;
/* p5 z wyk\u0142adu; prawd smierci glodnego drapieznika */
double p_drap_glod = 0.3;
/* p6 z wyk\u0142adu; prawd przejscia drap. ze stanu najedzonego do glodnego */

int szer = 6; /* ile pixeli ma jedno pole */
int xPoczatek = 10;
int yPoczatek = 10;
String ZAPIS = NAZWAMODELU + ".out";
int MAXSTEP = 2500;

class Wspolrzedna {
    int X;
    int Y;
}

Wspolrzedna[] TablicaWspolrzednych = new Wspolrzedna[8];
int[][] NaszSwiat = new int[bok + 1][bok + 1];
int iteracja;
int[] LicznikZmian = new int[8];
PrintWriter out;

int i_eksperyment = 1;
int NumerKroku = 0;

void settings() {
  size(bok * szer + szer + 5, bok * szer + 55);
}

void setup() {
  for (int k = 0; k < 8; k++) {
    TablicaWspolrzednych[k] = new Wspolrzedna();
  }

  TworzWspolrzedne();
  for (int i = 1; i <= 7; i++) {
    LicznikZmian[i] = 0;
  }
  out = createWriter(ZAPIS);
  frameRate(199); // TU MOŻNA ZNACZĄCO PRZYŚPIESZYĆ LUB SPOWOLNIĆ
}

void TworzWspolrzedne() {
/* Tworzy tablice z przesunięcia */
  int i, j, k;
  k = 0;
  for (i = -1; i <= 1; i++) {
    for (j = -1; j <= 1; j++) {
      if (!((i == 0) && (j == 0))) {
        TablicaWspolrzednych[k].X = i;
        TablicaWspolrzednych[k].Y = j;
        k = k + 1;
      }
    }
  }
}

void Przemaluj(int x, int y, int c) {
/* przemalowuje dan\u0105 komórk\u0119 na odpowiedni kolor */
  stroke(220, 220, 220);
  switch (c) {
    case 0:
      fill(255, 255, 255);
      break;
    case 1:
      fill(200, 200, 200);
      break;
    case 2:
      fill(50, 200, 250);
      break;
    case 3:
      fill(50, 100, 250);
      break;
  }
  rect(xPoczatek + (x - 1) * szer, yPoczatek + (y - 1) * szer, szer, szer);
}

void Start(int[][] TenSwiat) {
/* losuje warto\u015bci komórek */
  int i, j;
  double r;
  stroke(0, 0, 0);
  fill(0, 0, 0);
  rect(xPoczatek - 1, yPoczatek - 1, (bok) * szer + 2, (bok) * szer + 2);
  for (i = 1; i <= bok; i++) {
    for (j = 1; j <= bok; j++) {
      TenSwiat[i][j] = 0;
      r = random(1);
      if (r < gestosc_of) {
        TenSwiat[i][j] = 1;
      } else if (r < gestosc_of + gestosc_drap) {
        TenSwiat[i][j] = 2;
      }
      Przemaluj(i, j, TenSwiat[i][j]);
    }
  }
}

void Wizualizacja(int[][] NaszSwiat) {
  int i, j;
  for (i = 1; i <= bok; i++) {
    for (j = 1; j <= bok; j++) {
      Przemaluj(i, j, NaszSwiat[i][j]);
    }
  }
}

void LosowanieKomorki(int[] x, int[] y) {
  x[0] = int(random(bok)) + 1;
  y[0] = int(random(bok)) + 1;
}

void zdycha(int[][] TenSwiat, int a, int b) {
/* zarowno dla ofiary, jak i drapiezcy */
  TenSwiat[a][b] = 0;
}

void rozmnoz_of(int[][] TenSwiat, int c, int d) {
/* wspolrzednych biezacych ofiary nie zmieniam bo i tak zostaje tam 1 */
  TenSwiat[c][d] = 1;
}

void rozmnoz_drap(int[][] TenSwiat, int a, int b, int c, int d) {
/* wspolrzedne biezace i nowego miejsca */
  TenSwiat[a][b] = 2;
  TenSwiat[c][d] = 2;
}

void zjedz(int[][] TenSwiat, int a, int b, int c, int d) {
/* wspolrzedne drapieznika i ofiary */
  TenSwiat[a][b] = 0;
  TenSwiat[c][d] = 3;
}

void przesun(int[][] TenSwiat, int a, int b, int c, int d) {
/* wspolrzedne biezace i nowego miejsca */
  TenSwiat[c][d] = TenSwiat[a][b];
  TenSwiat[a][b] = 0;
}

void glodnieje(int[][] TenSwiat, int a, int b) {
/* dla sytego drapiezcy */
  TenSwiat[a][b] = 2;
}

boolean znajdz_puste(int[][] TenSwiat, int x, int y, int[] i_res, int[] j_res) {
/* szuka pustych p�l w s\u0105siedztwie */
  int a, k;
  int i = 0, j = 0;
  a = 0;
  k = int(random(8));
  /* wybieramy miejsce w tablicy wspolrzednych */
  do {
    i = (x + TablicaWspolrzednych[k].X + bok - 1) % bok + 1;
    j = (y + TablicaWspolrzednych[k].Y + bok - 1) % bok + 1;
    k = (k + 1) % 8;
    a = a + 1;
    /* bo jak trafimy na pelna komorke to przeskakujemy na nastepny w tablicy wektor przesuniecia */
  } while (!((TenSwiat[i][j] == 0) || (a == 8)));

  i_res[0] = i;
  j_res[0] = j;

  if (TenSwiat[i][j] == 0) {
    return true;
  } else {
    return false;
  }
}

boolean znajdz_ofiare(int[][] TenSwiat, int x, int y, int[] i_res, int[] j_res) {
/* szuka ofiar w s\u0105siedztwie */
  int a, k;
  int i = 0, j = 0;
  a = 0;
  k = int(random(8));
  /* wybieramy miejsce w tablicy wspolrzednych */
  do {
    i = (x + TablicaWspolrzednych[k].X + bok - 1) % bok + 1;
    j = (y + TablicaWspolrzednych[k].Y + bok - 1) % bok + 1;
    k = (k + 1) % 8;
    a = a + 1;
    /* bo jak trafimy na pelna komorke to przeskakujemy na nastepny w tablicy wektor przesuniecia */
  } while (!((TenSwiat[i][j] == 1) || (a == 8)));

  i_res[0] = i;
  j_res[0] = j;

  if (TenSwiat[i][j] == 1) {
    return true;
  } else {
    return false;
  }
}

void Kroczek(int x, int y, int[][] TenSwiat, int[] zmiana) {
/* zmiana to liczba opisujaca co sie stalo:
  1 - smierc ofiary
  2 - rozmnozenie sie ofiary
  3 - smierc drapieznika
  4 - rozmnozenie sie drapieznika
  5 - zjedzenie ofiary przez draopieznika
  6 - zglodnienie drapieznika */

  double b;
  int[] i_arr = new int[1];
  int[] j_arr = new int[1];

  b = random(1);
  /* liczba losowa, ktora posluzy do sprawdzenia czy sie rozmnaza, zdycha, czy migruje */
  zmiana[0] = 7;
  /* czyli nic sie nie stalo */
  switch (TenSwiat[x][y]) {
    case 1:
      if (b < p_of_zdycha) {
        zdycha(TenSwiat, x, y);
        zmiana[0] = 1;
      } else {
        if (b < p_of_zdycha + p_of_prok) {
          if (znajdz_puste(TenSwiat, x, y, i_arr, j_arr)) {
            rozmnoz_of(TenSwiat, i_arr[0], j_arr[0]);
            zmiana[0] = 2;
          }
        }
        if (b >= p_of_zdycha + p_of_prok) {
          if (znajdz_puste(TenSwiat, x, y, i_arr, j_arr)) {
            przesun(TenSwiat, x, y, i_arr[0], j_arr[0]);
          }
        }
      }
      break;
    case 2:
      if (b < p_drap_zdycha) {
        zdycha(TenSwiat, x, y);
        zmiana[0] = 3;
      }
      if (b < p_drap_zdycha + p_drap_zjada) {
        if (znajdz_ofiare(TenSwiat, x, y, i_arr, j_arr)) {
          zjedz(TenSwiat, x, y, i_arr[0], j_arr[0]);
          zmiana[0] = 5;
        } else {
          /* gdy nie znalazl w okolicy ofiary */
          if (znajdz_puste(TenSwiat, x, y, i_arr, j_arr)) {
            przesun(TenSwiat, x, y, i_arr[0], j_arr[0]);
          }
        }
      }
      if (b >= p_drap_zdycha + p_drap_zjada) {
        if (znajdz_puste(TenSwiat, x, y, i_arr, j_arr)) {
          przesun(TenSwiat, x, y, i_arr[0], j_arr[0]);
        }
      }
      break;
    case 3:
      if (b < p_drap_glod) {
        glodnieje(TenSwiat, x, y);
        zmiana[0] = 6;
      } else {
        if (b < p_drap_glod + p_drap_prok) {
          if (znajdz_puste(TenSwiat, x, y, i_arr, j_arr)) {
            rozmnoz_drap(TenSwiat, x, y, i_arr[0], j_arr[0]);
            zmiana[0] = 4;
          }
        }
        if (b >= p_drap_glod + p_drap_prok) {
          if (znajdz_puste(TenSwiat, x, y, i_arr, j_arr)) {
            przesun(TenSwiat, x, y, i_arr[0], j_arr[0]);
          }
        }
      }
      break;
  }
}

void Krok(int[][] TenSwiat) {
  int i, n;
  int[] k_arr = new int[1];
  int[] l_arr = new int[1];
  int[] zmiana_stanu = new int[1];

  for (i = 1; i <= 7; i++) {
    LicznikZmian[i] = 0;
  }
  for (n = 1; n <= bok * bok; n++) {
    LosowanieKomorki(k_arr, l_arr);
    int k = k_arr[0];
    int l = l_arr[0];
    /* zwraca losowe a, b - wspolrzedne wylosowanej komorki */
    if (TenSwiat[k][l] > 0) {
      /* jesli w tym miejscu jest w ogole jakies zyjatko */
      Kroczek(k, l, TenSwiat, zmiana_stanu);
      LicznikZmian[zmiana_stanu[0]] = LicznikZmian[zmiana_stanu[0]] + 1;
      /* to jest zmienna globalna, zaraz wykorzystam ja w statystykach */
    }
  }
}

void ZapisStatystyk(PrintWriter outWriter, int[][] TenSwiat) {
  int i, j;
  int[] Licznik = new int[4];

  for (i = 1; i <= 3; i++) {
    Licznik[i] = 0;
  }
  for (i = 1; i <= bok; i++) {
    for (j = 1; j <= bok; j++) {
      if (TenSwiat[i][j] > 0) {
        Licznik[TenSwiat[i][j]] = Licznik[TenSwiat[i][j]] + 1;
      }
    }
  }

  outWriter.print(NumerKroku + "\t");
  for (i = 1; i <= 3; i++) {
    outWriter.print(Licznik[i] + "\t");
  }
  for (i = 1; i <= 6; i++) {
    outWriter.print(LicznikZmian[i] + "\t");
  }
  outWriter.println();
}

void draw() {
  if (i_eksperyment <= 7) {
    if (NumerKroku == 0) {
      out.println("ofiar " + nf((float)gestosc_of, 1, 2) + ", drapie\u017cnik�w " + nf((float)gestosc_drap, 1, 2) + ", p1=" + nf((float)p_of_prok, 1, 2) + ", p2=" + nf((float)p_drap_zjada, 1, 2) + ", p3=" + nf((float)p_drap_prok, 1, 2) + ", p4=" + nf((float)p_of_zdycha, 1, 2) + ", p5=" + nf((float)p_drap_zdycha, 1, 2) + ", p6=" + nf((float)p_drap_glod, 1, 2));
      out.println("krok\tIle Ofiar\tIle g\u0142odnych drap\tIle sytych drap\tSmierc ofiary\trozmnozenie sie ofiary\tsmierc drap\trozmnozenie sie drap\tzjedzenie ofiary przez drap\tzglodnienie drap");
      Start(NaszSwiat);
    }

    if (NumerKroku < MAXSTEP) {
      ZapisStatystyk(out, NaszSwiat);
      if (NumerKroku % 10 == 0) {
        Wizualizacja(NaszSwiat);
      }
      Krok(NaszSwiat);
      NumerKroku = NumerKroku + 1;

      fill(255);
      stroke(255);
      rect(xPoczatek, yPoczatek + bok * szer + 2, bok * szer, 35);
      fill(0);
      textSize(12);
      text("Eksperyment " + i_eksperyment + " Krok numer " + NumerKroku + " z " + MAXSTEP, xPoczatek, yPoczatek + bok * szer + 20);
    } else {
      out.println();
      out.flush();
      NumerKroku = 0;
      i_eksperyment = i_eksperyment + 1;
      if (i_eksperyment > 7) {
        out.close();
        noLoop();
      }
    }
  }
}
