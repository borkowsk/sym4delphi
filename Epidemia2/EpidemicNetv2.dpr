Program EpidemicNetv2;
{
Rozbudowana i poprawiona wersja programu do modelowania epidemii na sieci.
Poza poprawkami technicznymi i kosmetycznymi uzupe³niona o:
* tworzenie sieci bezskalowych
* wiêcej rodzajów wizualizacji sieci (w tym zaleznym od stopnia wêz³a)
* wizualizacja u¿ycia poszczególnych po³¹czeñ w przekazywaniu infekcji
}
uses
  Algo in '..\UnitAlgo\Algo.pas',
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

{<--Wszystkie parametry pracy s¹ zdefiniowane jako zmienne w formularzu}

Type
   pnt=record
        x,y:integer;
        end;
   node=record
        x,y:real;
        state:integer;
        end;


const Ludzik:array[1..28] of pnt=
(
(x:0;y:-12),(x:1;y:-12),(x:2;y:-11),(x:2;y:-10),(x:1;y:-8),(x:4;y:-6),(x:4;y:3),
(x:3;y:2),(x:3;y:-3),(x:3;y:0),(x:2;y:11),(x:3;y:11),(x:3;y:12),(x:0;y:12),(x:0;y:2),
(x:0;y:12),(x:-3;y:12),(x:-3;y:11),(x:-2;y:11),(x:-3;y:0),(x:-3;y:-3),(x:-3;y:2),
(x:-4;y:3),(x:-4;y:-6),(x:-1;y:-8),(x:-2;y:-10),(x:-2;y:-11),(x:-1;y:-12));

Var
   TheNodes:array[1..MaxLast] of node; {Tablica wêz³ów}
   TheEdges:array[1..MaxLast,1..MaxLast] of real; {Tablica po³¹czeñ}
   UseEdges:array[1..MaxLast,1..MaxLast] of longword; {Liczniki udanego u¿ycia po³¹czeñ}

   minY,maxY:real;  {Zakres wspó³rzêdnych do wizualizacji}
   minX,maxX:real;  {Musi byæ sprawdzany/ustawiany przy zmianach po³o¿eñ}
   maxUseEdges:longword; {Max liczników udanego u¿ycia po³¹czeñ}


Procedure swap(Var a,b:integer); 
{Pomocnicza procedura zamiany wartoœci zmiennych}
Var 
   pom:integer; 
Begin 
  pom:=a;
  a:=b; 
  b:=pom;
end;

Procedure rysujLudzik(x,y:integer;size:double);
var i:integer;
begin
size:=size/2;
moveto(round(x+Ludzik[1].x*size),round(y+Ludzik[1].y*size));
for i := 2 to 28 do
  lineto(round(x+Ludzik[i].x*size),round(y+Ludzik[i].y*size));
lineto(round(x+Ludzik[1].x*size),round(y+Ludzik[1].y*size));
//fill(x,y);fill(x+1,y);fill(x-1,y);fill(x,y+1);fill(x,y-1);
end;

Procedure CleanArrays; 
{Czyszczenie struktur danych}
Var    i,j:integer; 
Begin 
  For i:=1 to Last do 
    Begin 
      TheNodes[i].x:=0; 
      TheNodes[i].y:=0; 
      TheNodes[i].state:=0; 
      For j:=1 to Last do 
      begin
        TheEdges[i,j]:=0; 
        UseEdges[i,j]:=0;
      end;
    end; 
    maxUseEdges:=0;
end; 

Procedure RandomPosition;
{Nadawanie wêz³om losowych pozycji}
Var    i:integer;
Begin
  For i:=1 to Last do
    Begin
      TheNodes[i].x:=random;
      TheNodes[i].y:=random;
    end;
   minY:=0;maxY:=1;
   minX:=0;maxX:=1;
end;

Procedure RingPositions;
{Nadawanie wêz³om pozycji na okrêgu}
Var
   i:integer;
   alfa:real;
