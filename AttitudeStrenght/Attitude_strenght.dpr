program AttitudeStrenght;
{Porzadna implementacja modelu Nowaka/Latane z si�ami} 
{ i bezpiecznym sprawdzaniem wyboru bez ukrytego biasu}
{ ale za to z mo�liwo�cia u�ycia jawnego biasu }
{ oraz globalnego szumu przestawiaj�cego jak�� cz�� agent�w na losowy poglad}
uses
  SysUtils,
  Algo in '..\UnitAlgo\Algo.pas', {Uwaga na scie�k� do modu�u!}
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

type 
   Agent=record 
        poglad:integer;  {0..IlePogladow-1}
        sila:integer;    {Je�li 0 to martwy}
        stres:integer;   {Ilu ma stresuj�cych s�siad�w?}
   end; 
   
   Swiat=array[1..MaxBok,1..MaxBok] of Agent;
   wartosc_licznika=double;//double bo czasem trzeba subtelne r�nice sprawdza�
   zbiorlicznikow=array[0..MaxIlePostaw{-1}] of wartosc_licznika;

procedure Inicjacja(var TenSwiat:Swiat);
{Wype�nianie �wiata. Nie�ywe maj� si�� = 0}
var 
   i,j,k:integer; 
   pomoc:real;
begin 
  for i:=1 to Bok do 
    for j:=1 to Bok do 
      begin 
        if Random<Zaludnienie then
          begin {�ywy} 
            TenSwiat[i,j].poglad:=random(IlePostaw); 
            pomoc:=1; 
            for k:=1 to Rozklad do
              pomoc:=pomoc*random; 
            TenSwiat[i,j].sila:=1+trunc(pomoc*(MaxSila-1));
            TenSwiat[i,j].stres:=0; {Na razie nie zestresowany...}
          end
        else
          begin {Martwy}
            TenSwiat[i,j].poglad:=IlePostaw;
            TenSwiat[i,j].stres:=0; {Nie zestresowany...}
            TenSwiat[i,j].sila:=0; {Bo 0 znaczy MARTWY!!!}
          end; 
      end; 
end; 

function Przeskaluj(v,min,max:real):real; 
{Do wizualizacji}
begin 
  Przeskaluj:=(v-min)/(max-min); 
end; 

function Przelogarytmuj(v,max:real):real; 
{Do wizualizacji}
begin 
  v:=ln(v+1); 
  Przelogarytmuj:=v/ln(max+1); 
end; 

procedure Wizualizacja(var TenSwiat:Swiat); 
{Kwadratami o wielkosci proporcjonalnej do logarytmu sily} 
var 
   i,j:integer;    {Przechodzenie po agentach}
   q,r,s,rRoz:real;  {Przeliczone cechy agenta}
   WRoz,ri,vi:integer;{Rozmiar wewn�trzny i pozycjonowanie}
begin
  RRoz:=1-NajmRoz/Rozmiar;
  WRoz:=Rozmiar-Brzeg; {Nie uwagl�dniamy szeroko�ci obw�dki (Bord), ale to specyfika ALGO}
  for i:=1 to Bok do
    for j:=1 to Bok do
      begin
        pen(Brzeg,100,100,100);
        brush(1,128,128,128);
        Rectangle(i*Rozmiar,j*Rozmiar,(i+1)*Rozmiar,(j+1)*Rozmiar);
        if TenSwiat[i,j].sila>0 then
          begin
            q:=Przeskaluj(TenSwiat[i,j].poglad,0,IlePostaw-1)*255;
            r:=Przelogarytmuj(TenSwiat[i,j].sila,MaxSila)*RRoz;
            s:=Przeskaluj(TenSwiat[i,j].stres,0,8)*255;
            ri:=NajmRoz+round(r*(WRoz-NajmRoz)); 
            vi:={Brzeg div 2+}(Rozmiar-ri) div 2;
            Pen(1,0{round(s)},round(s),0{round(s)});
            Brush(1,round(20+q*0.7),round(20+q*0.3),round(20+q*0.3)); 
            Rectangle(i*Rozmiar+vi,j*Rozmiar+vi,i*Rozmiar+vi+ri,j*Rozmiar+vi+ri);
          end; 
      end; 
