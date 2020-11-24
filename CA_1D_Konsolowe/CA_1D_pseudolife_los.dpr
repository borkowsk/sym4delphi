Program CA_1D_pseudo_life;
{$APPTYPE CONSOLE}
{Program nasladuje w jednowymiarowym automacie komórkowym Life Conwaya} 

const 
   Last=71; {Musi byc wiêksze ni¿ 1 i nieparzyste} 
var 
   Swiat:array[1..Last] of integer; 
   NowyS:array[1..Last] of integer; 
   krok:integer; 

procedure losuj; 
{Wylosowanie "Swiat"a aktualnego} 
var 
   i:integer; 
begin
  for i:=1 to Last do 
  if random < 0.5 then
    Swiat[i]:=0
    else
    Swiat[i]:=1;
end; 

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
{W³asciwy krok modelu} 

var 
   i,j,k:integer; 
   {indeks lewej, œrodkowej i prawej komorki} 
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
  losuj;
  writeln('Automat: jednowymiarowe "PseudoLife" o ',Last,' komorkach');
  for krok:=0 to 50 do 
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
