Program CA_1D_pseudo_life; 
{$APPTYPE CONSOLE}
{Program nasladuje w jednowymiarowym automacie kom�rkowym Life Conwaya} 

const 
   Last=71; {Musi byc wi�ksze ni� 1 i nieparzyste} 
var 
   Swiat:array[1..Last] of integer; 
   NowyS:array[1..Last] of integer; 
   krok:integer; 

procedure zeruj; 
{Wyzerowanie "Swiat"a aktualnego} 

var 
   i:integer; 
begin 
  for i:=1 to Last do 
    Swiat[i]:=0; 
end; 

procedure wypisz; 
{Wypisywanie na konsole} 

var 
   i:integer; 
begin 
  for i:=1 to Last do 
    if Swiat[i]=0 then 
      write('_') 
    else 
      write('|'); 
end; 

procedure przepisz; 
{Przepisywanie z "NowyS"[wiat] na "Swiat" aktualny} 

var 
   i:integer; 
begin 
  for i:=1 to Last do 
    Swiat[i]:=NowyS[i]; 
end; 

procedure zrob_krok; 
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

begin 
  Zeruj; 
  {�eby nie komplikowa� inicjacja w kodzie} 
  { Swiat[1]:=1; }
  Swiat[(last+1) div 2]:=1; 

  writeln('Automat: jednowymiarowe "PseudoLife" o ',Last,' komorkach');
  for krok:=1 to 50 do 
    begin 
      write(krok:3,') '); 
      wypisz; 
      writeln; 
      zrob_krok; 
      przepisz; 
    end; 
  writeln('Dziekuje i polecam sie na przyszlosc');
  readln;
end.
