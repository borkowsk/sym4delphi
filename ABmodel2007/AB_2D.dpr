Program AB_1D; 
uses Algo;
const 
   Size=300;
   MaxStep=10000;
   AStart=5; 
   AStep=0.05; 
   AProb=0.0000035;
   BStart=6; 
   BStep=0.01; 
   ABStep=6.0; 
   VFreq=10; 
Type 
   ABCell=record 
        A:real; 
        B:real; 
   end; 
   World=array[1..Size,1..Size] of ABCell; 
Var 
   Now,Next:World; 

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
   i,j,p,r:integer; 
Begin 
  for i:=1 to Size do 
    for j:=1 to Size do 
      begin 
        W[i,j].B:= RandomB(BStart); 
        W[i,j].A:= 0; 
      end; 
  for i:=1 to AStart do 
    begin 
      p:=1+random(Size); 
      r:=1+random(Size); 
      W[p,r].A:=1; 
    end; 
end; 

Procedure Draw(x,y:integer;var W:World); 

var 
   i,j:integer; 
Begin 
  for i:=1 to Size do 
    for j:=1 to Size do 
      begin 
        if W[i,j].A>0.1 then 
          Pen(1,trunc(W[i,j].A*255) mod 256, trunc(W[i,j].A*255) mod 256, trunc(W[i,j].A*255) mod 256) 
        else 
          Pen(1,trunc(log(1+W[i,j].B,10)*8) mod 256, trunc(log(1+W[i,j].B,10)*2) mod 256, trunc(log(1+W[i,j].B,10)*64) mod 256);
        Point(x+i,y+j); 
      end; 
end;

Procedure ChangeA(var C,N:World); 

var 
   i,j:integer; 
Begin 
  for i:=1 to Size do 
    for j:=1 to Size do 
      if random>AProb then 
        N[i,j].A:=C[i,j].A*(1-AStep) 
      else 
        if C[i,j].A>0 then 
          N[i,j].A:=0 
        else 
          N[i,j].A:=1; 
end; 

Procedure ProduceBbyA(var C:World); 

var 
   i,j:integer; 
Begin 
  for i:=1 to Size do 
    for j:=1 to Size do 
      begin 
        C[i,j].B:=C[i,j].B+C[i,j].B*C[i,j].A*ABStep; 
      end; 
end; 

Procedure ChangeB(var C,N:World); 

var 
   i,j,k,l,a,b,p,q:integer; 
Begin 
  for i:=1 to Size do 
    for j:=1 to Size do 
      begin 
        if i>1 then 
          a:=i-1 
        else 
          a:=i; 
        if i<Size then 
          b:=i+1 
        else 
          b:=i; 
        if j>1 then 
          p:=j-1 
        else 
          p:=j; 
        if j<Size then 
          q:=j+1 
        else 
          q:=j; 
        N[i,j].B:=0; 
        for k:=a to b do 
          for l:=p to q do 
            N[i,j].B:=N[i,j].B+C[k,l].B; 
        N[i,j].B:=N[i,j].B/((b-a+1)*(q-p+1))*(1-BStep); 
      end; 
end; 

Procedure CopyWorld(var T,S:World); 

var 
   i,j:integer; 
Begin 
  for i:=1 to Size do 
    for j:=1 to Size do 
      T[i,j]:=S[i,j]; 
end; 

var 
   step:integer; 

Procedure Main;
Begin 
  Init(Now); 
  Draw(1,1,Now); 
  for step:=1 to MaxStep do 
    begin 
      ProduceBbyA(Now); 
      CHangeB(Now,Next); 
      ChangeA(Now,Next); 
      CopyWorld(Now,Next); 
      if step mod VFreq = 0 then 
        Draw(1,1,Now); 
      writeln(step); 
    end; 
end;

begin
RunAsAlgo(Main,'AB 2D Model',Size+100,Size*2);
end.