Begin
  For i:=1 to Last do
    Begin
      alfa:=((2*pi)/Last)*i;
      TheNodes[i].x:=0.5+cos(alfa)/2.2;
      TheNodes[i].y:=0.5+sin(alfa)/2.2;
    end;
  minY:=0;maxY:=1;
  minX:=0;maxX:=1;
end;

Procedure LatticePosition;
{Nadawanie wêz³om pozycji na siatce}
Var    i,n:integer;
Begin
  minY:=-1;maxY:=1;
  minX:=-1;maxX:=1;
  n:=trunc(sqrt(Last));
  if n*n<Last then n:=n+1;
  For i:=1 to Last do
    Begin
     with TheNodes[i] do
     begin
      x:=(i-1) div n;
      y:=(i-1) mod n;
      if x>maxX then maxX:=x;
      if y>maxY then maxY:=y;
     end;
    end;
    maxX:=maxX+1;
    maxY:=maxY+1;
end;

Procedure ByConnectPosition;
{Nadawanie wêz³om pozycji wg ich znaczenia}
Var
   i,j:integer;
   alfa,r,ar:real;
   c:integer;
Begin
  minY:=-1;maxY:=1;
  minX:=-1;maxX:=1;
  r:=0;
  {Trzeba policzyæ ile po³aczeñ ma ka¿dy wêze³ i zapamiêtaæ na X}
  For i:=1 to Last do
  Begin
    c:=0;{licznik po³¹czeñ}
    for j := 0 to Last do
    begin
     if TheEdges[i,j]>0 then c:=c+1;
     if TheEdges[j,i]>0 then c:=c+1;
    end;
    TheNodes[i].x:=ln(c+1);
    if TheNodes[i].x>r then
          r:=TheNodes[i].x;
  End;
  r:=r+1;{Srodkowe kó³ko musi byæ z niezerowympromieniem}
  For i:=1 to Last do
    Begin
      alfa:=((2*pi)/Last)*i;
      with TheNodes[i] do
      begin
       ar:=r-x;
       x:=ar*cos(alfa);
       y:=ar*sin(alfa);
       if x>maxX then maxX:=x;
       if y>maxY then maxY:=y;
       if x<minX then minX:=x;
       if y<minY then minY:=y;
      end;
    end;
  minY:=minY-0.1*r;maxY:=maxY+0.1*r;
  minX:=minX-0.1*r;maxX:=maxX+0.1*r;
End;

Procedure RandomEdgesX(ratio:real);
{Losowe po³¹czenia o pe³nej sile}
Var
   i,j:integer;
Begin
  For i:=2 to Last do
    For j:=1 to i-1 do
      If random<ratio then
        TheEdges[i,j]:=1;
end;

Procedure WeightedEdgesX;
{Wa¿one po³¹czenia z ma³ym prawdopodobieñstwem du¿ej wagi}
Var
   i,j:integer;
Begin
  For i:=2 to Last do
    For j:=1 to i-1 do
        TheEdges[i,j]:=random*random*random;
end;

Procedure RandomNetEdges(ratio:real);
{Wa¿one po³¹czenia z ma³ym prawdopodobieñstwem du¿ej wagi}
Var
   i,j:integer;
Begin
  For i:=2 to Last do
   For j:=1 to i-1 do
    begin 
     If random<ratio then
      If weighted then
        TheEdges[i,j]:=random*random*random
      else
        TheEdges[i,j]:=1;
      if PrintNumbers then  
        write(TheEdges[i,j],' ');  
    end;
end;


Procedure RegularNetEdges(ratio:real);
{Wa¿one po³¹czenia z ma³ym prawdopodobieñstwem du¿ej wagi}
Var 
   i,j:integer; 
Begin 
  For i:=2 to Last do 
    Begin
      For j:=i-2 to i-1 do 
        If j>0 then 
          If random<ratio then
            If weighted then
              TheEdges[i,j]:=random*random*random
            else
              TheEdges[i,j]:=1;

      For j:=i-Last+1 to i-Last+2 do
        If j>0 then 
          If random<ratio then
            If weighted then
              TheEdges[i,j]:=random*random*random
            else
              TheEdges[i,j]:=1;

      if PrintNumbers then  
        write(i,' ');        
    end;
