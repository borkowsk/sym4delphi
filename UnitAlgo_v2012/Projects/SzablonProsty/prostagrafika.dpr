Program ProstaGrafika;
//Jeœli nie ma powodu do u¿ycia konsoli to mo¿na poni¿sz¹ linie wykomentowaæ: //
//{$APPTYPE CONSOLE}
uses
  Algo in '..\..\Algo.pas';

//const WIDTH=300;HEIGHT=300;//W ALGO tylko tak

var WIDTH:integer=400; //A w Delphi mo¿na
    HEIGHT:integer=400;//te¿ tak...

procedure Main;
var i:integer;
Begin
  {Sprawdzenie faktycznych rozmiarów okna}
  Algo.GetSize(WIDTH,HEIGHT);//Nie ma w prawdziwym ALGO

  {Kolorowy trójk¹t}
  For i:=0 to HEIGHT do
    Begin
      MoveTo(WIDTH,i);
      Pen(1,0,(2*i+50)mod 256,(2*i+50) mod 256);
      LineTo(0, 50)
    end;
end;

begin
RunAsALGO(Main,'Szablon z przyk³adow¹ grafik¹',WIDTH,HEIGHT);
end.
