program AttitudeStrenght; 
{Porzadna implementacja modelu Nowaka/Latane z si³ami} 
{ i bezpiecznym sprawdzaniem wyboru bez ukrytego biasu} 

const 
   Rozm=20;  {D³ugoœæ boku agenta} 
   Brzeg=3;  {Obwodka} 
   NajmRoz=2; {Jaki rozmiar maj¹ najslabsi agenci} 
   
   Bok=20;    {Dlugoœæ boku œwiata} 
   IlePogl¹dów=5; {Liczba konkuruj¹cych pogladów} 
   Gêstoœæ=1; {Gêstoœæ zaludnienia} 
   MaxSi³a=1000;{Najwieksza sila - musi byc odpowiednio du¿a do rozk³adu} 
   Rozk³ad=0;   {Stopien rozk³adu "Pareto" >=0 - zero daje brak rozkladu, same MaxSi³a}  
type 
   Agent=record 
        pogl¹d:integer;  {0..IlePogladow-1} 
        si³a:integer;    {Jeœli 0 to martwy} 
   end; 
   
   Œwiat=array[1..Bok,1..Bok] of Agent; 

procedure Inicjacja(var TenŒwiat:Œwiat); 
{Wype³nianie œwiata. Nie¿ywe maj¹ si³ê = 0}
var 
   i,j,k:integer; 
   pomoc:real; 
begin 
  for i:=1 to Bok do 
    for j:=1 to Bok do 
      begin 
        if Random<Gêstoœæ then 
          begin {¯ywy} 
            TenŒwiat[i,j].pogl¹d:=random(IlePogl¹dów); 
            pomoc:=1; 
            for k:=1 to Rozk³ad do 
              pomoc:=pomoc*random; 
            TenŒwiat[i,j].si³a:=1+trunc(pomoc*(MaxSi³a-1)); 
          end 
        else 
          begin {Martwy} 
            TenŒwiat[i,j].pogl¹d:=IlePogl¹dów; 
            TenŒwiat[i,j].si³a:=0; {Bo 0 znaczy MARTWY!!!} 
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

procedure Wizualizacja(var TenŒwiat:Œwiat); 
{Kwadratami o wielkosci proporcjonalnej do logarytmu sily} 
var 
   i,j:integer;    {Przechodzenie po agentach} 
   q,r,rRoz:real;  {Przeliczone cechy agenta} 
   WRoz,ri,vi:integer;{Rozmiar wewnêtrzny i pozycjonowanie} 
begin 
  RRoz:=1-NajmRoz/Rozm;
  WRoz:=Rozm-Brzeg; {Nie uwaglêdniamy szerokoœci obwódki (Bord), ale to specyfika ALGO}
  for i:=1 to Bok do 
    for j:=1 to Bok do 
      begin 
        pen(Brzeg,100,100,100); 
        brush(1,128,128,128); 
        Rectangle(i*Rozm,j*Rozm,(i+1)*Rozm,(j+1)*Rozm); 
        if TenŒwiat[i,j].si³a>0 then 
          begin 
            q:=Przeskaluj(TenŒwiat[i,j].pogl¹d,0,IlePogl¹dów-1)*255; 
            r:=Przelogarytmuj(TenŒwiat[i,j].si³a,MaxSi³a)*RRoz; 
            ri:=NajmRoz+round(r*(WRoz-NajmRoz)); 
            vi:={Brzeg div 2+}(Rozm-ri) div 2;                      
            Pen(1,0,0,0);
            Brush(1,round(20+q*0.7),round(20+q*0.3),round(20+q*0.3)); 
            Rectangle(i*Rozm+vi,j*Rozm+vi,i*Rozm+vi+ri,j*Rozm+vi+ri); 
          end; 
      end; 
end; 

procedure KrokSymulacji(var TenŒwiat:Œwiat); 
{Procedura zmiany stanu symulacji. Zawiera procedury pomocnicze.} 
type 
   zbiórliczników=array[0..IlePogl¹dów{-1}] of integer; 

procedure ZliczWp³ywy(x,y:integer;var Liczniki:zbiórliczników); 
{Wewnetrzna procedura dla KrokSymulacji} 
var 
   lewo,prawo,góra,dó³,i,j:integer; 
begin 
  lewo:=x-1;   if lewo<1 then lewo:=1; 
  prawo:=x+1;  if prawo>Bok then  prawo:=Bok; 
  góra:=y-1;   if góra<1 then góra:=1; 
  dó³:=y+1;    if dó³>Bok then dó³:=Bok; 
  
  for i:=lewo to prawo do 
    for j:=góra to dó³ do 
      if TenŒwiat[i,j].si³a>0 then 
        Liczniki[TenŒwiat[i,j].pogl¹d]:=Liczniki[TenŒwiat[i,j].pogl¹d]+TenŒwiat[i,j].si³a;{!!!} 
end; 

function UstalPogl¹d(var Liczniki:zbiórliczników):integer; 
{Wewnetrzna funkcja dla KrokSymulacji, znajduj¹ca nawiêkszy licznik} 
var 
   max,nowy,i,j:integer; 
begin 
  max:=0; 
  nowy:=-1; 
  j:=random(IlePogl¹dów);{Zeby uniknac niejawnego bias-owania} 
  for i:=0 to IlePogl¹dów-1 do {Petla tylko dba o przejrzenioe calej tablicy}
  begin
    if liczniki[j]>max then 
      begin 
        max:=liczniki[j]; 
        nowy:=j; 
      end; 
    j:=(j+1)mod IlePogl¹dów; {Zeby obejsc cala tablice zaczynajac z losowego miesjca}  
  end;    
  UstalPogl¹d:=nowy; 
end; 

var 
   i,j,k,l,N:integer; 
   liczniki:zbiórliczników; 
begin 
  N:=Bok*Bok; 
  for k:=1 to N do 
    begin 
      for l:=0 to IlePogl¹dów do 
        liczniki[l]:=0; 
      i:=1+random(Bok); 
      j:=1+random(Bok); 
      ZliczWp³ywy(i,j,liczniki); 
      TenŒwiat[i,j].pogl¹d:=UstalPogl¹d(liczniki); 
    end; 
end; 

var 
   ŒwiatSymulacji:Œwiat; 
   numerkroku:integer; 

begin 
  Inicjacja(ŒwiatSymulacji); 
  numerkroku:=0; 
  repeat 
    Wizualizacja(ŒwiatSymulacji); 
    KrokSymulacji(ŒwiatSymulacji); 
    numerkroku:=numerkroku+1; 
    brush(1,255,255,255); 
    writeln; 
    writeln(numerkroku); 
  until IsEvent; 
end.