end;

procedure KrokSymulacji(var TenSwiat:Swiat);
{Procedura zmiany stanu symulacji. Zawiera procedury pomocnicze.} 

procedure ZliczWplywy(x,y:integer;var Liczniki:zbiorlicznikow); 
{Wewnetrzna procedura dla KrokSymulacji} 
var 
   lewo,prawo,gora,dol,i,j:integer; 
begin 
  lewo:=x-1;   if lewo<1 then lewo:=1; 
  prawo:=x+1;  if prawo>Bok then  prawo:=Bok;
  gora:=y-1;   if gora<1 then gora:=1; 
  dol:=y+1;    if dol>Bok then dol:=Bok;

  if WartoscBiasu<>0 then
        Liczniki[PostawaBias]:=WartoscBiasu;

  for i:=lewo to prawo do 
    for j:=gora to dol do
      if TenSwiat[i,j].sila>0 then 
        Liczniki[TenSwiat[i,j].poglad]:=Liczniki[TenSwiat[i,j].poglad]+TenSwiat[i,j].sila;{!!!}
end;

function Ustalpoglad(var Liczniki:zbiorlicznikow):integer;
{Wewnetrzna funkcja dla KrokSymulacji, znajduj�ca nawi�kszy licznik} 
var 
   max:wartosc_licznika;
   nowy,i,j:integer;
begin 
  max:=0; 
  nowy:=-1;
  j:=random(IlePostaw);{Zeby uniknac niejawnego bias-owania} 
  for i:=0 to IlePostaw-1 do {Petla tylko dba o przejrzenioe calej tablicy}
  begin
    if liczniki[j]>max then
      begin 
        max:=liczniki[j];
        nowy:=j; 
      end; 
    j:=(j+1)mod IlePostaw; {Zeby obejsc cala tablice zaczynajac z losowego miesjca}
  end;
  Ustalpoglad:=nowy;
end; 

var 
   i,j,k,l,N:integer; 
   liczniki:zbiorlicznikow;
begin 
  N:=Bok*Bok; 
  for k:=1 to N do 
    begin
      for l:=0 to IlePostaw do 
        liczniki[l]:=0;
      i:=1+random(Bok);
      j:=1+random(Bok);
      if Random<PoziomSzumu then
          TenSwiat[i,j].poglad:=Random(IlePostaw)
          else
          begin
          ZliczWplywy(i,j,liczniki);
          TenSwiat[i,j].poglad:=Ustalpoglad(liczniki);
          end;
    end; 
end;


procedure PoliczStresy(var Tab:Swiat);
{Oblicza aktualne stresy dla wszystkich agent�w}
var
   i,j:integer;
   ca:integer; {"Current attid" - zmienna pomocnicza}
   Suma:integer; {Suma stres�w}

function SElem(akpoglad:integer;k,l:integer):integer;
{Sprawdza czy s�siad istnieje i jest �ywy i dolicza}
{s�siada do sumy stres�w je�li jest  innego  "wyznania"}
begin
  if (k>0)and(l>0)and(k<=Bok)and(l<=Bok)
    and(Tab[k,l].sila>0)
    and(Tab[k,l].poglad<>akpoglad)
  then
    SElem:=1
  else
    SElem:=0;
end;

begin
  for i:=1 to Bok do
    for j:=1 to Bok do
      if Tab[i,j].sila>0 then
        begin
          ca:=Tab[i,j].poglad;
          {Sprawdzamy s�siedztwo 8 sp�jne}
          Suma:=SElem(ca,i+1,j)+ SElem(ca,i-1,j)
              + SElem(ca,i,j+1)+ SElem(ca,i,j-1)
              + SElem(ca,i+1,j+1)+ SElem(ca,i-1,j-1)
              + SElem(ca,i-1,j+1)+ SElem(ca,i+1,j-1);
          {Maksymalnie o�miu sasiad�w mo�e by� innych}
          Tab[i,j].stres:=Suma;
        end;
