Program LosowePiksele;
{Proste zastosowanie losowania i grafiki}


uses
  Algo in '..\..\Algo.pas',
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

{<--Wszystkie parametry pracy s¹ zdefiniowane jako zmienne w formularzu}
//const
//   bok=300;   //Bok prostok¹ta z pikselami
//   prob=0.49; //Prawdopodobienstwo kolorowego piksela
//   dziek='Dziekujê za uwagê'; //Tekst koñcz¹cy
//   SWIDTH=500;
//   SHEIGHT=500;

procedure dodaj_punkt; 
{Rysuje punkt w losowym miejscu w obrêbie zadanego kwadratu}
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
{Rysuje losowe punkty a¿ do klikniêcia myszy lub klawiatury}
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

{Szablonowy program g³ówny inicjuj¹cy formularze i uruchamiaj¹cy modu³ ALGO}
begin
Application.Title := 'Losowe piksele';
Application.CreateForm(TSetupForm, SetupForm);{Tworzenie formy konfiguracyjnej}
InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpiêcie jej do struktur modu³u}
RunAsALGO(Main,'Random pixels',SWIDTH,SHEIGHT);{Uruchomienie modu³u}
{Kod umieszczony poni¿ej wykona siê po zamkniêciu g³ównego okna, albo i nigdy...}
end.
