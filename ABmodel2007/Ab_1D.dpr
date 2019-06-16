Program AB_1D_v4; 
{Z duzym bledem inicjacji A ktory zmienia wlasciwosci losowania!!!} 
uses Algo;
const 
   Size=600; 
   MaxStep=10000;
   AStart=1;
   AStep=0.05;
   ATresh=0.01;
   {ale nie ilosc A wplywa lecz sama obecnosc}
   AProb=0.000007;
   {SENsownie dziala tylko do 0.00001}
   BStart=6;
   BStep=0.01;
   ABStep=0.75;
   VisFreq=15;
Type 
   ABCell=record 
        A:real; 
        B:real; 
   end; 
   World=array[1..Size] of ABCell; 
Var 
   Now,Next:World; 
   liczA:integer; 

function log(a,b:real):real; 

begin 
  { (a > 0) and (b > 0) !!!} 
  log := ln(a)/ln(b) 
end; 

function RandomB(n:integer):real; 

var 
   i:integer; 
   ret:real; 
begin 
  ret:=1; 
  for i:=1 to n do 
    ret:=ret*random; 
  RandomB:=ret; 
end; 

Procedure Init(var W:World); 

var 
   i,p:integer; 
Begin 
  for i:=1 to Size do 
    begin 
      W[i].B:= RandomB(BStart); 
      W[i].A:= 0; 
    end; 
  for i:=1 to AStart do 
    begin 
      p:=1+random(Size); 
      W[p].A:=1; 
    end; 
end; 

Procedure Draw(y:integer;var W:World); 

var 
   i:integer; 
Begin 
  for i:=1 to Size do 
    begin 
      if W[i].A>0 then 
        Pen(1,255,255,255) 
      else 
        Pen(1,trunc(log(1+W[i].B,10)*8) mod 256, trunc(log(1+W[i].B,10)*2) mod 256, trunc(log(1+W[i].B,10)*64) mod 256); 
      Point(i,y); 
    end; 
end; 

Procedure ChangeB(var C,N:World); 

var 
   i:integer; 
Begin 
  N[1].B:=(C[1].B+C[2].B)/2*(1-BStep); 
  for i:=2 to Size-1 do 
    begin 
      N[i].B:=(C[i-1].B+C[i].B+C[i+1].B)/3*(1-BStep); 
    end; 
  N[Size].B:=(C[Size-1].B+C[Size].B)/2*(1-BStep); 
end; 

Procedure ChangeA(var C,N:World); 

var 
   i:integer; 
Begin 
  for i:=1 to Size do 
    begin 
      if C[i].A>ATresh then 
        N[i].A:=C[i].A*(1-AStep) 
      else 
        N[i].A:=0; 
      if random<=AProb then 
        begin 
          N[i].A:=1; 
          LiczA:=LiczA+1; 
        end; 
    end; 
end; 

Procedure ProduceBbyA(var C:World); 

var 
   i:integer; 
Begin 
  for i:=1 to Size do 
    if C[i].A>ATresh then 
      C[i].B:=C[i].B+C[i].B*ABStep; 
end; 

Procedure CopyWorld(var T,S:World); 

var 
   i:integer; 
Begin 
  for i:=1 to Size do 
    T[i]:=S[i]; 
end; 

function FindMaxB(var C:World):real; 

var 
   i:integer; 
   Max:real; 
Begin 
  Max:=0; 
  {Bo mniej i tak byc nie moze} 
  for i:=1 to Size do 
    if C[i].B>Max then 
      Max:=C[i].B; 
  FindMaxB:=Max; 
end; 

procedure DrawScale(x,y,width,height:integer;Max:real);

var 
   i:integer;
   value:real;
begin 
  moveto(x+width+50,y);
  write('Min=0');
  for i:=0 to height do
    begin
      Value:=1+(Max/height)*i;
      Pen(1,trunc(log(Value,10)*8) mod 256, trunc(log(Value,10)*2) mod 256, trunc(log(Value,10)*64) mod 256);
      Line(x,y+i,x+width,y+i);
      if i mod 16 = 0 then
        write('-  ',Value);
    end;
  moveto(x+width,y+height+5);
  write('Max=',Max); 
end; 

var 
   step,coX,coY:integer;

Procedure Main;
Begin 
  LiczA:=AStart; 
  Init(Now);
  Draw(0,Now); 
  for step:=1 to MaxStep do 
    begin 
      ProduceBbyA(Now); 
      CHangeB(Now,Next); 
      ChangeA(Now,Next); 
      CopyWorld(Now,Next); 
      if Step mod VisFreq=0 then 
        Draw(Step div VisFreq,Now);
    end;
  Coordinates(coX,coY);
  MoveTo(0,coY+2);
  Writeln(' Num of A=',LiczA);
  DrawScale(Size+10,0,20,Size,FindMaxB(Now)); 
end;

begin
RunAsAlgo(Main,'AB 1D Model',Size+180,MaxStep div VisFreq +50);
end.
