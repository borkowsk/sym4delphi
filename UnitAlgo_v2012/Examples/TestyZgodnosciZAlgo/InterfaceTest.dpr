Program test_interfaceu;
uses
  Algo in '..\..\Algo.pas';{$APPTYPE CONSOLE}
(*
{Grafika podstawowa}
Procedure Line(x1, y1, x2, y2: integer);{Rysuje odcinek linii prostej ��cz�cy punkt o wsp�rz�dnych (x1, y1) z punktem o wsp�rz�dnych (x2, y2). Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x2, y2).}
Procedure LineTo(x, y: integer);{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu o wsp�rz�dnych (x, y). Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x, y).}
Procedure MoveTo(x, y: integer);{Przemieszcza kursor graficzny do punktu o wsp�rz�dnych (x, y).}
Procedure Coordinates(Var x, y: integer);{Zwraca informacj� o wsp�rz�dnych kursora graficznego.}
Procedure Pen(n, r, g, b: integer);{Ustala kolor i grubo�� rysowanych linii. Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - grubo��.}
Procedure Brush(k, r, g, b: integer);{Ustala kolor i styl wype�nienia. Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim. Je�li k=1 to figury s� zamalowywane wybranym kolorem p�dzla, je�li k=0 to kolor jest przezroczysty.}
Procedure TextColor(r, g, b: integer);{Okre�la kolor dla wypisywanych tekst�w procedurami Pisz i PiszLn. Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim.}
Procedure Rectangle(x1, y1, x2, y2: integer);{Rysuje prostok�t, kt�rego przeciwleg�e wierzcho�ki maj� wsp�rz�dne (x1, y1) i (x2, y2). Przesuwa tak�e kursor graficzny do punktu o wsp�rz�dnych (x2, y2).}
Procedure Ellipse(x1, y1, x2, y2: integer);{Rysuje elips�. Parametry okre�laj� wsp�rz�dne dw�ch przeciwleg�ych wierzcho�k�w prostok�ta opisanego na elipsie. Wsp�rz�dne kursora graficznego nie ulegaj� zmianie.}
Procedure Point(x, y: integer);{Zaznacza punkt o wsp�rz�dnych (x, y) w kolorze pisaka. Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x, y).}
Procedure Fill(x, y: integer);{Wype�nia zadanym kolorem p�dzla wn�trze obszaru obejmuj�cego punkt o wsp�rz�dnych (x, y).}
Procedure Font(rozmiar, Heading, grubo��: integer);{Wybiera rozmiar (6..72), kierunek (0..359) i grubo�� (1..1000) wypisywanych tekst�w procedurami Pisz i PiszLn. Argumentami procedury Czcionka mog� by� dowolne wyra�enia ca�kowite.}
Procedure Clear;{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym g�rnym rogu okna wynik�w.
Opr�cz wyczyszczenia okna, procedura wykonuje nast�puj�ce czynno�ci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype�nienia;
- ustawia czcionk� (8,0,400).
}

{Okienne wej�cie-wyj�cie}
Function IsEvent: boolean;{Wynikiem funkcji jest warto�� logiczna prawda, je�li od ostatniego wywo�ania procedury Zdarzenie zasz�o jakie� zdarzenie (naci�ni�cie klawisza klawiatury lub lewego przycisku myszy w obr�bie okna wynik�w), w przeciwnym przypadku fa�sz.}
Procedure Event(Var k, x, y: integer);{Za zdarzenie uwa�a si� naci�ni�cie klawisza na klawiaturze lub wci�ni�cie lewego przycisku myszki w obr�bie okna wynik�w. Je�li w momencie wywo�ania procedury zdarzenia jeszcze nie by�o, to program oczekuje zdarzenia.
Wywo�anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y warto�ci:
k=1, x=kod, y=0 - naci�ni�to klawisz steruj�cy nie maj�cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naci�ni�to klawisz steruj�cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naci�ni�to klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wsp�rz�dne kursora myszy - wci�ni�to lewy przycisk myszy;
k=3, x, y=wsp�rz�dne kursora myszy - mysz przemieszcza si� z wci�ni�tym lewym przyciskiem.
}