end;

procedure PoliczStatystyki(var Tab:Swiat;var StresGlobalny:double;var Wyznawcy:zbiorlicznikow);
var i,j,N:integer;
begin
  for i:=0 to IlePostaw do Wyznawcy[i]:=0;
  StresGlobalny:=0;
  N:=0;//Tak �atwiej
  for i:=1 to Bok do
    for j:=1 to Bok do
      if Tab[i,j].sila>0 then
        begin
        N:=N+1;
        StresGlobalny:=StresGlobalny+Tab[i,j].stres;
        Wyznawcy[Tab[i,j].poglad]:=Wyznawcy[Tab[i,j].poglad]+1;
        end;
  if N>0 then
     StresGlobalny:=StresGlobalny/N;
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

var
   SwiatSymulacji:Swiat;
   numerkroku:integer;

Procedure Main;
var F:text;
    N:string;
    StresGlobalny:double;
    Wyznawcy:zbiorlicznikow;
    i:integer;
begin
  Inicjacja(SwiatSymulacji);
  numerkroku:=0;
  N:=FileNameCore
      +inttostr(Bok)+'x'+inttostr(Bok)  {Dlugo�� boku �wiata}
      +'P'+inttostr(IlePostaw)   {Liczba konkuruj�cych poglad�w 2..10}
      +'G'+floattostr(Zaludnienie) {Zaludnienie zaludnienia 0..1}
      +'N'+floattostr(PoziomSzumu) {Szum czyli losowe "mutacje" pogl�d�w - 0..1 bo to prawdopodobie�stwo, ale ��te ju� pow 0.05}
      +'R'+inttostr(Rozklad)  {Stopien rozk�adu "Pareto" >=0 - zero daje brak rozkladu, same MaxSila. Max: 12}
      +'m'+inttostr(MaxSila)   {Najwieksza sila - musi byc odpowiednio du�a do rozk�adu min:1, max: 1 000 000}
      +'.log';
  assign(F,N);
  rewrite(F);
  writeln(F,N);
  writeln(F,'Krok',chr(9),'Stres',chr(9),'Liczby wyznawc�w');
  repeat
    PoliczStresy(SwiatSymulacji);
    PoliczStatystyki(SwiatSymulacji,StresGlobalny,Wyznawcy);
    if numerkroku mod CzestoscWizualizacji=0 then
          Wizualizacja(SwiatSymulacji);
    {Wypisywanie}
    brush(1,255,255,255);
    writeln;Moveto(1,(Bok+1)*Rozmiar);//Pozycjonowanie na konsoli i w oknie
    writeln(numerkroku,'  *  ',StresGlobalny);
    write(F,numerkroku,chr(9),floattostr(StresGlobalny));
    for i:=0 to IlePostaw-1 do
      begin
      write(F,chr(9),Wyznawcy[i]);
      write(' ',Wyznawcy[i],' ');
      end;
    writeln(F);
    delay(Chwila);
    {Kolejny krok}
    KrokSymulacji(SwiatSymulacji);
    numerkroku:=numerkroku+1;
  until UserStop or (NumerKroku>MaxKrok);
  writeln(F);
  close(F);
end;

{Szablonowy program g��wny inicjuj�cy formularze i uruchamiaj�cy modu� ALGO}
begin
Algo.InitialiseUnit; //MUSI BY� TU BO INACZEJ SetupForm NIE MA ZINICJOWANEJ APLIKACJI!
Application.Title := 'Wp�yw spo�eczny';
Application.CreateForm(TSetupForm, SetupForm);
{Tworzenie formy konfiguracyjnej}
InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpi�cie jej do struktur modu�u}
RunAsALGO(Main,'Wp�yw spo�eczny Nowaka/Latane',SWIDTH,SHEIGHT);{Uruchomienie modu�u}
{Kod umieszczony poni�ej wykona si� po zamkni�ciu g��wnego okna, albo i nigdy...}
end.

