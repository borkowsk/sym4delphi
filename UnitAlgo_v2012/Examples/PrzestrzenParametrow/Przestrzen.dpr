Program PrzestrzenParametrówPary;
{
Zadanie "na 6" - przerobiæ program tak ¿eby pokazywa³:
Przekrój przestrzeni parametrów powi¹zanych map logistycznych
z zafiksowanym parametrem alfa.
Statystyka - œrednia ró¿nica, (ale tu bez ABS)
Autorka rozwi¹zania:
    Zuzanna Wojewoda - studentka SPIK
    Wojciech Borkowski - wiêkszoœæ kodu i "odpluskwianie" modyfikacji
}
uses Algo in '..\..\Algo.pas',windows;
Const
   N = 250;
   {Ile iteracji} 
   START=800;
   {dzielone przez DZIEL daje pocz¹tek zakresu r} 
   FINAL=1600;
   {dzielone przez DZIEL daje koniec zakresu r}
   DZIEL=400;
   {Mno¿nik œredniej przy przeliczaniu na kolory} 
   MNOZNIK=100;
   {Zafiksowany parametr kontroli}
   alfa=0.02; {PARAMETR ALFA}
Var
   x,y:real;     {Stany}
   rx,ry:real;   {PARAMETRY KONTROLI - LAMBDY}
   suma,srednia,min,max:real;  {Dla statystyk}
   i,j,k:integer;  {Zliczanie iteracji}


Procedure UstawKolor(v:real); 
Begin 
  If v>0 then
  {mapowanie v na kolor} 
    Pen(1,round(v*255),round(v*50),0)
  else 
    {dla ujemnych} 
    Pen(1,0,round(-v*25),round(-v*255)); 
end; 

procedure Main;
Begin
  min:=100000; 
  max:=-100000; 
  For k:=START to FINAL do
    For j:=START to FINAL do 
      Begin 
        x:=Random;  {LOSOWY STAN POCZ¥TKOWY X}
        y:=Random;  {LOSOWY STAN POCZ¥TKOWY Y}
        suma:=0; {STAN NA POCZ¥TEK}
        srednia:=0; {STAN NA POCZ¥TEK}
        {suma roznic} 
        rx:=k/DZIEL; 
        ry:=j/DZIEL; 
        
        for i:=0 to N do 
          Begin 
            x:=rx*(y*alfa+x*(1-alfa))*(1-(y*alfa+x*(1-alfa)));
            y:=ry*(x*alfa+y*(1-alfa))*(1-(x*alfa+y*(1-alfa)));
            {WZÓR PRZEPISANY ZE SLAJDU 12}
            suma:=suma+(x-y); {DLA JEDNEJ, POJEDYÑCZEJ ITERACJI}
          End; 
        srednia:=suma/N;  {DLA JEDNEGO PUNKTU = 250 Iter.}       
       
        if srednia>max then max:=srednia;
        if srednia<min then min:=srednia;
        
        {Rysowanie œrednich} 
        UstawKolor(srednia*MNOZNIK); 
        Point(k-START,j-START);
      end;

  {LEGENDA}
  For k:=0 to FINAL-START do
    Begin 
      x:=min+k/(FINAL-START)*(max-min); 
      {Rysowanie skali} 
      UstawKolor(x*MNOZNIK); 
      Line(FINAL-START+20,k,FINAL-START+50,k);
    end; 
  MoveTo(FINAL-START+52,0);
  Write(min); 
  MoveTo(FINAL-START+52,FINAL-START);
  Write(max); 
end;

begin
RunAsALGO(Main,'Parametry pary (Coupled logistics maps)',FINAL-START+160,FINAL-START+16);
end.
