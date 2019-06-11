program PrizonersInSpace;
{Model spo³ecznego dylematu wiêŸnia z rozmna¿aniem i opcjonalnymi mutacjami}
{Oraz opcjonalnie z uzyciem modelu Nowaka/Latane do zmiany postaw}
uses
  SysUtils,
  Algo in '..\UnitAlgo\Algo.pas',
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

type
   Agent=record 
        poglad:integer;  {0..IlePostaw-1}
        sila:integer;    {Jeœli 0 to martwy}
        stres:double;   {Wartosc stresu ekonomicznego}
   end; 
   
   Swiat=array[1..MaxBok,1..MaxBok] of Agent;

   zbiorlicznikow=array[0..MaxIlePostaw] of integer; {W ostatnim "suma kontrolna"}

{Tablica kierunków do u³atwienia ruchu i interakcji}
const dxy:array[0..7,0..1] of integer=((0,1),(0,-1),(1,0),(-1,0),(-1,-1),(1,1),(-1,1),(1,-1));

procedure Inicjacja(var TenSwiat:Swiat);
{Wype³nianie œwiata. Nie¿ywe maj¹ si³ê = 0}
var
   i,j,k:integer;
   pomoc:real; 
begin
  for i:=1 to Bok do 
    for j:=1 to Bok do 
      begin 
        if Random<Zaludnienie then
          begin {¯ywy} 
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
   WRoz,ri,vi:integer;{Rozmiar wewnêtrzny i pozycjonowanie}
begin
  RRoz:=1-NajmRoz/Rozmiar;
  WRoz:=Rozmiar-Brzeg; {Nie uwaglêdniamy szerokoœci obwódki (Bord), ale to specyfika ALGO}
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
            s:=Przeskaluj(TenSwiat[i,j].stres,0,1)*255;
            ri:=NajmRoz+round(r*(WRoz-NajmRoz)); 
            vi:={Brzeg div 2+}(Rozmiar-ri) div 2;
            Pen(1,round(s),0{round(s)},0{round(s)});
            Brush(1,0,round(255-q),round(q));
            Rectangle(i*Rozmiar+vi,j*Rozmiar+vi,i*Rozmiar+vi+ri,j*Rozmiar+vi+ri);
          end; 
      end;
end;

procedure OpcjonalnyWplywSpoleczny(var TenSwiat:Swiat);
{Procedura zmiany pogl¹dów agentów. Zawiera procedury pomocnicze.}

procedure ZliczWplywy(x,y:integer;var Liczniki:zbiorlicznikow);
{Wewnetrzna procedura dla zliczania wplywów}
var
   lewo,prawo,gora,dol,i,j:integer;
begin
  lewo:=x-1;   if lewo<1 then lewo:=1;
  prawo:=x+1;  if prawo>Bok then  prawo:=Bok;
  gora:=y-1;   if gora<1 then gora:=1;
  dol:=y+1;    if dol>Bok then dol:=Bok;

  for i:=lewo to prawo do
    for j:=gora to dol do
      if TenSwiat[i,j].sila>0 then
        Liczniki[TenSwiat[i,j].poglad]:=Liczniki[TenSwiat[i,j].poglad]+TenSwiat[i,j].sila;{!!!}
end;

function Ustalpoglad(var Liczniki:zbiorlicznikow):integer; 
{Wewnetrzna funkcja dla KrokSymulacji, znajduj¹ca nawiêkszy licznik} 
var 
   max,nowy,i,j:integer;
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
      if TenSwiat[i,j].sila>0 then {Bo bywaj¹ te¿ martwi...}
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
{Oblicza aktualne stresy ekonomiczne dla wszystkich agentów}
var
   i,j:integer;
   Wartosc:double;

function ZliczSasiadow(x,y:integer):integer;
{Wewnetrzna procedura zliczajaca sasiadow}
var
   lewo,prawo,gora,dol,i,j,licznik:integer;
begin
  lewo:=x-1;   if lewo<1 then lewo:=1;
  prawo:=x+1;  if prawo>Bok then  prawo:=Bok;
  gora:=y-1;   if gora<1 then gora:=1;
  dol:=y+1;    if dol>Bok then dol:=Bok;
  licznik:=0;
  for i:=lewo to prawo do
    for j:=gora to dol do
      if Tab[i,j].sila>0 then
        inc(Licznik);
  ZliczSasiadow:=Licznik;
end;

