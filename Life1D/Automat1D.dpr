Program Automat1D;//CA_1D_pseudo_life_z_losowaniem;
{Program nasladuje w jednowymiarowym automacie kom�rkowym Life Conwaya}
{Proste zestawienie formularza konfiguracyjnego z rysowaniem grafiki}
//{$APPTYPE CONSOLE}

uses
  Algo in '..\UnitAlgo\Algo.pas',
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

{<--Wszystkie parametry pracy s� zdefiniowane jako zmienne w formularzu}

var
   Swiat:array[1..MaxLast] of integer;
   NowyS:array[1..MaxLast] of integer;
   krok:integer;
   plik:text;

procedure zeruj;
{Wyzerowanie "Swiat"a aktualnego}
var
   i:integer;
begin
  for i:=1 to Last do
    Swiat[i]:=0;
end;

procedure losuj;
{Wylosowanie "Swiat"a aktualnego}
var
   i:integer;
begin
  for i:=1 to Last do
    if random<Prob0 then
      Swiat[i]:=0
    else
      Swiat[i]:=1;
end;

procedure wypisz(linia:integer);
{Wypisywanie na ekran graficzny}
var
   i:integer;
begin
  for i:=1 to Last do
    begin
      if Swiat[i]=0 then
        Pen(1,0,0,0)
      else
        Pen(1,255,0,0);
      Point(i,linia);
    end;
  Pen(1,255,255,255);
  Point(Last+1,linia);
end;

procedure wyrysuj;
{Wypisywanie na ekran graficzny}
var 
   i:integer; 
begin 
  for i:=1 to Last do 
    begin 
      if Swiat[i]=0 then 
        Pen(1,0,0,1) 
      else 
        Pen(1,255,255,0);
      Line(i,15,i,24); 
    end;
end; 

procedure przepisz; 
{Przepisywanie z "NowyS"[wiat] na "Swiat" aktualny}
var 
   i:integer; 
begin 
  for i:=1 to Last do 
    Swiat[i]:=NowyS[i]; 
end; 

procedure zr�b_krok; 
{W�asciwy krok modelu} 

var 
   i,j,k:integer; 
   {indeks lewej, �rodkowej i prawej komorki} 
   sas:integer; 
begin 
  for j:=1 to Last do 
    begin 
      sas:=0; 
      i:=j-1; 
      k:=j+1; 
      if (i>0) and (Swiat[i]>0) then 
        sas:=sas+1; 
      if (k<=Last) and (Swiat[k]>0) then 
        sas:=sas+1; 
      if sas=1 then 
        NowyS[j]:=1 
      else 
        NowyS[j]:=0; 
    end;
end;

{STATYSTYKI}
function ile_zywych:integer;
var 
   i:integer; 
   licznik:integer;
begin 
  licznik:=0; 
  for i:=1 to Last do 
    licznik:=licznik+Swiat[i]; 
  ile_zywych:=licznik; 
end; 

procedure oblicz_statystyke; 
var 
   ile,i:integer;
begin 
  ile:=ile_zywych; 
 MoveTo(Last+2,krok+stat_offset);
 if krok mod 20 = 0 then
  writeln(format(krok,3),':',ile);//zamiast writeln(Format(krok,3),' �ywych:',Format(ile,3));
  //Zapis do pliku
  write(plik,krok,chr(9),ile);
  if SaveStates then
    for i := 1 to Last do
      write(plik,chr(9),Swiat[i]);
  writeln(plik);
end; 

procedure Main;
{PROGRAM G��WNY}
var i:integer;
begin
  assign(plik,OutFileName+'.out');
  rewrite(plik); 
  system.writeln(plik,'N=',chr(9),Last,chr(9),' P0=',chr(9),Prob0);
  write(plik,'Krok',chr(9),'Ile_�ywych');
  if SaveStates then write(plik,chr(9),'Stany kom�rek ...');
  writeln(plik);
  losuj; 
  {Swiat[1]:=1;} 
  writeln('Automat: jednowymiarowe "�ycie" o ',Last,' kom�rkach i P0=',Format(Prob0,5,3));
  
  for krok:=0 to Steps do
    begin 
      wyrysuj; 
      wypisz(stat_offset+krok);
      Pen(1,0,0,0);
      oblicz_statystyke;
      if IsEvent then
             break;
      zr�b_krok;
      przepisz;
    end;
  writeln;

  close(plik);  
  writeln('Zako�czone');
end;

{Szablonowy program g��wny inicjuj�cy formularze i uruchamiaj�cy modu� ALGO}
begin
Algo.InitialiseUnit; //MUSI BY� TU BO INACZEJ SetupForm NIE MA ZINICJOWANEJ APLIKACJI!
Application.Title := 'Automat 1D';
Application.CreateForm(TSetupForm, SetupForm);
  {Tworzenie formy konfiguracyjnej}
InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpi�cie jej do struktur modu�u}
RunAsALGO(Main,'Automat kom�rkowy 1D Life',SWIDTH,SHEIGHT);{Uruchomienie modu�u}
{Kod umieszczony poni�ej wykona si� po zamkni�ciu g��wnego okna, albo i nigdy...}
end.
