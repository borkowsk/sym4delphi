Program CA_2D_agregacja; 
{Program CA symulacja dyfuzji z agregacj�} 
uses Algo in '..\UnitAlgo\Algo.pas';

const 
   Last=100;  {Rozmiar tablicy - Musi byc wi�ksze ni� 1 i najwyzej 160} 
   Bok=5;    {Rozmiar kom�rki} 
   Prob0=0.800;    {Prawdopodobienstwo 0 w inicjalizacjilosowej} 
   IniFile='';    {'2DCA_dane.txt';}    {Nazwa pliku z danymi} 
type 
   TypSwiata=array[1..Last,1..Last] of integer; 
var 
   Swiat:TypSwiata; 
   {Globalna zmienna reprezentuj�ca �wiat} 
   krok:integer; 
   {RӯNE FUNKCJE INICJUJ�CE DO ROZS�DNEGO WYBORU} 

procedure ZerujCa�e; 
{Wyzerowanie "Swiat"a} 

var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      Swiat[i,j]:=0; 
end; 

procedure ZerujCz��(xp,xk,yp,yk:integer); 
{Wyzerowanie kawa�ka "Swiat"a} 

var 
   i,j:integer; 
begin 
  for i:=xp to xk do 
    for j:=yp to yk do 
      Swiat[i,j]:=0; 
end; 

procedure LosujCa�y; 
{Wylosowanie cz�stek "Swiat"a } 

var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      if random<Prob0 then 
        Swiat[i,j]:=0 
      else 
        Swiat[i,j]:=1; 
end; 

procedure LosujCz��(xp,xk,yp,yk:integer); 
{Losowanie cz�stek w prostok�cie} 

var 
   i,j:integer; 
begin 
  for i:=xp to xk do 
    for j:=yp to yk do 
      if random<Prob0 then 
        Swiat[i,j]:=0 
      else 
        Swiat[i,j]:=1; 
end; 

procedure Przes�ona(pozycja:integer); 
{Rysuje przes�one na 2/3 szeroko�ci �wiata} 

var 
   i:integer; 
begin 
  for i:=1 to Last div 3 do 
    begin 
      Swiat[i,pozycja]:=2; 
      Swiat[Last-i,Pozycja]:=2; 
    end; 
end; 

function min(a,b:integer):integer; 
{Matematyczne minimum z dwu liczb ca�kowitych} 

begin 
  if a>b then 
    min:=b 
  else 
    min:=a; 
end; 

function max(a,b:integer):integer; 
{Matematyczne maximum z dwu liczb ca�kowitych} 

begin 
  if a<b then 
    max:=b 
  else 
    max:=a; 
end; 

procedure WczytajPlik(nazwa:string); 
{Wczytuje plik z danymi. * oznaczaj� 1, X=2, reszta 0} 

var 
   dane:text; 
   bufor:string[Last]; 
   i,j:integer; 
begin 
  assign(dane,nazwa); 
  reset(dane); 
  j:=1; 
  repeat 
    readln(dane,bufor); 
    for i:=1 to min(Length(bufor),Last) do 
      begin 
        if bufor[i]='*' then 
          Swiat[i,j]:=1 
        else 
          if (bufor[i]='X')or(bufor[i]='x') then 
            Swiat[i,j]:=2 
          else 
            Swiat[i,j]:=0; 
      end; 
    {writeln(bufor);  DEBUG} 
    j:=j+1; 
  until (j>Last) or (eof(dane)); 
  close(dane) 
end; 

procedure PatrzObok(xo,yo:integer;var x,y:integer); 
{Losuje s�siedni� kom�rk�, dbaj�c o to, �eby nie wyj�� za tablice} 
{Niezbyt optymalne, ale skuteczne} 

begin 
  x:=xo+random(3)-1; 
  y:=yo+random(3)-1; 
  if x<1 then 
    x:=1; 
  if x>Last then 
    x:=Last; 
  if y<1 then 
    y:=1; 
  if y>Last then 
    y:=Last; 
end; 

function MaSasiada2(xo,yo:integer):boolean; 
{Sprawdzenie czy jest w s�siedztwie Moora jaka� 2-ka}
var 
   i,j:integer; 
   flaga:boolean; 
begin 
  flaga:=false; 
  for i:=max(1,xo-1) to min(xo+1,Last) do 
    for j:=max(1,yo-1) to min(yo+1,Last) do 
      if Swiat[i,j]=2 then 
        flaga:=true; 
  MaSasiada2:=flaga; 
end; 

procedure Zr�bKrokMonteCarlo; 
{W�asciwy krok modelu} 

var 
   k,xo,yo,xn,yn:integer; 
begin 
  for k:=1 to Last*Last do 
    begin 
      xo:=random(Last)+1; 
      yo:=random(Last)+1; 
      if Swiat[xo,yo]=1 then 
        if MaSasiada2(xo,yo) then 
          begin 
            Swiat[xo,yo]:=2; 
          end 
        else 
          begin 
            PatrzObok(xo,yo,xn,yn); 
            if Swiat[xn,yn]=0 then 
              begin 
                Swiat[xn,yn]:=Swiat[xo,yo]; 
                Swiat[xo,yo]:=0; 
              end; 
          end; 
    end; 
end; 

procedure Wypisz; 
{ALGOwe wypisywanie na ekran graficzny jest nieprzeno�ne!!!} 

var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      begin 
        if Swiat[i,j]=0 then 
          Brush(1,0,0,0) 
        else 
          if Swiat[i,j]=1 then 
            Brush(1,255,0,0) 
          else 
            Brush(1,0,0,255); 
        Rectangle(i*bok,j*bok,(i+1)*bok,(j+1)*bok); 
      end; 
  Brush(1,255,255,255); 
end;

function UserStop:boolean;
var k, x, y: Integer;
begin
UserStop:=false;
if IsEvent then
  begin
  Event(k, x, y);
  if k=1 then
    if x<>27 then
      begin
      moveto(1,0);
      writeln('Hint: ESC --> STOP');
      delay(200);
      end
      else
      UserStop:=true;
  end;
end;

procedure Main;
begin 
  {Wariantowa inicjalizacja przestrzeni symulacji} 
  if IniFile='' then 
    begin  
      LosujCa�y; 
      Swiat[Last div 2,Last div 2]:=2; 
     (*
      LosujCz��(1,Last,1,Last div 2); 
      ZerujCz��(1,Last,Last div 2+1,Last); 
      Przes�ona(Last div 2+1); 
      *)     
    end 
  else 
    begin 
      ZerujCa�e; 
      WczytajPlik(IniFile); 
    end; 
  Wypisz; 
  writeln; 
  writeln('          Automat kom�rkowy "Dyfuzja i agregacja" o ',Last,'x',Last,' kom�rkach'); 
  {W�a�ciwa p�tla symulacji} 
  krok:=0; 
  while not UserStop do
    begin 
      Zr�bKrokMonteCarlo; 
      krok:=krok+1; 
      wypisz; 
      writeln; 
      writeln(format(krok,3),') '); 
    end; 
  writeln; 
  writeln('Dzi�kuje i polecam si� na przysz�o��'); 
end;

BEGIN
Randomize;
RunAsAlgo(Main,'Dyfuzja i agregacja',510,570);
END.
