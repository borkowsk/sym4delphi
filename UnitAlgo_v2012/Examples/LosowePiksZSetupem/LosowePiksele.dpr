Program LosowePiksele;
{Proste zastosowanie losowania i grafiki}


uses
  Algo in '..\..\Algo.pas',
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

{<--Wszystkie parametry pracy s� zdefiniowane jako zmienne w formularzu}
//const
//   bok=300;   //Bok prostok�ta z pikselami
//   prob=0.49; //Prawdopodobienstwo kolorowego piksela
//   dziek='Dziekuj� za uwag�'; //Tekst ko�cz�cy
//   SWIDTH=500;
//   SHEIGHT=500;

procedure dodaj_punkt; 
{Rysuje punkt w losowym miejscu w obr�bie zadanego kwadratu}
var 
   x,y:integer; 
begin 
  x:=random(bok);
  y:=random(bok); 
  Point(x,y); 
end; 

procedure wylosuj_kolor; 
{Losuje kolor rysowania}
var
   r,g,b:integer; 
begin 
  r:=random(256);
  g:=random(256); 
  b:=random(256); 
  Pen(1,r,g,b); 
end; 

procedure Main;
{Rysuje losowe punkty a� do klikni�cia myszy lub klawiatury}
Begin
  While not IsEvent do
    begin
      if random<prob then
        wylosuj_kolor
      else
        Pen(1,255,255,255);
      dodaj_punkt;
    end;
  write(dziek);
end;

{Szablonowy program g��wny inicjuj�cy formularze i uruchamiaj�cy modu� ALGO}
begin
Application.Title := 'Losowe piksele';
Application.CreateForm(TSetupForm, SetupForm);{Tworzenie formy konfiguracyjnej}
InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpi�cie jej do struktur modu�u}
RunAsALGO(Main,'Random pixels',SWIDTH,SHEIGHT);{Uruchomienie modu�u}
{Kod umieszczony poni�ej wykona si� po zamkni�ciu g��wnego okna, albo i nigdy...}
end.
