program AttitudeStrenght; 
{Porzadna implementacja modelu Nowaka/Latane z si�ami} 
{ i bezpiecznym sprawdzaniem wyboru bez ukrytego biasu} 

const 
   Rozm=20;  {D�ugo�� boku agenta} 
   Brzeg=3;  {Obwodka} 
   NajmRoz=2; {Jaki rozmiar maj� najslabsi agenci} 
   
   Bok=20;    {Dlugo�� boku �wiata} 
   IlePogl�d�w=5; {Liczba konkuruj�cych poglad�w} 
   G�sto��=1; {G�sto�� zaludnienia} 
   MaxSi�a=1000;{Najwieksza sila - musi byc odpowiednio du�a do rozk�adu} 
   Rozk�ad=0;   {Stopien rozk�adu "Pareto" >=0 - zero daje brak rozkladu, same MaxSi�a}  
type 
   Agent=record 
        pogl�d:integer;  {0..IlePogladow-1} 
        si�a:integer;    {Je�li 0 to martwy} 
   end; 
   
   �wiat=array[1..Bok,1..Bok] of Agent; 

procedure Inicjacja(var Ten�wiat:�wiat); 
{Wype�nianie �wiata. Nie�ywe maj� si�� = 0}
var 
   i,j,k:integer; 
   pomoc:real; 
begin 
  for i:=1 to Bok do 
    for j:=1 to Bok do 
      begin 
        if Random<G�sto�� then 
          begin {�ywy} 
            Ten�wiat[i,j].pogl�d:=random(IlePogl�d�w); 
            pomoc:=1; 
            for k:=1 to Rozk�ad do 
              pomoc:=pomoc*random; 
            Ten�wiat[i,j].si�a:=1+trunc(pomoc*(MaxSi�a-1)); 
          end 
        else 
          begin {Martwy} 
            Ten�wiat[i,j].pogl�d:=IlePogl�d�w; 
            Ten�wiat[i,j].si�a:=0; {Bo 0 znaczy MARTWY!!!} 
          end; 
      end; 
end; 

function Przeskaluj(v,min,max:real):real; 
{Do wizualizacji}
begin 
  Przeskaluj:=(v-min)/(max-min); 
end; 

function Przelogarytmuj(v,max:real):real; 
{Do wizualizacji}
begin 
  v:=ln(v+1); 
  Przelogarytmuj:=v/ln(max+1); 
end; 

procedure Wizualizacja(var Ten�wiat:�wiat); 
{Kwadratami o wielkosci proporcjonalnej do logarytmu sily} 
var 
   i,j:integer;    {Przechodzenie po agentach} 
   q,r,rRoz:real;  {Przeliczone cechy agenta} 
   WRoz,ri,vi:integer;{Rozmiar wewn�trzny i pozycjonowanie} 
begin 
  RRoz:=1-NajmRoz/Rozm;
  WRoz:=Rozm-Brzeg; {Nie uwagl�dniamy szeroko�ci obw�dki (Bord), ale to specyfika ALGO}
  for i:=1 to Bok do 
    for j:=1 to Bok do 
      begin 
        pen(Brzeg,100,100,100); 
        brush(1,128,128,128); 
        Rectangle(i*Rozm,j*Rozm,(i+1)*Rozm,(j+1)*Rozm); 
        if Ten�wiat[i,j].si�a>0 then 
          begin 
            q:=Przeskaluj(Ten�wiat[i,j].pogl�d,0,IlePogl�d�w-1)*255; 
            r:=Przelogarytmuj(Ten�wiat[i,j].si�a,MaxSi�a)*RRoz; 
            ri:=NajmRoz+round(r*(WRoz-NajmRoz)); 
            vi:={Brzeg div 2+}(Rozm-ri) div 2;                      
            Pen(1,0,0,0);
            Brush(1,round(20+q*0.7),round(20+q*0.3),round(20+q*0.3)); 
            Rectangle(i*Rozm+vi,j*Rozm+vi,i*Rozm+vi+ri,j*Rozm+vi+ri); 
          end; 
      end; 
end; 

procedure KrokSymulacji(var Ten�wiat:�wiat); 
{Procedura zmiany stanu symulacji. Zawiera procedury pomocnicze.} 
type 
   zbi�rlicznik�w=array[0..IlePogl�d�w{-1}] of integer; 

procedure ZliczWp�ywy(x,y:integer;var Liczniki:zbi�rlicznik�w); 
{Wewnetrzna procedura dla KrokSymulacji} 
var 
   lewo,prawo,g�ra,d�,i,j:integer; 
begin 
  lewo:=x-1;   if lewo<1 then lewo:=1; 
  prawo:=x+1;  if prawo>Bok then  prawo:=Bok; 
  g�ra:=y-1;   if g�ra<1 then g�ra:=1; 
  d�:=y+1;    if d�>Bok then d�:=Bok; 
  
  for i:=lewo to prawo do 
    for j:=g�ra to d� do 
      if Ten�wiat[i,j].si�a>0 then 
        Liczniki[Ten�wiat[i,j].pogl�d]:=Liczniki[Ten�wiat[i,j].pogl�d]+Ten�wiat[i,j].si�a;{!!!} 
end; 

function UstalPogl�d(var Liczniki:zbi�rlicznik�w):integer; 
{Wewnetrzna funkcja dla KrokSymulacji, znajduj�ca nawi�kszy licznik} 
var 
   max,nowy,i,j:integer; 
begin 
  max:=0; 
  nowy:=-1; 
  j:=random(IlePogl�d�w);{Zeby uniknac niejawnego bias-owania} 
  for i:=0 to IlePogl�d�w-1 do {Petla tylko dba o przejrzenioe calej tablicy}
  begin
    if liczniki[j]>max then 
      begin 
        max:=liczniki[j]; 
        nowy:=j; 
      end; 
    j:=(j+1)mod IlePogl�d�w; {Zeby obejsc cala tablice zaczynajac z losowego miesjca}  
  end;    
  UstalPogl�d:=nowy; 
end; 

var 
   i,j,k,l,N:integer; 
   liczniki:zbi�rlicznik�w; 
begin 
  N:=Bok*Bok; 
  for k:=1 to N do 
    begin 
      for l:=0 to IlePogl�d�w do 
        liczniki[l]:=0; 
      i:=1+random(Bok); 
      j:=1+random(Bok); 
      ZliczWp�ywy(i,j,liczniki); 
      Ten�wiat[i,j].pogl�d:=UstalPogl�d(liczniki); 
    end; 
end; 

var 
   �wiatSymulacji:�wiat; 
   numerkroku:integer; 

begin 
  Inicjacja(�wiatSymulacji); 
  numerkroku:=0; 
  repeat 
    Wizualizacja(�wiatSymulacji); 
    KrokSymulacji(�wiatSymulacji); 
    numerkroku:=numerkroku+1; 
    brush(1,255,255,255); 
    writeln; 
    writeln(numerkroku); 
  until IsEvent; 
end.