begin
  for i:=1 to Bok do
    for j:=1 to Bok do
      if Tab[i,j].sila>0 then
        begin
          //Na ile dni ma zapas
          Wartosc:=Tab[i,j].sila/KosztKroku;
          //Jaka to czesc wartosci wymaganej?
          Wartosc:=Wartosc/OptimumZapasu;
          //Zapamietaj na Krok MC
          if Wartosc<1 then
            Tab[i,j].stres:=1-Wartosc
          else
            Tab[i,j].stres:=0;
          //Jeœli nie lubi¹ zbytniej ciasnoty to siê wtedy stresuj¹
          if StresZageszczenia and
            (Tab[i,j].stres<0.9) and
            (ZliczSasiadow(i,j)>7) then
              Tab[i,j].stres:=Tab[i,j].stres+0.1;
        end;
end;

var deficytzycia:integer=0;{Ile razy nie uda³o siê posiac nowego agenta}

procedure ZyjIUmieraj(var TenSwiat:Swiat);
{Procedura metabolizmu, rozmna¿ania i poruszania}

function SprobujRuchu(kierunek,x,y:integer;var nx,ny:integer):boolean;
{Czy pole nadaje sie do ruchu?}
begin
  {Nie sprawdzam tu czy nie wieksze ni¿ tablica bo to by dodatkowo kosztowalo}
  nx:=x+dxy[kierunek][0];
  ny:=y+dxy[kierunek][1];
  {Zamkniecie z krawedziami}
  if nx<1 then
    nx:=1;
  if nx>Bok then
    nx:=Bok;
  if ny<1 then
    ny:=1;
  if ny>Bok then
    ny:=Bok;
  {Mozna siê przesun¹c tylko na puste pole}
  SprobujRuchu:=(TenSwiat[nx,ny].sila=0);
end;

procedure Przesuwaj(x,y,nx,ny:integer);
{Przemieszcza agenta w zadane miejsce}
begin
  TenSwiat[nx,ny]:=TenSwiat[x,y];
  {Parowanie sladu}
  TenSwiat[x,y].sila:=0;
  TenSwiat[x,y].stres:=0;
  TenSwiat[x,y].poglad:=IlePostaw;
end;

procedure ZasiejNowego;
{Tworzy nowego agenta jako kopie losowego}
var kierunek,i,j,m,n,NN:integer;
begin
   NN:=Bok*Bok*3;//Zabezpieczenie na nieskonczonosc
   repeat //Tak d³ugo a¿ nie bêdzie pary pól spe³niaj¹cych kryteria
    i:=1+random(Bok);
    j:=1+random(Bok);
    kierunek:=Random(8);
    dec(NN);
    if NN=0 then
        begin
        inc(deficytzycia);
        exit;{Ta procedura ju¿ nie da rady}
        end;
   until (TenSwiat[i,j].sila>KosztKroku*2)and(SprobujRuchu(kierunek,i,j,m,n));
   TenSwiat[i,j].sila:=TenSwiat[i,j].sila div 2;//Bo dzieli siê energi¹
   TenSwiat[i,j].stres:=0;//Przez chwilê nie ma stresu, ¿eby nie uciekli
   TenSwiat[m,n]:=TenSwiat[i,j];

   if (PoziomSzumu>0)and(Random<PoziomSzumu) then {EWENTUALNA MUTACJA}
        TenSwiat[m,n].poglad:=random(IlePostaw);
end;


var
   kierunek,i,j,k,m,n,NN:integer;
begin
 if DeficytZycia<>0 then {Dodatkowa próba zasiania nowego}
   begin
   dec(DeficytZycia);
   ZasiejNowego;
   end;
  NN:=Bok*Bok;
  for k:=1 to NN do
    begin
      i:=1+random(Bok);
      j:=1+random(Bok);
      if TenSwiat[i,j].poglad<>IlePostaw then
               if TenSwiat[i,j].sila<=0 then
                        assert(false,'NIESPÓJNOŒC ALGORYTMU: Agenci z si³¹ <=0 maj¹ postawê!!');
      if TenSwiat[i,j].sila>0 then
        begin
          {Czy aby jeszcze ¿yje}
          TenSwiat[i,j].sila:=TenSwiat[i,j].sila-KosztKroku;
          if TenSwiat[i,j].sila<=0 then
            begin
            {Œmierc i rozk³ad}
            TenSwiat[i,j].sila:=0;
            TenSwiat[i,j].stres:=0;
            TenSwiat[i,j].poglad:=IlePostaw;
            {I nowe ¿ycie...}
            ZasiejNowego();
            end
            else {Ostatecznie próbuje ruchu jesli jest w stresie}
            if Random<TenSwiat[i,j].stres then
             begin
             kierunek:=Random(8);
             if SprobujRuchu(kierunek,i,j,m,n) then
                        Przesuwaj(i,j,m,n);
             end;
        end;
    end;
end;

procedure KooperujRywalizuj(var TenSwiat:Swiat);
var
   kierunek,i,j,k,m,n,NN,p,q:integer;

