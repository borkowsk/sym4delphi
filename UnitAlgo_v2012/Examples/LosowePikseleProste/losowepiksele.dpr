Program LosowePiksele; 
{Proste zastosowanie losowania i grafiki}
uses Algo in '..\..\Algo.pas';

const 
   width=400; 
   height=400; 

procedure dodaj_punkt; 

var 
   x,y:integer; 
begin 
  x:=random(width); 
  y:=random(height); 
  Point(x,y); 
end; 

procedure wylosuj_kolor; 

var 
   r,g,b:integer; 
begin 
  r:=random(256); 
  g:=random(256); 
  b:=random(256); 
  Pen(1,r,g,b);
end; 

procedure Main;
Begin
  While true do 
    begin
      wylosuj_kolor;
      dodaj_punkt; 
    end; 
end;

begin
RunAsALGO(Main,'Random pixels',width+1,height+1);
end.