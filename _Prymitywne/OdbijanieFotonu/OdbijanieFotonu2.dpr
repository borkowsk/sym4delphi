Program Odbijanie2; 
{Odbijanie "fotonu" - kliknij w okno ¿eby przerwaæ}
Uses Algo in '..\..\Algo.pas'; {GRAFIKA Z ALGO}
const 
   width=500; 
   height=555; 
   DELA=0;

procedure Main;
var 
   x,y:integer; 
   vx,vy:integer;
begin 
  rectangle(0,0,width,height);{Pudelko - mniej wiêcej}
  
  {Inicjacja pozycji i prêdkoœci}
  x:=width div 2; 
  y:=height div 2; 
  vx:=2-random(5);
  vy:=2-random(5);
  point(x,y);
  
  {Pêtla "dynamiki"}
  repeat 
  x:=x+vx; {przemieszczanie po X}
  y:=y+vy; {przemieszczanie po Y}
  
  lineto(x,y);{Rysowanie przemieszczenia}
  if random(100)=0 then {Czasem zmiana koloru}
     pen(1,random(255),random(255),random(255));
  
  {Wykrywanie odbcia}   
  if (x<=0)or(x>width) then
      vx:=-vx;
  if (y<=0)or(y>height)then
      vy:=-vy;
           
  delay(DELA);{Spowolnienie dla obserwacji}    
  until IsEvent; 
end;

begin
RunAsALGO(Main,'Odbijanie',width,height);  
end.
