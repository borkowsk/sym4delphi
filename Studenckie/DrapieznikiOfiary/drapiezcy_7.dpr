Program Drapieznicy;
uses Algo in '..\UnitAlgo\Algo.pas';
{
Zmienilam zupelnie swoj program
 - zarowno algorytmy jak i wizualizacje i cala organizacje tego ;)
dodalam tez podstawowa wersje zapisu statystyk - i jeszcze nad tym popracuje...
ale wydaje sie ze dzala:)

Przewlocka Jaga

szare - ofiary
niebieskie - drapiezniki glodne
granatowe - drap najedzone
}

{trzeba podmienic w glownym programie lokalizacje pliku zapisywanego!!!}

const
   NAZWAMODELU='Predators#7';
   bok=100;
   {ile pól w poziomie i pionie ma plansza} 

   gestosc_drap=0.2; 
   {gestosc drap na planszy} 
   gestosc_of=0.4; 
   {gestosc ofiar na planszy} 
   p_of_prok=0.4; 
   {p1 z wyk³adu; prawd rozmnozenia sie ofiary} 
   p_drap_zjada=0.2; 
   {p2 z wyk³adu; prawd zjedzenia ofiary} 
   p_drap_prok=0.2;
   {p3 z wyk³adu; prawd rozmnozenia sie sytego drapieznika} 
   p_of_zdycha=0.2; 
   {p4 z wyk³adu; prawd smierci ofiary} 
   p_drap_zdycha=0.2; 
   {p5 z wyk³adu; prawd smierci glodnego drapieznika} 
   p_drap_glod=0.3; 
   {p6 z wyk³adu; prawd przejscia drap. ze stanu najedzonego do glodnego} 
   
   szer=6; {ile pixeli ma jedno pole}
   xPocz¹tek=10; 
   yPocz¹tek=10; 
   ZAPIS=NAZWAMODELU+'.out';
   MAXSTEP=2500;

type 
   pole=integer; 
   Swiat= Array[1..bok, 1..bok] of pole; 
   Wspolrzedna= record 
        X: integer; 
        Y: integer; 
   end; 
   Wspolrzedne=Array[0..7] of Wspolrzedna; 

var 
   TablicaWspolrzednych:Wspolrzedne; 
   NaszSwiat:Swiat; 
   iteracja:integer;
   LicznikZmian:Array[1..7] of integer; 
   out:text; 

Procedure TworzWspolrzedne; 
{Tworzy tablice z przesuniêciai} 
var    i,j,k:integer; 
begin 
  k:=0; 
  for i:=-1 to 1 do 
    for j:=-1 to 1 do 
      begin 
        if not ((i=0) and (j=0)) then 
          begin 
            TablicaWSpolrzednych[k].X:=i; 
            TablicaWSpolrzednych[k].Y:=j; 
            k:=k+1; 
          end; 
      end; 
end; 

Procedure Przemaluj(x,y,c:integer); 
{przemalowuje dan¹ komórkê na odpowiedni kolor} 

begin 
  Pen(1,220,220,220); 
  Case c of 
    0: 
      Brush(1,255,255,255); 
    1: 
      Brush(1,200,200,200); 
    2: 
      Brush(1,50,200,250); 
    3: 
      Brush(1,50,100,250); 
  end; 
  Rectangle(xPocz¹tek+(x-1)*szer,yPocz¹tek+(y-1)*szer,xPocz¹tek+x*szer,yPocz¹tek+y*szer); ; 
end; 

Procedure Start(var TenSwiat:Swiat); 
{losuje wartoœci komórek} 

var 
   i,j:integer; 
   r:real; 
begin 
  Pen(1,0,0,0); 
  brush(0,0,0,0); 
  rectangle(xPocz¹tek-1,yPocz¹tek-1,xPocz¹tek+(bok)*szer+1,yPocz¹tek+(bok)*szer+1); 
  for i:=1 to bok do 
    for j:=1 to bok do 
      begin 
        TenSwiat[i,j]:=0; 
        r:=random; 
        if r<gestosc_of then 
          begin 
            TenSwiat[i,j]:=1; 
          end 
        else 
          if r<gestosc_of+gestosc_drap then 
            begin 
              TenSwiat[i,j]:=2; 
            end ; 
        Przemaluj(i,j,TenSwiat[i,j]); 
      end; 
end; 

Procedure Wizualizacja(NaszSwiat:Swiat); 
var i,j:integer;
begin 
  for i:=1 to bok do
    for j:=1 to bok do 
      Przemaluj(i,j,NaszSwiat[i,j]) 
end; 

Procedure Krok(var TenSwiat:Swiat);