function SprobujPole(kierunek,x,y:integer;var nx,ny:integer):boolean;
{Czy pole zawiera wspolczlonka spoleczenstwa?}
begin
  {Nie sprawdzam tu czy nie wieksze ni¿ tablica bo to by dodatkowo kosztowalo}
  nx:=x+dxy[kierunek][0];
  ny:=y+dxy[kierunek][1];
  {Zamkniecie z krawedziami}
  if nx<1 then
    nx:=1;
  if nx>Bok then
    nx:=Bok;
  if ny<1 then
    ny:=1;
  if ny>Bok then
    ny:=Bok;
  {Mozna siê przesun¹c tylko na puste pole}
  SprobujPole:=(TenSwiat[nx,ny].sila>0);
end;

function Decyzja(poglad:integer):integer;{Zwraca 0 (koop) albo 1 (rywalizacja)}
var prob:double;
begin
if poglad=0 then Decyzja:=0
else
if poglad=IlePostaw-1 then Decyzja:=1
else
{Niezdecydowany - a to juz trudna sprawa}
   begin
   prob:=poglad/(IlePostaw-1);
   if Random<prob then
      Decyzja:=1 //Im poglad bli¿szy 0 tym trudniej wylosowac rywalizacje!
      else
      Decyzja:=0;
   end;
end;

begin
   NN:=Bok*Bok;
  for k:=1 to NN do
    begin
      i:=1+random(Bok);
      j:=1+random(Bok);
      if TenSwiat[i,j].sila>0 then
        begin
        kierunek:=Random(8);
        if SprobujPole(kierunek,i,j,m,n) then
           begin {Jakas interakcja jest mozliwa}
           p:=Decyzja(TenSwiat[i,j].poglad);
           q:=Decyzja(TenSwiat[m,n].poglad);
           if p=q then {Zagrali to samo!}
             begin
             TenSwiat[i,j].sila:=TenSwiat[i,j].sila+TabelaWyp[p,q];
             TenSwiat[m,n].sila:=TenSwiat[m,n].sila+TabelaWyp[p,q];
             end
             else
             if p=1 then {Pierwszy rywalizuje, to drugi jest frajer}
               begin
               TenSwiat[i,j].sila:=TenSwiat[i,j].sila+TabelaWyp[0,1];
               TenSwiat[m,n].sila:=TenSwiat[m,n].sila+TabelaWyp[1,0];{powinno byc ujemne}
               end
               else {p=0. Pierwszy jest frajer, to drugi rywalizuje}
               begin
               TenSwiat[i,j].sila:=TenSwiat[i,j].sila+TabelaWyp[1,0];{powinno byc ujemne}
               TenSwiat[m,n].sila:=TenSwiat[m,n].sila+TabelaWyp[0,1];
               end;
           {Cos sie zmienilo. Trzeba zadbac o ogolna spojnosc.}
           if TenSwiat[i,j].sila<=0 then TenSwiat[i,j].sila:=1;//Ostatni dech
           if TenSwiat[m,n].sila<=0 then TenSwiat[m,n].sila:=1;//Ostatni dech
           if TenSwiat[i,j].sila>MaxSila then TenSwiat[i,j].sila:=MaxSila;//Nie za du¿o
           if TenSwiat[m,n].sila>MaxSila then TenSwiat[m,n].sila:=MaxSila;//Nie za du¿o
           end;
        end;
    end;
end;

procedure KrokSymulacji(var TenSwiat:Swiat);
begin
  //Jesli u¿ywamy wp³ywu spo³ecznego
  if UzyjWplywuDlaPostaw then
               OpcjonalnyWplywSpoleczny(TenSwiat);
  //Realizacja spo³ecznego dylematu wiêŸnia - zdobywanie zasobów
  KooperujRywalizuj(TenSwiat);
  //Wykonanie ewentualnych ruchów i aplikacja kosztów utrzymania i rozmna¿anie
  ZyjIUmieraj(TenSwiat);
end;

procedure PoliczStatystyki(var Tab:Swiat;var StresGlobalny,SilaSrednia,SilaMax:double;var Wyznawcy:zbiorlicznikow);
var i,j,N:integer;
begin
  SilaSrednia:=0;
  SilaMax:=0;
  for i:=0 to IlePostaw do Wyznawcy[i]:=0;
  StresGlobalny:=0;
  N:=0;//Tak ³atwiej
  for i:=1 to Bok do
    for j:=1 to Bok do
      if Tab[i,j].sila >0 then
        begin
        N:=N+1;
        StresGlobalny:=StresGlobalny+Tab[i,j].stres;
        Wyznawcy[Tab[i,j].poglad]:=Wyznawcy[Tab[i,j].poglad]+1;
        SilaSrednia:=SilaSrednia+Tab[i,j].sila;
        if SilaMax<Tab[i,j].sila then
             SilaMax:=Tab[i,j].sila;
        end;
  Wyznawcy[IlePostaw]:=N;
  if N>0 then
    begin
     StresGlobalny:=StresGlobalny/N;
     SilaSrednia:=SilaSrednia/N;
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
    StresGlobalny,SilaSrednia,SilaMax:double;
    Wyznawcy:zbiorlicznikow;
    i:integer;
    q:double;{pomocnicza zmienna do ustalania kolorów w "histogramie"}

    function BoolToStr(w:boolean;yes,no:string):string;
    begin
        if w then  BoolToStr:=yes
        else BoolToStr:=no
    end;

