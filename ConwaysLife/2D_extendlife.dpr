Program CA_2D_life_i_podobne; 
{Program Life Conwaya z mozliwoscia przesuwania barier zycia i smierci} 
Uses Algo in '..\UnitAlgo\Algo.pas'; {GRAFIKA Z ALGO}

const 
   RndSeed=0;  {Start generatora}
   Last=150;    {Rozmiar tablicy - Musi byc wi�ksze ni� 1 i najwyzej 160 w ALGO}
   Steps=10000; {Ile krok�w mo�na wykona� } 
   Prob0=0.70; {Prawdopodobienstwo 0 w inicjalizacji}
   GranicaSamotnosci=2; 
   GranicaPrzegeszczenia=3; 
   OptimumRozmnazania=3; 
   bok=5;
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
        Swiat[i,j]:=0 
      else 
        Swiat[i,j]:=1; 
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
  for i:=1 to Last do 
    for j:=1 to Last do 
      begin 
        if Swiat[i,j]=0 then 
          Brush(1,0,0,0) 
        else 
          Brush(1,255,0,0); 
        Rectangle(i*bok,j*bok,(i+1)*bok,(j+1)*bok); 
      end; 
  Brush(1,255,255,255);      
end; 

function sprawd�_kom�rke(i,j:integer):integer;inline;
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

Procedure Main;
LABEL 8888; {Wyjscie z glownej petli bo w algo nie ma break;}
begin 
 if RndSeed<>0 then
     Randomize(RndSeed);
  Losuj; 
  wypisz; 
  writeln;
  writeln('            Automat "Rozszerzalne �ycie" o ',Last,'x',Last,' kom�rkach');
  delay(100);
  for krok:=1 to Steps do 
    begin 
      zr�b_krok; 
      przepisz; 
      wypisz; 
      writeln;
      writeln(Format(krok-1,4),' ) ');
      if UserStop then goto 8888;
    end; 
    
8888:
  writeln('Dzi�kuje i polecam si� na przysz�o��'); 
end;

begin
RunAsAlgo(Main,'2D CA Conway''a Life');
end.