var 
   n,a,b,k,l,zmiana_stanu:integer; 
   {procedury pomocnicze} 

Procedure LosowanieKomorki(var x:integer; var y:integer); 

begin 
  x:=random(bok)+1; 
  y:=random(bok)+1 
end; 

Procedure zdycha(a,b:integer); 
{zarowno dla ofiary, jak i drapiezcy} 

begin 
  TenSwiat[a,b]:=0; 
end; 

Procedure rozmnoz_of(c,d:integer); 
{wspolrzednych biezacych ofiary nie zmieniam bo i tak zostaje tam 1} 

begin 
  TenSwiat[c,d]:=1; 
end; 

Procedure rozmnoz_drap(a,b,c,d:integer); 
{wspolrzedne biezace i nowego miejsca} 

begin 
  TenSwiat[a,b]:=2; 
  TenSwiat[c,d]:=2; 
end; 

Procedure zjedz(a,b,c,d:integer); 
{wspolrzedne drapieznika i ofiary} 

begin 
  TenSwiat[a,b]:=0; 
  TenSwiat[c,d]:=3; 
end; 

Procedure przesun(a,b,c,d:integer); 
{wspolrzedne biezace i nowego miejsca} 

begin 
  TenSwiat[c,d]:=TenSwiat[a,b]; 
  TenSwiat[a,b]:=0; 
end; 

Procedure glodnieje(a,b:integer); 
{dla sytego drapiezcy} 

begin 
  TenSwiat[a,b]:=2; 
end; 

Function znajdz_puste(x,y:integer; var i,j:integer):boolean; 
{szuka pustych pól w s¹siedztwie} 

var 
   a,k:integer; 
begin 
  a:=0; 
  k:=random(8); 
  {wybieramy miejsce w tablicy wspolrzednych} 
  Repeat 
    begin 
      i:=(x+TablicaWspolrzednych[k].X+bok-1) mod bok +1; 
      j:=(y+TablicaWspolrzednych[k].Y+bok-1) mod bok +1; 
      k:=(k+1) mod 8 ; 
      a:=a+1; 
      {bo jak trafimy na pelna komorke to przeskakujemy na nastepny w tablicy wektor przesuniecia} 
    end; 
  Until (TenSwiat[i,j]=0) or (a=8); 
  if TenSwiat[i,j]=0 then 
    znajdz_puste:=true 
  else 
    znajdz_puste:=false; 
end; 

Function znajdz_ofiare(x,y:integer; var i,j:integer):boolean; 
{szuka ofiar w s¹siedztwie} 

var 
   a,k:integer; 
begin 
  a:=0; 
  k:=random(8); 
  {wybieramy miejsce w tablicy wspolrzednych} 
  Repeat 
    begin 
      i:=(x+TablicaWspolrzednych[k].X+bok-1) mod bok +1; 
      j:=(y+TablicaWspolrzednych[k].Y+bok-1) mod bok +1; 
      k:=(k+1) mod 8 ; 
      a:=a+1; 
      {bo jak trafimy na pelna komorke to przeskakujemy na nastepny w tablicy wektor przesuniecia} 
    end; 
  Until (TenSwiat[i,j]=1) or (a=8); 
  if TenSwiat[i,j]=1 then 
    znajdz_ofiare:=true 
  else 
    znajdz_ofiare:=false; 
end; 

Procedure Kroczek(x,y:integer; var TenSwiat:Swiat; var zmiana:integer); 
{zmiana to liczba opisujaca co sie stalo:
  1 - smierc ofiary
  2 - rozmnozenie sie ofiary
  3 - smierc drapieznika
  4 - rozmnozenie sie drapieznika
  5 - zjedzenie ofiary przez draopieznika
  6 - zglodnienie drapieznika} 

var 
   a,i,j,k,stan_stary, stan_nowy:integer; 
   b:real; 
