program Dyfuzja;
uses Algo in '../UnitAlgo/Algo.pas';
const
  Bok=100; {liczba komórek boku tablicy}
  xPocz=2; {wspó³rzêdna x lewego górnego rogu rysowanej tablicy}
  yPocz=2; {wspó³rzêdna y lewego górnego rogu rysowanej tablicy}
  Rozm=7; {dlugoœæ boku rysowanych komórek}
  Gestosc=0.1; {gêstoœæ komórek w tablicy}
  pstwo=0.25; {prawdopodobieñstwo ruchu dla 1-ego s¹siada}

type
  Swiat=array[1..Bok,1..Bok] of integer; {1-komórka pe³na, 0-pusta}
  Para=record
    x,y: integer;
  end;
  TabKierunkow=array[0..7] of Para;
  
var
  TenSwiat:Swiat;
  Kierunki:TabKierunkow;
  Komorka, Kierunek:Para;

procedure Inicjalizacja (var ts:Swiat; var tk:TabKierunkow);
 
  procedure Inicjalizacja_Swiata (var ts:Swiat);
    var i,j:integer;
    begin
      for i:=1 to Bok do
        for j:=1 to Bok do
          if (random<Gestosc) then
            ts[i,j]:=1
          else
            ts[i,j]:=0;
    end;
  
  procedure Inicjalizacja_Kierunkow (var tk:TabKierunkow);
    var ix,iy,j:integer;
    begin
      j:=0;
      for ix:=-1 to 1 do
        for iy:=-1 to 1 do
          if not((ix=0) and (iy=0)) then begin
            tk[j].x:=ix;
            tk[j].y:=iy;
            j:=j+1;
          end;
    end;

  begin
    Inicjalizacja_Swiata (ts);
    Inicjalizacja_Kierunkow (tk);
  end;

procedure LosujKomorke (var kom:Para); {zmienia globaln¹ zmienn¹ Komorka}
  begin
    kom.x:=random(bok)+1;
    kom.y:=random(bok)+1;
  end;

procedure LosujKierunek (var kier:Para); {zmienia globaln¹ zmienn¹ Kierunek}
  begin
    kier:=Kierunki[random(8)];
  end;
  
function IluSasiadow (ts:Swiat; var kom:Para):integer; {zwraca liczbê s¹siadów}
  var sx,sy,ix,iy,pom:integer;
  begin
    pom:=0;
    for ix:=-1 to 1 do
      for iy:=-1 to 1 do begin
        sx:=((bok+kom.x+ix-1) mod bok)+1;
        sy:=((bok+kom.y+iy-1) mod bok)+1;
        if (ts[sx,sy]=1) then
          pom:=pom+1;
      end;
    if (ts[kom.x,kom.y]=1) then
      pom:=pom-1;
    IluSasiadow:=pom;
  end;

Function CzyPusta (ts:Swiat; kom:Para):integer; {1-pusta; 0-pe³na}
  begin
    CzyPusta:=1-ts[kom.x,kom.y];
  end;

Function OgolnaMozliwoscRuchu (ts:Swiat; kom:Para):integer; {1-ruch mo¿liwy; 0-ruch niemo¿liwy}
  var ile_s,pom:integer;
  begin
    pom:=0;
    if (CzyPusta(ts,kom)=0) then begin
      ile_s:=IluSasiadow(ts,kom);
      if ((ile_s<1) or (ile_s>2) or ((ile_s=1) and (random<pstwo))) then
        pom:=1;
    end;
    OgolnaMozliwoscRuchu:=pom;
  end;

procedure RysujSwiat (ts:Swiat); {rysowanie ca³ej tablicy}
  var 
     i,j,kolor:integer; 
  begin 
    for i:=1 to bok do 
      for j:=1 to bok do 
        begin 
          kolor:=255*(1-ts[i,j]);
          Pen(1,100,100,100); 
          Brush(1,kolor,kolor,kolor); 
          Rectangle(xPocz+i*Rozm,yPocz+j*Rozm,xPocz+(i+1)*Rozm,yPocz+(j+1)*Rozm); 
        end; 
  end;
  
procedure RysujRuch (ts:Swiat; kom, nowe:Para); {rysowanie tylko tego, co siê zmieni³o}
  var 
    kolor:integer; 
  begin 
    Pen(1,100,100,100);
    kolor:=255*(1-ts[kom.x,kom.y]);
    Brush(1,kolor,kolor,kolor); 
    Rectangle(xPocz+kom.x*Rozm,yPocz+kom.y*Rozm,xPocz+(kom.x+1)*Rozm,yPocz+(kom.y+1)*Rozm);
    kolor:=255*(1-ts[nowe.x,nowe.y]);
    Brush(1,kolor,kolor,kolor); 
    Rectangle(xPocz+nowe.x*Rozm,yPocz+nowe.y*Rozm,xPocz+(nowe.x+1)*Rozm,yPocz+(nowe.y+1)*Rozm);
  end;

procedure Ruch (var ts:Swiat; var kom,nowe:Para);
  begin
    ts[kom.x,kom.y]:=0;
    ts[nowe.x,nowe.y]:=1;
  end;

procedure KrokMC (var ts:Swiat; var kom,kier:Para);
  var
    nowe:Para;
    i,ile_kom:integer;
  begin
    ile_kom:=bok*bok;
    for i:=1 to ile_kom do begin
      LosujKomorke(kom);
      if (OgolnaMozliwoscRuchu(ts,kom)=1) then begin
        LosujKierunek(kier);
        nowe.x:=((bok+kom.x+kier.x-1) mod bok)+1;
        nowe.y:=((bok+kom.y+kier.y-1) mod bok)+1;
        if (CzyPusta(ts, nowe)=1) then begin
          Ruch(ts,kom,nowe);
          RysujRuch(ts,kom,nowe);
          {Delay(10);}
        end;
      end;
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
      brush(1,128,128,128);
      writeln('Hint: ESC --> STOP');
      delay(200);
      end
      else
      UserStop:=true;
  end;
end;
  
procedure Main;
begin
  Inicjalizacja (TenSwiat, Kierunki);
  RysujSwiat (TenSwiat);
  repeat
    KrokMC(TenSwiat, Komorka, Kierunek);
  until UserStop;
end;

BEGIN
RunAsAlgo(Main,'Dyfuzja Ma³gosi Pó³torak',(Bok+2)*Rozm,Bok*Rozm+24);
END.
