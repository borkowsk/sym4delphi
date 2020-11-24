Program JetkaAutokorelacja; 
{$APPTYPE CONSOLE}
{Program do modelowania }
uses
  Algo in '..\UnitAlgo\Algo.pas';
Const 
   Xo=0.5;{   - Jak 0 lub mniej to bêdzie losowo}
   N = 300;   {Ile iteracji}
   DZIEL=100;
   START=round(0*DZIEL); {dzielone przez DZIEL daje pocz¹tek zakresu r}
   FINAL=round(4*DZIEL); {dzielone przez DZIEL dajekoniec zakresu r}
   SWidth=2*(FINAL-START)+170;
   SHeight=2*(FINAL-START)+20; 
Var 
   szereg:array[0..N] of real;    {Tablica na szereg czasowy dla statystyk} 

function Srednia:real; {Po prostu œrednia arytmetyczna tablicy "Szereg"}
var s:real;
    i:integer;
begin
   s:=0;
  For i:=0 to N do
     s:=s+Szereg[i];
  Srednia:=s/(N+1);    
end;

function Lapunow(r1,r2:real):real; 
{Liczy wyk³adnik Lapunowa dla danego r1 i r2 na podstawie tablicy "Szereg"} 
var a,s,x,ln2:real;
    i:integer;
begin 
  ln2:=ln(2); 
  s:=0;
  For i:=0 to N do 
    Begin 
      x:=Szereg[i];
      if i mod 2 = 0 then  {Obliczenie dla kolejnych iteracji} 
        begin 
         a:=abs(r1-2*r1*x); 
         if a>0 then 
            s:=s+ln(a)/ln2; 
        end 
      else 
        begin  
          a:=abs(r2-2*r2*x); 
          if a>0 then 
            s:=s+ln(a)/ln2; 
        end; 
    end; 
  s:=s/(N+1); 
  Lapunow:=s; {Zwrot wyniku}
end; 

function Autokorelacja(krok:integer):real;
{Liczy autokorelacje o zadanym przesuniêciu} 
var Xs,Ys,summ1,summ2,summ3:real;
    i:integer;
begin 
  Xs:=0; 
  Ys:=0; 
  summ1:=0; 
  summ2:=0; 
  summ3:=0; 
  {Liczenie œrednich - pewnie dosyc podobnych} 
  for i:=0 to N-krok do{ Powy¿ej N-krok ju¿ nie bêdzie} 
      Xs:=Xs+Szereg[i];
  for i:=krok to N do {Od "krok", bo poni¿ej autokolreacji nie liczymy}    
      Ys:=Ys+Szereg[i]; 
  Xs:=Xs/(N-krok); 
  Ys:=Ys/(N-krok); 
  
  {W³aœciwe liczenie korelacji} 
  for i:=0 to N-krok do 
    begin 
      summ1:=summ1+(Xs-Szereg[i])*(Ys-Szereg[i+krok]); 
      summ2:=summ2+sqr(Xs-Szereg[i]); 
      summ3:=summ3+sqr(Ys-Szereg[i+krok]); 
    end; 
  if (summ2>0) and (summ3>0) then  
     Autokorelacja:=summ1/(sqrt(summ2)*sqrt(summ3)) 
     else
     Autokorelacja:=0; {Nieco umownie, bo po prostu nie da siê policzyæ}
end; 

procedure UstawKolorL(v:real); 
{mapowanie v na kolor} 
begin 
  if v> 0 then 
    pen(1,round(v*255),round(v*50),0) 
  else 
    {dla ujemnych} 
    pen(1,0,round(-v*25),round(-v*255)); 
end;

procedure UstawKolor1(v:real); 
{mapowanie v na kolor} 
begin 
  if v> 0 then 
    pen(1,round(v*255),round(v*255),0) 
  else 
    {dla ujemnych} 
    pen(1,0,round(-v*255),round(-v*255)); 
end;
 
procedure main;
Var 
   x:real;    {Stan uk³adu} 
   r1,r2:real;    {Zmieniane parametry kontroli} 
   L,minL,maxL,S,C:real;    {Dla statystyk} 
   i,j,k:integer;    {Zliczanie iteracji} 

Begin 
  minL:=0;{Domyœlny zakres skali} 
  maxL:=1;{ma du¿e szanse siê zmieniæ} 
  For k:=START to FINAL do
    For j:=START to FINAL do 
      Begin 
        if Xo<=0 then
           x:=Random
           else
           x:=Xo; 
        Szereg[0]:=x; 
        r1:=k/DZIEL; 
        r2:=j/DZIEL; 
        For i:=1 to N do 
          Begin 
            if i mod 2 = 0 then 
            {Obliczenie iteracji} 
                x:=r1*x*(1-x) 
            else  
                x:=r2*x*(1-x); 
            Szereg[i]:=x; 
          end; 
          
        {Rysowanie wykladnikow}  
        L:=Lapunow(r1,r2); {Liczy sumê logarytmów a potem z niej srednia}  
        if L>maxL then {Sprawdzanie w jakim zakresie jest wyk³adnik}
          maxL:=L; 
        if L<minL then 
          minL:=L; 
        UstawKolorL(L); 
        point((FINAL-START)+10+k-START,j-START); 
          
        {Rysowanie œrednich}
        S:=Srednia; 
        UstawKolor1(S); 
        point(k-START,(FINAL-START)+10+j-START); 
        
        {Rysowanie autokorelacji}
        C:=Autokorelacja(5);
        UstawKolor1(C);
        point((FINAL-START)+10+k-START,(FINAL-START)+10+j-START); 
        
        {Rysowanie ostatniego stanu}
        UstawKolorL(x);
        point(k-START,j-START);  
      end; 
  {LEGENDA} 
  j:=(FINAL-START);
  For k:=0 to j do 
    begin 
      x:=minL+k/j*(maxL-minL); 
      {Rysowanie skali L} 
      UstawKolorL(x); 
      line(2*j+50,k+1,2*j+80,k+1);
      x:=-1.0+k/j*2;
      UstawKolor1(x);
      line(2*j+50,j+k+10,2*j+80,j+k+10); 
    end; 
  moveto(2*j+82,1);
  write(minL,' ');
  moveto(2*j+82,j-10);
  write(maxL,' ');
  moveto(2*j+82,j+11); 
  write(Format(-1.0,4,2),' ');
  moveto(2*j+82,2*j-10); 
  write(Format(1.0,4,2),' ');
end;
begin
 RunAsALGO(Main, 'Jêtka', SWidth, SHeight);
end.