{Inne}
Procedure Date(Var rok, miesi�c, dzie�: integer);{Procedura wylicza aktualn� dat�, czyli rok (1900..2099), miesi�c (1..12), dzie� i dzie� (1.. 31).}
Procedure Time(Var godzina, minuta, sekunda: integer);{Procedura wylicza aktualny czas, czyli godzin� (0..23), minuty (0..59) i sekundy (0..59).}
Procedure Delay(ms: integer);{Wstrzymanie wykonywania programu na okres ms milisekund.}
Procedure PlaySound(atr: integer, plik: string);{Odtwarza pliki d�wi�kowe typu *.wav.
Pierwszym parametrem jest wyra�enie ca�kowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - je�li w momencie wywo�ania jest odtwarzany inny d�wi�k to zostanie przerwany;
3 - odtwarzanie w p�tli bez ko�ca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis okre�laj�cy nazw� pliku typu *.wav. W og�lnym przypadku nazwa okre�la pe�n� �cie�k� dost�pu do pliku - dysk, folder i jego nazw�.
}
*)


Procedure wait;

Var
   k, x, y:integer;
Begin
  Event(k, x, y);
  Write('Czynno��: ');
  If k=1 then
    Begin
      Write('klawiatura. ');
      If y=0 then
        WriteLn('Wci�ni�ty klawisz steruj�cy. Kod ',x)
      else
        If y=1 then
          WriteLn('Steruj�cy klawisz. Kod ',x)
        else
          WriteLn('Widoczny klawisz. Znak ''',chr(x),'''')
    end
  else
    If k=2 then
      WriteLn('mysz. Lewy przycisk. X=',x,' Y=',y)
    else
      WriteLn('mysz. Mysz przemieszcza si�: X=',x,' Y=',y);

  Event(k,x,y);
  clear;
end;


procedure Main;
Var
   i, x, y: integer;
   rok, miesiac, dzien: integer;
   godzina, minuta, sekunda: integer;

Begin
  {Przesuwanie tekstu}
  For i:=0 to 3 do
    Begin
      MoveTo(10*i,30*i);
      Coordinates(x,y);
      Write('x=',x,'y=',y)
    end;
  Writeln;
  wait;

  {Data i czas}
  Time(godzina,minuta,sekunda);
  Writeln(godzina,':',minuta,'.',sekunda);
  Date(rok, miesiac, dzien);
  Writeln(rok,'/',miesiac,'/',dzien);
  wait;

  {Wykres}
  MoveTo(0, 50);
  For i:=1 to 100 do
    LineTo(i, round(50-50*sin(i/10)));
  wait;

  {R�ne pisaki}
  Line( 0, 0, 90, 90);
  Pen( 2, 0, 0,255);
  Line(30, 30, 90, 30);
  Pen( 6,255, 0, 0);
  Line(10, 10, 10, 90);
  wait;

  {Kolorowy tr�jk�t}
  For i:=0 to 100 do
    Begin
      MoveTo(100,i);
      Pen(1,0,2*i+50,2*i+50);
      LineTo(0, 50)
    end;
  wait;

  Brush(1,255,255,0);
  Rectangle(10,10,50,50);
  Brush(1,255,255,255);
  Rectangle(30,30,90,90); 
  Pen(2,255,0,0); 
  Brush(0,0,0,0); 
  Rectangle(20,20,70,70); 
  wait;

  {Manipulacja kolorem tekstu}
  TextColor(0, 0, 0);
  WriteLn('Kolor tekstu');
  TextColor(0, 0, 255);
  WriteLn('Kolor tekstu');
  wait;

  {Elipsy}
  Ellipse(10, 10, 80, 80);
  Pen(1, 255, 0, 0);
  Ellipse(60, 10, 0, 90);
  Pen(1, 0, 0, 255);
  Brush(1, 255, 255, 0);
  Ellipse(20, 30, 50, 90);
  wait;

  {Punkty}
  For i:=1 to 5000 do
    Begin
      x:=random(100); 
      y:=random(100); 
      If sqr(x-50)+ sqr(y-50)<1600 then 
        Begin 
          If x>50 then 
            Pen(1,0,0,255) 
          else 
            Pen(1,255,0,0); 
          Point(x,y) 
        end 
    end; 
  wait;

  {Napisy r�nymi czcionkami}
  Font(10,0,400);
  WriteLn('Czcionka(10,0,400)');
  Font(8,0,800);
  WriteLn('Czcionka(8,0,800)');
  MoveTo( 80,100 );
  Font(10,30,400);
  WriteLn('Czcionka(10,30,400)');
  wait;

  {Wypelnienie tr�jk�ta}
  MoveTo(0,0);
  LineTo(70, 30);
  LineTo(20, 80);
  LineTo(0, 0);
  Brush(1,255,255,0);
  Fill(10, 10);
  wait;
end;

begin
RunAsALGO(Main);
end.