end;

Procedure SmallWordClassic(ratio:real);
var
  i,a,b,c,d: Integer;
begin
  RegularNetEdges(ratio);

  if NetParam>Last div 2 then
     NetParam:=Last div 2
     else
     if NetParam<1 then
           NetParam:=1;//Conajmniej jeden

  {Wymiana krawedzi}
  for i := 1 to NetParam do
    begin
      repeat
      a:=random(Last)+1;
      {Usuniêcie po³¹czenia do jednego z dwu s¹siadów}
      if random(2)=0 then
         begin
          c:=a-1;if c<1 then c:=Last;
          d:=a;
         end
         else
         begin
          c:=a+1;if c>Last then c:=1;
          d:=a;
         end;

      if d<c then
          swap(d,c);

      until TheEdges[d,c]<>0;{Konczy tylko wtedy gdy faktycznie znajdzie krawêdŸ!}

      TheEdges[d,c]:=0;

      repeat
      b:=random(Last)+1;
      If a<b then
        swap(a,b);
      until ((a<>b)AND(a<>c)AND(b<>c)AND(TheEdges[a,b]=0)AND(TheEdges[b,a]=0));

      If weighted then
        TheEdges[a,b]:=random*random*random
        else
        TheEdges[a,b]:=1; 
        
      if PrintNumbers then  
        write(TheEdges[a,b],' ');  
    end;
end;

Procedure SmallWordBetter(ratio:real);
var
  i,a,b: Integer;
begin
  RegularNetEdges(ratio);

  if NetParam>Last div 2 then
     NetParam:=Last div 2
     else
     if NetParam<1 then
           NetParam:=1;//Conajmniej jeden
  {Dodatkowe krawêdzie}
  for i := 1 to NetParam do
    begin
      a:=random(Last)+1; {"Poczatek" krawêdzi}
      
      {Tylko poprawne krawêdzie mog¹ byæ pozostawione}
      repeat
      b:=random(Last)+1;{Hipotetyczny koniec}
      If a<b then
        swap(a,b);
      until ((a<>b)AND(TheEdges[a,b]=0)AND(TheEdges[b,a]=0));

      If weighted then
        TheEdges[a,b]:=random*random*random
        else
        TheEdges[a,b]:=1;
      if PrintNumbers then  
        write(TheEdges[a,b],' ');
    end;
end;

Procedure ScaleFree(N,m:integer;k:real);
var
  i,j,new,t: Integer;
  total,sum: Integer;
  tot:array[1..MaxLast] of Integer;
  too:array[1..MaxLast] of Integer;
begin
  if m<2 then
    begin
    writeln('Pocz¹tkowa liczba po³¹czonych wêz³ów nie mo¿e byæ mniejsza ni¿ 2');
    m:=2;
    end;
 {Dla pewnoœci zerowanie}
 for i := 1 to N do
   for j := 1 to N do
      TheEdges[i,j]:=0;
 {Ma³y blok predefiniowanych krawêdzi}
 for i := 1 to m do
   for j := 1 to m do
      TheEdges[i,j]:=1;  
 {Usumiêcie przek¹tnej}
 for i := 1 to m do
      TheEdges[i,i]:=0;          
 {Trzeba policzyæ potrzebne parametry}
 total:=m*(m-1);
 {Pêtla sumuje kolumny tablicy krawêdzi i wpisuje na tot}
 for i := 1 to N do
 begin
   Sum:=0;
   for j := 1 to N do
       Sum:=Sum+trunc(TheEdges[j,i]);
   tot[i]:=Sum;
   if PrintNumbers then
    write(tot[i],',');
 end;  
 if PrintNumbers then  
  writeln;  

 {Teraz zaczynamy dodawaæ krawêdzie}
 for new := m+1 to N do
 begin
  t:=new-1;
  //to=rand(1,t)<(k*tot(1:t)/total);
  for i := 1 to t do
  begin
    if random < (k*tot[i]/total) then 
      too[i]:=1
      else
      too[i]:=0;
    if PrintNumbers then
      write(too[i],',');  
  end;
  if PrintNumbers then
    writeln;
  
  //G(new,1:t)=to; G(1:t,new)=to'; sum(to)
  sum:=0;
  for i := 1 to t do
  begin 
    TheEdges[new,i]:=too[i];
    TheEdges[i,new]:=too[i];
    sum:=sum+too[i];
  end;
  
  total:=total+2*sum;//total=total+2*sum(to);

  //tot(1:t)=tot(1:t)+to;
  for i := 1 to t do
  begin
    tot[i]:=tot[i]+too[i];
    if PrintNumbers then
      write(tot[i],',');
  end;  
  
  tot[new]:=sum;
  if PrintNumbers then
  begin
   write(tot[new],',');
   writeln;
   AlgoSync;
  end;
 end;                              

  //Wa¿enie utworzonych krawêdzi
  if weighted then
   for i := 1 to N do
    for j := 1 to N do
     if TheEdges[i,j]>0 then
       TheEdges[i,j]:=random*random*random;     
 AlgoSync;        