begin
  Inicjacja(SwiatSymulacji);
  numerkroku:=0;
  deficytzycia:=0;
  N:=FileNameCore
      +inttostr(Bok)+'x'+inttostr(Bok)  {Dlugoœæ boku œwiata}
      +'P'+inttostr(IlePostaw)   {Liczba konkuruj¹cych pogladów 2..10}
      +'G'+floattostr(Zaludnienie) {Zaludnienie zaludnienia 0..1}
      +'M'+floattostr(PoziomSzumu) {Szum czyli losowe "mutacje" pogl¹dów}
//R wlasciwie nieistotne
//      +'R'+inttostr(Rozklad)  {Pocz¹tkowy stopien rozk³adu "Pareto" >=0 - zero daje brak rozkladu, same MaxSila. Max: 12}
      +'m'+inttostr(MaxSila)   {Najwieksza sila - musi byc odpowiednio du¿a do rozk³adu min:1, max: 1 000 000}
      +'k'+inttostr(KosztKroku)
      +'op'+inttostr(OptimumZapasu)
      +'W('+inttostr(TabelaWyp[0,0])+')('+inttostr(TabelaWyp[1,1])+')('+inttostr(TabelaWyp[0,1])+')'
      +BoolToStr(UzyjWplywuDlaPostaw,'WPLY','b.wpl')
      +'-'
      +BoolToStr(StresZageszczenia,'S.ZAG','tlok')
      +'.log';
  assign(F,N);
  rewrite(F);
  writeln(F,N);
  system.writeln(F,'Krok',chr(9),'Stres',chr(9),'EnergiaSr',chr(9),'EnergiaMax',chr(9),'Liczby wyznawców');
  repeat
    PoliczStresy(SwiatSymulacji);
    PoliczStatystyki(SwiatSymulacji,StresGlobalny,SilaSrednia,SilaMax,Wyznawcy);
    if numerkroku mod CzestoscWizualizacji=0 then
          Wizualizacja(SwiatSymulacji);
    {Wypisywanie}
    brush(1,255,255,255);
    pen(1,255,255,255);
    Rectangle(1,(Bok+1)*Rozmiar,SWIDTH,SHEIGHT);
    pen(1,0,0,0);
    TextColor(0,0,0);
    writeln;Moveto(2,(Bok+1)*Rozmiar+1);//Pozycjonowanie na konsoli i w oknie
    write(numerkroku,' *STRES: ',StresGlobalny,' *SI£A: 0->',format(SilaSrednia,0,3),'->',SilaMax);
    writeln(' *¯ywych: ',Wyznawcy[IlePostaw],' (deficyt: ',DeficytZycia,') ');
    write(F,numerkroku,chr(9),floattostr(StresGlobalny),chr(9),floattostr(SilaSrednia),chr(9),floattostr(SilaMax));
    for i:=0 to IlePostaw-1 do
      begin
      q:=Przeskaluj(i,0,IlePostaw-1)*255;
      TextColor(0,round(255-q),round(q));
      write(F,chr(9),Wyznawcy[i]);
      write(' ',Wyznawcy[i],' ');
      end;
    writeln(F);{Tylko do pliku}
    delay(Chwila);
    {Kolejny krok}
    KrokSymulacji(SwiatSymulacji);
    numerkroku:=numerkroku+1;
  until UserStop or (NumerKroku>MaxKrok);
  writeln(F);
  close(F);
end;

{Szablonowy program g³ówny inicjuj¹cy formularze i uruchamiaj¹cy modu³ ALGO}
begin
Algo.InitialiseUnit; //MUSI BYÆ TU BO INACZEJ SetupForm NIE MA ZINICJOWANEJ APLIKACJI!
Application.Title := 'Dylemat wiêŸnia Borkowskiego';
Application.CreateForm(TSetupForm, SetupForm);
  InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpiêcie jej do struktur modu³u}
RunAsALGO(Main,'Spo³eczno-ekonomiczny dylemat wiêŸnia',SWIDTH,SHEIGHT);{Uruchomienie modu³u}
{Kod umieszczony poni¿ej wykona siê po zamkniêciu g³ównego okna, albo i nigdy...}
end.

