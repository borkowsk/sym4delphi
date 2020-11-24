Program Losowe_b³¹dzenie3; 
{Losowe b³¹dzenie w obcym œrodowisku ;-) } 

const 
   s=500; 
   last=100; 
var 
   x,y,r,g,b,i,licznik,min,max,sum:integer; 

function distance(x1,y1,x2,y2:real):real; 

begin 
  distance:=sqrt(sqr(x1-x2)+sqr(y1-y2)); 
end; 

begin 
  sum:=0; 
  max:=0; 
  {Brush(1,128,255,255);
  Brush(0,0,0,0);}
  for i:=1 to last do 
    begin 
      licznik:=0; 
      r:=round(random * 255); 
      g:=round(random * 255); 
      b:=round(random * 255); 
      ellipse(0,0,s-1,s-1); 
      {obszar pomiaru} 
      x:=s div 2; 
      y:=s div 2; 
      repeat 
        pen(1,r,g,b); 
        point(x,y); 
        moveto(0,0); 
        write('Krok: ',licznik); 
        x:=x+random(3)-1; 
        y:=y+random(3)-1; 
        licznik:=licznik+1; 
      until distance(x,y,s/2,s/2) > s/2; 
      sum:=sum+licznik; 
      if i=1 then 
        min:=licznik; 
      if licznik < min then 
        min:=licznik; 
      if licznik > max then 
        max:=licznik;  
      moveto(0, 512); 
      writeln('Po ', i, ' przebiegach na ', last, ':'); 
      writeln('min = ', min); 
      writeln('œrednia = ', round(sum/i)); 
      writeln('max = ', max); 
    end; 
end.