end;


Function Rescale(v,min,max:real;imax:integer):integer;
{Podprocedura a wlasciwie funkcja reskalujaca dane}
Begin
  v:=(v-min)/(max-min);
  Rescale:=round(imax*v);
end;

Procedure ViewGraph;
{PROCEDURA WIZUALIZACJI GRAFU}

Procedure EdgeColor(w,min,max,u:real;maxu:word);
{Podprocedura: Kolor krawêdzi - szary, zale¿ny od wagi}
Begin
  w:=(w-min)/(max-min);
  w:=w*255;
  if u=0 then
    Pen(1,round(255-w),round(255-w),round(255-w))
    else
    begin
    u:=u/maxu;
    u:=u*255;
    Pen(1,round(u),round(255-w),round(255-w))
    end;
end;

Procedure NodeFill(v:integer); 
{Podprocedura: Kolor wêz³a zale¿ny od stanu}
Begin
  If v=0 then
    Begin 
      Brush(1,0,0,155); 
      Pen(1,0,0,155); 
    end
  else
    If v<Duration then
      Begin 
        v:=round(255-(v-1)/(Duration-1)*155); 
        Brush(1,v,0,0); 
        Pen(1,v,0,0); 
      end 
    else
      Begin 
        v:=round(255-(v-Duration)/(Duration+Immunity-Duration)*155); 
        Brush(1,0,v,0); 
        Pen(1,0,v,0); 
      end;
end; 

Var 
   i,j:integer; 
   x1,y1,x2,y2:integer;
Begin {CIA£O PROCEDURY RYSOWANIA}


  {Krawedzie:}
  For i:=2 to Last do
    For j:=1 to i-1 do
      If TheEdges[i,j]>0 then
        Begin
          x1:=Rescale(TheNodes[i].x,minX,maxX,SWidth);
          y1:=Rescale(TheNodes[i].y,minY,maxY,SWidth);
          x2:=Rescale(TheNodes[j].x,minX,maxX,SWidth);
          y2:=Rescale(TheNodes[j].y,minY,maxY,SWidth);
          EdgeColor(TheEdges[i,j],0,1,UseEdges[i,j],maxUseEdges);
          Line(x1,y1,x2,y2);
        end;
  {Wêz³y:}
  For i:=1 to Last do
    Begin
      NodeFill(TheNodes[i].state);
      x1:=Rescale(TheNodes[i].x,minX,maxX,SWidth);
      y1:=Rescale(TheNodes[i].y,minY,maxY,SWidth);
      rysujLudzik(x1,y1,Radius);

      x1:=x1-Radius;
      y1:=y1-Radius;
      x2:=x1+2*Radius;
      y2:=y1+2*Radius;
      Ellipse(x1,y1,x2,y2);

      if PrintNumbers then
        begin
          moveto(x1+2,y1+2);
          TextColor(255,255,0);
          write(i);
        end;
    end;

    TextColor(0,0,0);
end;

