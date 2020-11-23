Program Skok; 
{Demonstracja pêtli zrobionej za pomoc¹ skoku} 

label A0001;
var 
   x:real; 

Begin 
  A0001: writeln('Ile to jest 2 * 2 ?');
  readln(x); 
  if x<>4 then 
    goto A0001;
  writeln('Tak!'); 
end.
