Program Attitude; 
{Uproszczona implementacja modelu wp�ywu spo�ecznego Nowaka-Latane} 
{Brak si� agent�w, niejawny bias na "wyznania" o ni�szych indeksach
ze wzgl�du na algorytm wybierania nowego pogl�du} 

type 
   agent=record 
        alife:boolean; 
        attid:integer; 
        stres:real; 
   end; 

   const 
   Last=30; 
   Side=12; 
   ProbAlife=1; 
   HowManyAttid=4;
   VisFreq=1; 
type 
   world=array[1..Last,1..Last] of agent; 

procedure Init(var Tab:world); 
{Inicjuje swiat wg. zadanych parametr�w} 

var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      if random<ProbAlife then 
        begin 
          Tab[i,j].alife:=true; 
          Tab[i,j].stres:=0; 
          Tab[i,j].attid:=random(HowManyAttid); 
        end 
      else 
        Tab[i,j].alife:=false; 
end; 

function SElem(var Tab:world;attid:integer;k,l:integer):integer; 
{Sprawdza czy s�siad istnieje i jest �ywy i dolicza} 
{s�siada do sumy stres�w je�li jest  innego  "wyznania"} 

begin 
  if (k>0)and(l>0)and(k<=Last)and(l<=last)and(Tab[k,l].alife)and(Tab[k,l].attid<>attid) then 
    SElem:=1 
  else 
    SElem:=0; 
end; 

procedure CalculateStres(var Tab:world); 
{Oblicza aktualne stresy dla wszystkich agent�w} 

var 
   i,j:integer; 
   {"Current attid" - zmienna pomocnicza} 
   ca:integer; 
   {Suma stres�w} 
   Summ:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      if Tab[i,j].alife then 
        begin 
          ca:=Tab[i,j].attid; 
          {Sprawdzamy s�siedztwo 8 sp�jne} 
          Summ:=SElem(Tab,ca,i+1,j)+ SElem(Tab,ca,i-1,j)+ SElem(Tab,ca,i,j+1)+ SElem(Tab,ca,i,j-1) + SElem(Tab,ca,i+1,j+1)+ SElem(Tab,ca,i-1,j-1)+ SElem(Tab,ca,i-1,j+1)+ SElem(Tab,ca,i+1,j-1); 
          {Maksymalnie o�miu sasiad�w mo�e by� innych} 
          Tab[i,j].stres:=Summ/8; 
        end; 
end; 

{ WERSJA DETERMINISTYCZNA BINARNA      } 
{-------------------------------------------------------} 

procedure DeterministicChange(var Tab:world;x,y:integer); 
{Zmiana stanu agenta w swiecie dwu postaw!}
{Pe�ny konformizm - zmiana na liczniej reprezentowany pogl�d} 
var 
   licznik:integer; 
   lewo,prawo,g�ra,d�,i,j:integer; 
   max,nowy:integer; 
begin 
  licznik:=0; 
  
  lewo:=x-1;  if lewo<1 then lewo:=1; 
  prawo:=x+1; if prawo>Last then prawo:=Last; 
  g�ra:=y-1;  if g�ra<1 then g�ra:=1; 
  d�:=y+1;   if d�>Last then d�:=Last; 
  
  for i:=lewo to prawo do 
    for j:=g�ra to d� do 
      if Tab[i,j].alife then 
        if Tab[i,j].attid>0 then 
          licznik:=licznik+1 
        else 
          licznik:=licznik-1; 
  
  if licznik>0 then 
    Tab[x,y].attid:=1 
  else 
    Tab[x,y].attid:=0 
end; 


{ WERSJA DETERMINISTYCZNA WIELOPOSTAWOWA      } 
{-------------------------------------------------------} 

procedure DeterministicMulti(var Tab:world;x,y:integer); 
{Pe�ny konformizm - zmiana na najliczniej reprezentowany pogl�d} 
var 
   liczniki:array[0..HowManyAttid {-1}] of integer; 
   lewo,prawo,g�ra,d�,i,j:integer; 
   max,nowy:integer; 