begin 
  b:=random; 
  {liczba losowa, ktora posluzy do sprawdzenia czy sie rozmnaza, zdycha, czy migruje} 
  zmiana:=7; 
  {czyli nic sie nie stalo} 
  Case TenSwiat[x,y] of 
    1: 
      if b<p_of_zdycha then 
        begin 
          zdycha(x,y); 
          zmiana:=1 
        end 
      else 
        begin 
          if b<p_of_zdycha+p_of_prok then 
            if znajdz_puste(x,y,i,j) then 
              begin 
                rozmnoz_of(i,j); 
                zmiana:=2 
              end; 
          if b>=p_of_zdycha+p_of_prok then 
            if znajdz_puste(x,y,i,j) then 
              przesun(x,y,i,j); 
        end; 
    2: 
      begin 
        if b<p_drap_zdycha then 
          begin 
            zdycha(x,y); 
            zmiana:=3 
          end; 
        if b<p_drap_zdycha+p_drap_zjada then 
          begin 
            if znajdz_ofiare(x,y,i,j) then 
              begin 
                zjedz(x,y,i,j) ; 
                zmiana:=5 
              end 
            else 
              {gdy nie znalazl w okolicy ofiary} 
              if znajdz_puste(x,y,i,j) then 
                przesun(x,y,i,j); 
          end ; 
        if b>=p_drap_zdycha+p_drap_zjada then 
          if znajdz_puste(x,y,i,j) then 
            przesun(x,y,i,j); 
      end; 
    3: 
      begin 
        if b<p_drap_glod then 
          begin 
            glodnieje(x,y); 
            zmiana:=6; 
          end 
        else 
          begin 
            if b<p_drap_glod+p_drap_prok then 
              if znajdz_puste(x,y,i,j) then 
                begin 
                  rozmnoz_drap(x,y,i,j); 
                  zmiana:=4; 
                end; 
            if b>=p_drap_glod+p_drap_prok then 
              if znajdz_puste(x,y,i,j) then 
                przesun(x,y,i,j); 
          end; 
      end; 
  end; 
end;
{wlasciwy Krok}
var i:integer;
begin
  for i:=1 to 7 do
    LicznikZmian[i]:=0;
  for n:=1 to bok*bok do
    begin
      LosowanieKomorki(k,l);
      {zwraca losowe a, b - wspolrzedne wylosowanej komorki}
      if (TenSwiat[k,l]>0) then
      {jesli w tym miejscu jest w ogole jakies zyjatko}
        begin
          Kroczek(k,l,TenSwiat,zmiana_stanu);
          LicznikZmian[zmiana_stanu]:= LicznikZmian[zmiana_stanu]+1;
          {to jest zmienna globalna, zaraz wykorzystam ja w statystykach}
        end;
    end;
end;

var NumerKroku:integer=0;

procedure ZapisStatystyk(var out: text; TenSwiat:Swiat);
var 
   i,j:integer; 
   Licznik:Array[1..3] of integer; 
begin

  for i:=1 to 3 do
    Licznik[i]:=0;
  for i:=1 to bok do
    for j:=1 to bok do
      if TenSwiat[i,j]>0 then
        Licznik[TenSwiat[i,j]]:=Licznik[TenSwiat[i,j]]+1;

  write(out,NumerKroku,chr(9));
  for i:=1 to 3 do
    write(out,Licznik[i],chr(9)); 
  for i:=1 to 6 do 
    write(out,LicznikZmian[i],chr(9)); 
  writeln(out); 
end;


procedure MAIN;
var i:integer;
BEGIN 
  TworzWspolrzedne; 
  for i:=1 to 7 do 
    LicznikZmian[i]:=0; 
  assign(out,ZAPIS);
  rewrite(out); 
  for i:=1 to 7 do {Powtarza 7 niezaleznych eksperymentów}
    begin 
      system.writeln(out,'ofiar ',gestosc_of:3:2,', drapie¿ników ',gestosc_drap:3:2,', p1=',p_of_prok:3:2,', p2=',p_drap_zjada:3:2,', p3=',p_drap_prok:3:2,', p4=',p_of_zdycha:3:2,', p5=',p_drap_zdycha:3:2,', p6=',p_drap_glod:3:2);
      system.writeln(out,'krok',chr(9),'Ile Ofiar',chr(9),'Ile g³odnych drap',chr(9),'Ile sytych drap',chr(9),'Smierc ofiary',chr(9),'rozmnozenie sie ofiary',chr(9),'smierc drap',chr(9),'rozmnozenie sie drap',chr(9),'zjedzenie ofiary przez drap',chr(9),'zglodnienie drap');
      Start(NaszSwiat); 
      NumerKroku:=0;
      while NumerKroku<MAXSTEP do
        begin
          ZapisStatystyk(out,NaszSwiat);
          if NumerKroku mod 10 = 0 then
            Wizualizacja(NaszSwiat);
          Krok(NaszSwiat);
          NumerKroku:=NumerKroku+1;
          MoveTo(xPocz¹tek,yPocz¹tek+bok*szer+10);
          Brush(1,255,255,255);
          writeln('Eksperyment ',i,' Krok numer ',NumerKroku,' z ',MAXSTEP,'   ');
        end;
       system.Writeln(out);
    end; 
  close(out);
END;

begin
RunAsAlgo(Main,NAZWAMODELU+' by Jaga Przew³ocka',bok*Szer+Szer+5,bok*Szer+55);
end.
