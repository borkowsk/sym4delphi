Program CA_2D_life_podobny_graph1_11BLUE; 
{Program Life Conwaya z mozliwoscia przesuwania barier zycia i smierci} 
{Kolorowanie niebieskie z pokazywaniem stabilnych kom�rek}
{GRAFIKA Z ALGO - NIE MA PRZENO�NEJ GRAFIKI DLA PASCALA} 
Uses Algo in '..\..\Algo.pas'; {GRAFIKA Z ALGO}
const 
   RndSeed=0;  {Start generatora}
   Last=100;    {Rozmiar tablicy - Musi byc wi�ksze ni� 1 i najwyzej 160} 
   Steps=10000; {Ile krok�w mo�na wykona� } 
   Prob0=0.66; {Prawdopodobienstwo 0 w inicjalizacji} 
   GranicaSamotnosci=2; 
   GranicaPrzegeszczenia=3; 
   OptimumRozmnazania=3; 
   bok=7;
type 
   TypSwiata=array[1..Last,1..Last] of integer; 
var 
   Swiat:TypSwiata; 
   NowyS:TypSwiata; 
   krok:integer; 

procedure zeruj; 
{Wyzerowanie "Swiat"a aktualnego} 
var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      Swiat[i,j]:=0; 
end; 

procedure losuj; 
{Wylosowanie "Swiat"a aktualnego} 
var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      if random<Prob0 then 
        NowyS[i,j]:=0 
      else 
        NowyS[i,j]:=1; 
end; 

procedure przepisz; 
{Przepisywanie z "NowyS"[wiat] na "Swiat" aktualny} 
begin 
  Swiat:=NowyS; 
end; 

procedure wypisz; 
{Wypisywanie na ekran graficzny} 
{To jest nieprzeno�ne!!!} 
var 
   i,j:integer; 
begin 
  Pen(1,255,255,255);
  for i:=1 to Last do 
    for j:=1 to Last do 
      begin 
        if Swiat[i,j]=0 then 
          Brush(1,254,254,254) 
        else 
          if NowyS[i,j]<>0 then
             Brush(1,0,0,255)
          else
             Brush(1,0,128,255);
        Rectangle(i*bok,j*bok,(i+1)*bok,(j+1)*bok); 
      end; 
  Brush(1,255,255,255);  
  Pen(1,0,0,0);    
end; 

function sprawd�_kom�rke(i,j:integer):integer; 
{Wg zasady "martwych krawedzi"}
begin
if (i>0)and(j>0)and
   (i<=Last)and(j<=Last)and(Swiat[i,j]=1) then
       sprawd�_kom�rke:=1
       else
       sprawd�_kom�rke:=0;
end;

function ile_sasiad�w(i,j:integer):integer; 
var sas:integer;
begin 
ile_sasiad�w:=sprawd�_kom�rke(i-1,j-1)+
              sprawd�_kom�rke(i-1,j)+
              sprawd�_kom�rke(i-1,j+1)+
              sprawd�_kom�rke(i,j-1)+
              sprawd�_kom�rke(i,j+1)+
              sprawd�_kom�rke(i+1,j-1)+
              sprawd�_kom�rke(i+1,j)+
              sprawd�_kom�rke(i+1,j+1);                                                                                    
end; 

procedure zr�b_krok0; 
{W�asciwy krok modelu} 

var 
   i,j:integer; 
   {indeks lewej, �rodkowej i prawej komorki} 
   sas:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      begin 
        sas:=ile_sasiad�w(i,j); 
        
        if Swiat[i,j]=1 then 
          begin 
            if (GranicaSamotnosci<=sas)and(sas<=GranicaPrzegeszczenia) then 
              NowyS[i,j]:=1 
            else 
              NowyS[i,j]:=0; 
          end 
        else 
          if sas=OptimumRozmnazania then 
            NowyS[i,j]:=1 
          else 
            NowyS[i,j]:=0; 
      end; 
end; 

procedure zr�b_krok; 
{W�asciwy krok modelu} 
var 
   i,j:integer; 
   {indeks lewej, �rodkowej i prawej komorki} 
   sas:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      begin 
        sas:=sprawd�_kom�rke(i-1,j-1)+
              sprawd�_kom�rke(i-1,j)+
              sprawd�_kom�rke(i-1,j+1)+
              sprawd�_kom�rke(i,j-1)+
              sprawd�_kom�rke(i,j+1)+
              sprawd�_kom�rke(i+1,j-1)+
              sprawd�_kom�rke(i+1,j)+
              sprawd�_kom�rke(i+1,j+1); 
        
        if Swiat[i,j]=1 then 
          begin 
            if (GranicaSamotnosci<=sas)and(sas<=GranicaPrzegeszczenia) then 
              NowyS[i,j]:=1 
            else 
              NowyS[i,j]:=0; 
          end 
        else 
          if sas=OptimumRozmnazania then 
            NowyS[i,j]:=1 
          else 
            NowyS[i,j]:=0; 
      end; 
end; 


Procedure Main;
LABEL 8888; {Wyjscie z glownej petli bo w algo nie ma break;}
begin 
  if RndSeed<>0 then
     Randomize(RndSeed);
  Losuj; 
  Przepisz;
  wypisz; 
  writeln;
  writeln('          Automat "Rozszerzalne �ycie" o ',Last,'x',Last,' kom�rkach'); 
  for krok:=1 to Steps do 
    begin 
      zr�b_krok; 
      wypisz; 
      przepisz; 
      writeln;
      writeln(format(krok-1,3),') ');
      if IsEvent then goto 8888;
    end; 
    
8888:    
  writeln; 
  writeln('Dzi�kuje i polecam si� na przysz�o��'); 
end;


begin
RunAsAlgo(Main,'2D CA Conway''a Life',(Last+1)*Bok,(Last+1)*Bok+40);
end.