procedure MarkEdge(i,j:integer);
var x1,y1,x2,y2:integer;
begin
  x1:=Rescale(TheNodes[i].x,minX,maxX,SWidth);
  y1:=Rescale(TheNodes[i].y,minY,maxY,SWidth);
  x2:=Rescale(TheNodes[j].x,minX,maxX,SWidth);
  y2:=Rescale(TheNodes[j].y,minY,maxY,SWidth);
  Pen(2,255,0,0);
  Line(x1,y1,x2,y2);
end;

Procedure SmallStep(var counter:integer);
{Pojedyncza interakcja pomiêdzy wêz³ami}
Var 
   i,j:integer; 
   w:real; 
Begin 
  {Losowanie 1. partnera interakcji} 
  i:=1+random(Last); 
  {Losowanie 2. partnera ró¿nego od 1} 
  Repeat 
    j:=1+random(Last); 
  until i<>j; 
  
  {Przestawianie partnerów bo po³aczenia s¹ symetryczne} 
  If i<j then
    swap(i,j);
  w:=TheEdges[i,j]; 

  {Infekcja z j na i}
  If w>0 then
    Begin 
      If (TheNodes[i].state=0)and (TheNodes[j].state>0)and(TheNodes[j].state<Duration)and (random<w) then
      begin
        TheNodes[i].state:=1;
        UseEdges[i,j]:=UseEdges[i,j]+1;
        if UseEdges[i,j]>MaxUseEdges then  MaxUseEdges:=UseEdges[i,j];
        if VisJumps then
                MarkEdge(i,j);
      end;
    end
    else
    Begin {...i z i na j}
      If (TheNodes[j].state=0)and (TheNodes[i].state>0)and(TheNodes[i].state<Duration)and (random<w) then
      begin
        TheNodes[j].state:=1;
        UseEdges[i,j]:=UseEdges[i,j]+1;
        if UseEdges[i,j]>MaxUseEdges then  MaxUseEdges:=UseEdges[i,j];
        if VisJumps then
                MarkEdge(i,j);
      end;
    end;

    counter:=counter+1;
end;

Procedure TimeSlice(var intcounter:integer);
{Up³yw czasu - synchroniczna zmiana stanów, infekcja losowa}
Var
   i:integer;
Begin
  For i:=1 to Last do
    If TheNodes[i].state>0 then
      TheNodes[i].state:=(TheNodes[i].state+1)mod(Duration+Immunity);
  {Infekcja}
  For i:=1 to Round(Intensity*Last) do
    SmallStep(intcounter);
end;

Procedure CalculateStat(Var infected,immuned:integer);
{Obliczanie statystyki}
Var
   i:integer;
Begin
  infected:=0;
  immuned:=0;
  For i:=1 to Last do
    If TheNodes[i].state>0 then
      If TheNodes[i].state<Duration then
        infected:=infected+1
      else
        immuned:=immuned+1;
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
var
   outf:text;
   step:integer;
   infected,immuned:integer;
   interactions:integer;
Begin
  Clear;
  step:=0;
  interactions:=0;
  CleanArrays;
  RandomPosition;{Na wszelki wypadek}

  case Topology of
  RandomTopology:{Losowa}
  begin
   writeln('Inicjuje sieæ losow¹');
   RandomNetEdges(ERatio);
   writeln('GOTOWE');
  end;
  LinearTopology:{Pierœcieniowa}
  begin
    writeln('Inicjuje sieæ regularn¹');
    RegularNetEdges(ERatio);
    writeln('GOTOWE');
  end;
  ImSWTopology:{Ulepszone ma³e œwiaty}
  begin
    writeln('Inicjuje sieæ "ulepszone" SmallWorlds');
    SmallWordBetter(ERatio);
    writeln('GOTOWE');
  end;
  ClSWTopology:{Klasyczne ma³e œwiaty}
  begin
    writeln('Inicjuje sieæ SmallWorlds');
    SmallWordClassic(ERatio);
    writeln('GOTOWE');
  end;
  FreeScaleTopology: {sieæ bezskalowa}
  begin
    writeln('Inicjuje sieæ bezskalow¹');
    ScaleFree(Last,NetParam,ERatio);
    writeln('GOTOWE');
  end;