begin 
  for i:=0 to HowManyAttid-1 do 
    liczniki[i]:=0; 
  
  lewo:=x-1;  if lewo<1 then lewo:=1; 
  prawo:=x+1; if prawo>Last then prawo:=Last; 
  g�ra:=y-1;  if g�ra<1 then g�ra:=1; 
  d�:=y+1;   if d�>Last then d�:=Last; 
   
  for i:=lewo to prawo do 
    for j:=g�ra to d� do 
      if Tab[i,j].alife then 
        liczniki[Tab[i,j].attid]:=liczniki[Tab[i,j].attid]+1; 
        
  {Wyszukiwanie nowego pogl�du. Niejawnie bias-owane!!!}      
  max:=0; 
  nowy:=-1; 
  for i:=0 to HowManyAttid-1 do 
    if liczniki[i]>max then 
      begin 
        max:=liczniki[i]; 
        nowy:=i; 
      end; 
  Tab[x,y].attid:=nowy; 
end; 
 
{ NAIWNIE PODOBNA DO GETTA WERSJA PROBABILISTYCZNA      } 
{-------------------------------------------------------} 
procedure RandomChange(var Tab:world;i,j:integer); 
{Im wi�kszy stres tym latwiej zmienia pogl�d} 

begin 
  if (random<Tab[i,j].stres) then 
    begin 
      Tab[i,j].attid:=random(HowManyAttid); 
    end; 
end; 

procedure MonteCarloStep(var Tab:world); 

var 
   a,steplenght,i,j,ni,nj:integer; 
begin 
  steplenght:=sqr(Last); 
  for a:=1 to steplenght do 
    begin 
      i:=1+random(Last); 
      j:=1+random(Last); 
      if Tab[i,j].alife then 
         (* RandomChange(Tab,i,j); *)    
       if HowManyAttid=2 then
        DeterministicChange(Tab,i,j)
        else
        DeterministicMulti(Tab,i,j);
    end 
end; 


{ RYSOWANIE               } 
{-------------------------} 

procedure ChangeBorder(v,min,max:real); 

begin 
  v:=(v-min)/(max-min); 
  v:=v*255; 
  {Pen(2,round(v),round(v),0); }
  Pen(2,round(v),0,0); 
end; 

procedure ChangeFill(v,min,max:real); 

begin 
  v:=(v-min)/(max-min); 
  v:=v*255; 
  Brush(1,round(v*0.2),0,round(v*0.9)); {Niebieskie}
end; 

procedure Draw(var Tab:World;x,y,side:integer); 
{Rysuje swiat za pomoc� elips z pokazyjacych ras� i stres} 

var 
   i,j:integer; 
begin 
  for i:=1 to Last do 
    for j:=1 to Last do 
      if Tab[i,j].alife then 
        begin 
          ChangeBorder(Tab[i,j].stres,0,1); 
          ChangeFill(Tab[i,j].attid,0,HowManyAttid-1); 
          rectangle(x+i*side-side,y+j*side-side,x+i*side,y+j*side); 
        end 
      else 
        begin 
          Brush(1,255,255,255); 
          Pen(1,255,255,255); 
          rectangle(x+i*side-side,y+j*side-side,x+i*side,y+j*side); 
        end; 
end; 
{PROGRAM G��WNY           } 
{-------------------------} 

var 
   TheWorld:World; 
   step:integer; 

begin 
  step:=0; 
  Init(TheWorld); 
  CalculateStres(TheWorld); 
  Draw(TheWorld,0,0,Side); 
  repeat 
    MoveTo(0,Last*side+10); 
    Pen(1,0,0,0); 
    Brush(1,255,255,255); 
    Writeln(Step); 
    CalculateStres(TheWorld); 
    if step mod VisFreq = 0 then 
      Draw(TheWorld,0,0,Side); 
    MonteCarloStep(TheWorld); 
    Step:=Step+1; 
  until isEvent; 
end.
