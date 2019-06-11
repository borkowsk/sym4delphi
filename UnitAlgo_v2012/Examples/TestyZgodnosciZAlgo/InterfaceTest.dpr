Program test_interfaceu;
uses
  Algo in '..\..\Algo.pas';{$APPTYPE CONSOLE}
(*
{Grafika podstawowa}
Procedure Line(x1, y1, x2, y2: integer);{Rysuje odcinek linii prostej ³¹cz¹cy punkt o wspó³rzêdnych (x1, y1) z punktem o wspó³rzêdnych (x2, y2). Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x2, y2).}
Procedure LineTo(x, y: integer);{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu o wspó³rzêdnych (x, y). Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x, y).}
Procedure MoveTo(x, y: integer);{Przemieszcza kursor graficzny do punktu o wspó³rzêdnych (x, y).}
Procedure Coordinates(Var x, y: integer);{Zwraca informacjê o wspó³rzêdnych kursora graficznego.}
Procedure Pen(n, r, g, b: integer);{Ustala kolor i gruboœæ rysowanych linii. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - gruboœæ.}
Procedure Brush(k, r, g, b: integer);{Ustala kolor i styl wype³nienia. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim. Jeœli k=1 to figury s¹ zamalowywane wybranym kolorem pêdzla, jeœli k=0 to kolor jest przezroczysty.}
Procedure TextColor(r, g, b: integer);{Okreœla kolor dla wypisywanych tekstów procedurami Pisz i PiszLn. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim.}
Procedure Rectangle(x1, y1, x2, y2: integer);{Rysuje prostok¹t, którego przeciwleg³e wierzcho³ki maj¹ wspó³rzêdne (x1, y1) i (x2, y2). Przesuwa tak¿e kursor graficzny do punktu o wspó³rzêdnych (x2, y2).}
Procedure Ellipse(x1, y1, x2, y2: integer);{Rysuje elipsê. Parametry okreœlaj¹ wspó³rzêdne dwóch przeciwleg³ych wierzcho³ków prostok¹ta opisanego na elipsie. Wspó³rzêdne kursora graficznego nie ulegaj¹ zmianie.}
Procedure Point(x, y: integer);{Zaznacza punkt o wspó³rzêdnych (x, y) w kolorze pisaka. Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x, y).}
Procedure Fill(x, y: integer);{Wype³nia zadanym kolorem pêdzla wnêtrze obszaru obejmuj¹cego punkt o wspó³rzêdnych (x, y).}
Procedure Font(rozmiar, Heading, gruboœæ: integer);{Wybiera rozmiar (6..72), kierunek (0..359) i gruboœæ (1..1000) wypisywanych tekstów procedurami Pisz i PiszLn. Argumentami procedury Czcionka mog¹ byæ dowolne wyra¿enia ca³kowite.}
Procedure Clear;{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym górnym rogu okna wyników.
Oprócz wyczyszczenia okna, procedura wykonuje nastêpuj¹ce czynnoœci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype³nienia;
- ustawia czcionkê (8,0,400).
}

{Okienne wejœcie-wyjœcie}
Function IsEvent: boolean;{Wynikiem funkcji jest wartoœæ logiczna prawda, jeœli od ostatniego wywo³ania procedury Zdarzenie zasz³o jakieœ zdarzenie (naciœniêcie klawisza klawiatury lub lewego przycisku myszy w obrêbie okna wyników), w przeciwnym przypadku fa³sz.}
Procedure Event(Var k, x, y: integer);{Za zdarzenie uwa¿a siê naciœniêcie klawisza na klawiaturze lub wciœniêcie lewego przycisku myszki w obrêbie okna wyników. Jeœli w momencie wywo³ania procedury zdarzenia jeszcze nie by³o, to program oczekuje zdarzenia.
Wywo³anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y wartoœci:
k=1, x=kod, y=0 - naciœniêto klawisz steruj¹cy nie maj¹cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciœniêto klawisz steruj¹cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciœniêto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wspó³rzêdne kursora myszy - wciœniêto lewy przycisk myszy;
k=3, x, y=wspó³rzêdne kursora myszy - mysz przemieszcza siê z wciœniêtym lewym przyciskiem.
}

{Inne}
Procedure Date(Var rok, miesi¹c, dzieñ: integer);{Procedura wylicza aktualn¹ datê, czyli rok (1900..2099), miesi¹c (1..12), dzieñ i dzieñ (1.. 31).}
Procedure Time(Var godzina, minuta, sekunda: integer);{Procedura wylicza aktualny czas, czyli godzinê (0..23), minuty (0..59) i sekundy (0..59).}
Procedure Delay(ms: integer);{Wstrzymanie wykonywania programu na okres ms milisekund.}
Procedure PlaySound(atr: integer, plik: string);{Odtwarza pliki dŸwiêkowe typu *.wav.
Pierwszym parametrem jest wyra¿enie ca³kowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - jeœli w momencie wywo³ania jest odtwarzany inny dŸwiêk to zostanie przerwany;
3 - odtwarzanie w pêtli bez koñca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis okreœlaj¹cy nazwê pliku typu *.wav. W ogólnym przypadku nazwa okreœla pe³n¹ œcie¿kê dostêpu do pliku - dysk, folder i jego nazwê.
}
*)


Procedure wait;

Var
   k, x, y:integer;
Begin
  Event(k, x, y);
  Write('Czynnoœæ: ');
  If k=1 then
    Begin
      Write('klawiatura. ');
      If y=0 then
        WriteLn('Wciœniêty klawisz steruj¹cy. Kod ',x)
      else
        If y=1 then
          WriteLn('Steruj¹cy klawisz. Kod ',x)
        else
          WriteLn('Widoczny klawisz. Znak ''',chr(x),'''')
    end
  else
    If k=2 then
      WriteLn('mysz. Lewy przycisk. X=',x,' Y=',y)
    else
      WriteLn('mysz. Mysz przemieszcza siê: X=',x,' Y=',y);

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

  {Ró¿ne pisaki}
  Line( 0, 0, 90, 90);
  Pen( 2, 0, 0,255);
  Line(30, 30, 90, 30);
  Pen( 6,255, 0, 0);
  Line(10, 10, 10, 90);
  wait;

  {Kolorowy trójk¹t}
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

  {Napisy ró¿nymi czcionkami}
  Font(10,0,400);
  WriteLn('Czcionka(10,0,400)');
  Font(8,0,800);
  WriteLn('Czcionka(8,0,800)');
  MoveTo( 80,100 );
  Font(10,30,400);
  WriteLn('Czcionka(10,30,400)');
  wait;

  {Wypelnienie trójk¹ta}
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