(*    HierarchTopology:{Hierarchiczna}
  begin
  end; ScaleFree(N,m:integer;k:real);         *)

else
  begin
    writeln('Wybrano niezaimplementowan¹ topologiê sieci');
    exit;
  end;
end;

  case Arrangement of
   RandArrangement:RandomPosition;{U³o¿enie losowe  }
   CircleArrangement:RingPositions;{U³o¿enie koliste  }
   LatticeArrangement:LatticePosition;{U³o¿enie macierzowe       }
   ByConnectArrangement:ByConnectPosition;{U³o¿enie wg. liczby po³¹czeñ    }
   FreeModelArrangement:;{U³o¿enie pozostawione modelowi    }
  else begin
    writeln('Wybrano niezdefiniowany sposób u³o¿enia sieci');
    RandomPosition;
  end;
  end;

  Assign(outf,OutFileName+'.log');
  Rewrite(outf);
//  Topology:integer=0;  {Typ sieci: 0-losowa,1-pierscieñ,2-ma³e œwiay,3-lepsze ma³e œwiaty,4-hierarchia}
  system.Writeln(outf,'Topology:',chr(9),Topology);
//   Last:integer=20;    {Ile wezlów}    //OK
  system.Writeln(outf,'Last:',chr(9),Last);
//   NetParam:integer=0;  {Ile przekierowañ albo poziomów hierarchi}
  system.Writeln(outf,'NetParam:',chr(9),NetParam);
//   ERatio:double=0.25;  {Ile po³aczeñ istnieje realnie}   //OK
  system.Writeln(outf,'ERatio:',chr(9),ERatio);
//   Weighted:boolean=false;{Czy po³¹czenia wa¿one?}        //OK
  system.Writeln(outf,'Weighted:',chr(9),Weighted);
//   Intensity:double=5; {Last*Intensity - Ile mo¿liwoœci interakcji ka¿dego dnia}
  system.Writeln(outf,'Intensity:',chr(9),Intensity);
//   Duration:integer=7;   {Czas trwania infekcji}
  system.Writeln(outf,'Duration:',chr(9),Duration);
//   Immunity:integer=31;  {Czas istnienia odpornoœci}
  system.Writeln(outf,'Immunity:',chr(9),Immunity);
  system.Writeln(outf,'Day',chr(9),'infected',chr(9),'immuned',chr(9),'interactions');

  {Czyszczenie przed startem modelu}
  delay(200);
  Algo.Clear;

  {Wprowadzenie infekcji}
  TheNodes[1].state:=1;
  Repeat
    Delay(DelayTime);
    Pen(1,0,0,0);
    Brush(1,255,255,255);
    MoveTo(1,1);
    CalculateStat(infected,immuned);
    Write('day:',step,' inf:',infected,' imm:',immuned);WriteLn(' in.count:',interactions,'      ');
    system.writeln(outf,step,chr(9),infected,chr(9),immuned,chr(9),interactions);
    ViewGraph;
    {Nowy stan}
    step:=step+1;
    TimeSlice(interactions);
  until (infected=0)or UserStop;

  close(outf);
end;

{Szablonowy program g³ówny inicjuj¹cy formularze i uruchamiaj¹cy modu³ ALGO}
begin
Algo.InitialiseUnit; //MUSI BYÆ TU BO INACZEJ SetupForm NIE MA ZINICJOWANEJ APLIKACJI!
Application.Title := 'Epidemic v2 (02.2011)';
Application.CreateForm(TSetupForm, SetupForm);
{Tworzenie formy konfiguracyjnej}
InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpiêcie jej do struktur modu³u}
RunAsALGO(Main,'Epidemic Net v:2.0',SWIDTH,SHEIGHT);{Uruchomienie modu³u}
{Kod umieszczony poni¿ej wykona siê po zamkniêciu g³ównego okna, albo i nigdy...}
end.
