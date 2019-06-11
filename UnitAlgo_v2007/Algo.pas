unit Algo;
(*
IMPLEMENTACJA CZÊŒCI NIESTANDARDOWEGO INTERFEJSU "ALGO" DLA DELPHI   wersja 0.22
================================================================================
Autor: Wojciech Borkowski,                                            28.03.2007
          Instytut Studiów Spo³ecznych UW: borkowsk@samba.iss.uw.edu.pl
          Spo³eczna Psychologia Informatyki i Komunikacji (SPIK) SWPS:
                                           borkowsk@spik.swps.edu.pl

Unit ma przygotowywaæ "formê" z obrazkiem do rysowania i implementowaæ funkcje
graficzne i inne niezbêdne (IsEvent i Event) specyficzne dla kompilatorka ALGO.
Ponadto ma zaimplementowany zestaw procedur Write/Writeln, zeby pisanie odbywa³o
siê jak w ALGO na okno graficzne. Nie ma natomiast w³asnego zestawu read co
mo¿e objawiac sie brakiem synchronizacji okna graficznego i konsoli na ktorej
dziala read bez parametru plikowego.
*)

interface
const DELPHI_VERSION=8;{7,8...Warunkowa kompilacja w zaleznoœci od wersji Delphi}

(*
SPOSÓB U¯YCIA:
Program dla ALGO nale¿y zapisac pod nazw¹ z rozszerzeniem dpr (Delphi project)
i umiescic w koatalogu razem z plikami Algo.pas i Algo.dfm. Plik dfm nie jest potrzebnym gdy
kompilator Delphi jest w wersji wiekszej ni¿ 7 - ale trzeba wtedy zmieniæ definicje DELPHI_VERSION w pliku Algo.pas na wartoœæ wiêksz¹ ni¿ 7.

Po pierwszej linii programu w pliku dpr, brzmi¹cej zwykle jakos tak:

Program Nazwaprogramu;

Trzeba umieœciæ liniê:

uses Algo in 'Algo.pas';  {$APPTYPE CONSOLE}

Nastêpnie pierwotny program g³ówny nale¿y przekszta³ciæ w procedurê
(nazwan¹ np. Main), a w nowym programie g³ównym umieœciæ jedynie wywo³anie
procedury uruchamiaj¹cej aplikacje:

begin
RunAsALGO(Main,'Nazwa aplikacji')
end.

czyli podaj¹c jako pierwszy parametr procedurê reprezentuj¹c¹ dawny program
g³ówny, a jako drugi nazwê dla okna. Mo¿na podaæ te¿ wymagane rozmiary u¿ytkowe
okna grafiki jako dwa kolejne parametry. Np.:

RunAsALGO(Main,'Moja aplikacja',800,600)

Po nacisnieciu pierwszego przycisku w oknie graficznym procedura Main zostanie
uruchomiona w osobnym w¹tku mog¹cym u¿ywaæ interfejsu kompatybilnego z
rozszerzeniami ALGO w stosunku do standardu PASCALa.
Wyjœcie graficzne zostanie skierowane, w zaleznosci od stanu drugiego przycisku,
na paintbox lub image okna graficznego, a tekstowe do okna oraz jednoczeœnie na
konsolê.
Gdy dzia³anie w¹tku "g³ównego" siê zakoñczy, wszystkie przyciski okna graficznego 
staj¹ siê szare i mozna je jedynie zamkn¹æ.


POPRAWKI W WERSJACH: 
0.22: 
 * Dodano wywo³anie procedury Randomize w inicjacji w¹tku g³ównego dla poprawienia zgodnoœci z tym co robi ALGO
 * Usuniêcie b³êdu w wariantowej kompilacji dla wersji 6 i 7 (z plikiem dfm) i wyzszych (bez pliku)

ZNANE NIEKOMPATYBILNOŒÆI I B£ÊDY:
 * Ze wzgledu na brak parametrów otwartych w Delphi procedury write[ln]
akceptuj¹ jedynie do 6 parametrów. Wywo³ania z wiêksz¹ liczb¹ parametrów trzeba
podzieliæ.

 * Brak jest wlasnej implementacji Read, Readln, wiêc procedury te mog¹ nie
dzia³ac asynchronicznie w stosunku do okna graficznego. Mo¿na u¿yc przed
dodatkowej procedury AlgoSync;

 * Funkcje readln/read czytaj¹ treœæ tylko z konsoli tekstowej nie pozostawiaj¹c echa na ekranie graficznym i nie przechodz¹c tam do nastêpnej linii. 

 * W wersji 6 i 7 nie dzia³a nachylenie tekstu, a  ¿adnej nie dzia³a wyt³uszczanie

 * Rysowanie w trybie pliku graficznego - czyli przygotowanie do zapisu "obrazka" jest bardzo powolne, a ponadto czêsto potrafi pomijaæ fragmenty rysunku. Wynika to z nieodkrytego b³êdu wspó³dzia³ania obu w¹tków programu i okaza³o siê niezwykle trudne do usuniêcia
 
 * Nie zaimplementowano PlaySound - zamiast tego jest prosty sygna³ dŸwiêkowy
*)

{
Procedura uruchamiania aplikacji:
Uruchamia procedure zrobion¹ z programu g³ownego ALGO w osobnym w¹tku,
ktory mo¿e uzywaæ poni¿szego podzbioru interfejsu ALGO.
}
type MainProcedure=procedure;
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application'; 
                    Width:integer=800;
                    Height:integer=800
                    );

{Grafika podstawowa}
Procedure Line(x1, y1, x2, y2: Integer);{Rysuje odcinek linii prostej ³¹cz¹cy punkt o wspó³rzêdnych (x1, y1) z punktem o wspó³rzêdnych (x2, y2). Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x2, y2).}
Procedure LineTo(x, y: Integer);{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu o wspó³rzêdnych (x, y). Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x, y).}
Procedure MoveTo(x, y: Integer);{Przemieszcza kursor graficzny do punktu o wspó³rzêdnych (x, y).}
Procedure Coordinates(Var x, y: Integer);{Zwraca informacjê o wspó³rzêdnych kursora graficznego.}
Procedure Pen(n, r, g, b: Integer);{Ustala kolor i gruboœæ rysowanych linii. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - gruboœæ.}
Procedure Brush(k, r, g, b: Integer);{Ustala kolor i styl wype³nienia. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim. Jeœli k=1 to figury s¹ zamalowywane wybranym kolorem pêdzla, jeœli k=0 to kolor jest przezroczysty.}
Procedure TextColor(r, g, b: Integer);{Okreœla kolor dla wypisywanych tekstów procedurami Pisz i PiszLn. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim.}
Procedure Rectangle(x1, y1, x2, y2: Integer);{Rysuje prostok¹t, którego przeciwleg³e wierzcho³ki maj¹ wspó³rzêdne (x1, y1) i (x2, y2). Przesuwa tak¿e kursor graficzny do punktu o wspó³rzêdnych (x2, y2).}
Procedure Ellipse(x1, y1, x2, y2: Integer);{Rysuje elipsê. Parametry okreœlaj¹ wspó³rzêdne dwóch przeciwleg³ych wierzcho³ków prostok¹ta opisanego na elipsie. Wspó³rzêdne kursora graficznego nie ulegaj¹ zmianie.}
Procedure Point(x, y: Integer);{Zaznacza punkt o wspó³rzêdnych (x, y) w kolorze pisaka. Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x, y).}
Procedure Fill(x, y: Integer);{Wype³nia zadanym kolorem pêdzla wnêtrze obszaru obejmuj¹cego punkt o wspó³rzêdnych (x, y).}
Procedure Font(rozmiar, kierunek, grubosc: Integer);{Wybiera rozmiar (6..72), kierunek (0..359) i gruboœæ (1..1000) wypisywanych tekstów procedurami Pisz i PiszLn. Argumentami procedury Czcionka mog¹ byæ dowolne wyra¿enia ca³kowite.}
Procedure Clear;{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym górnym rogu okna wyników.
Oprócz wyczyszczenia okna, procedura wykonuje nastêpuj¹ce czynnoœci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype³nienia;
- ustawia czcionkê (8,0,400).
}

{Inne}
Procedure Date(Var rok, miesiac, dzien: integer);{Procedura wylicza aktualn¹ datê, czyli rok (1900..2099), miesi¹c (1..12), dzieñ i dzieñ (1.. 31).}
Procedure Time(Var godzina, minuta, sekunda: Integer);{Procedura wylicza aktualny czas, czyli godzinê (0..23), minuty (0..59) i sekundy (0..59).}
Procedure Delay(ms: Integer);{Wstrzymanie wykonywania programu na okres ms milisekund.}
Procedure PlaySound(atr: Integer; plik: string);{ NIE ZAIMPLEMENTOWANA!
Odtwarza pliki dŸwiêkowe typu *.wav.
Pierwszym parametrem jest wyra¿enie ca³kowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - jeœli w momencie wywo³ania jest odtwarzany inny dŸwiêk to zostanie przerwany;
3 - odtwarzanie w pêtli bez koñca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis okreœlaj¹cy nazwê pliku typu *.wav. W ogólnym przypadku nazwa okreœla pe³n¹ œcie¿kê dostêpu do pliku - dysk, folder i jego nazwê.
}

{Okienne wejœcie-wyjœcie}
Function IsEvent: Boolean;{Wynikiem funkcji jest wartoœæ logiczna prawda, jeœli od ostatniego wywo³ania procedury Zdarzenie zasz³o jakieœ zdarzenie (naciœniêcie klawisza klawiatury lub lewego przycisku myszy w obrêbie okna wyników), w przeciwnym przypadku fa³sz.}

Procedure Event(Var k, x, y: Integer);{Za zdarzenie uwa¿a siê naciœniêcie klawisza na klawiaturze lub wciœniêcie lewego przycisku myszki w obrêbie okna wyników. Jeœli w momencie wywo³ania procedury zdarzenia jeszcze nie by³o, to program oczekuje zdarzenia.
Wywo³anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y wartoœci:
k=1, x=kod, y=0 - naciœniêto klawisz steruj¹cy nie maj¹cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciœniêto klawisz steruj¹cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciœniêto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wspó³rzêdne kursora myszy - wciœniêto lewy przycisk myszy;
k=3, x, y=wspó³rzêdne kursora myszy - mysz przemieszcza siê z wciœniêtym lewym przyciskiem.
}

procedure Writeln;overload;
procedure Write(p1:variant);overload;
procedure Writeln(p1:variant);overload;
procedure Write(p1,p2:variant);overload;
procedure Writeln(p1,p2:variant);overload;
procedure Write(p1,p2,p3:variant);overload;
procedure Writeln(p1,p2,p3:variant);overload;
procedure Write(p1,p2,p3,p4:variant);overload;
procedure Writeln(p1,p2,p3,p4:variant);overload;
procedure Write(p1,p2,p3,p4,p5:variant);overload;
procedure Writeln(p1,p2,p3,p4,p5:variant);overload;
procedure Write(p1,p2,p3,p4,p5,p6:variant);overload;
procedure Writeln(p1,p2,p3,p4,p5,p6:variant);overload;

{I niestety plikowe, bo inaczej nie dzia³a}
procedure Writeln(var f:text);overload;
procedure Write(var f:text;p1:variant);overload;
procedure Writeln(var f:text;p1:variant);overload;
procedure Write(var f:text;p1,p2:variant);overload;
procedure Writeln(var f:text;p1,p2:variant);overload;
procedure Write(var f:text;p1,p2,p3:variant);overload;
procedure Writeln(var f:text;p1,p2,p3:variant);overload;
procedure Write(var f:text;p1,p2,p3,p4:variant);overload;
procedure Writeln(var f:text;p1,p2,p3,p4:variant);overload;
procedure Write(var f:text;p1,p2,p3,p4,p5:variant);overload;
procedure Writeln(var f:text;p1,p2,p3,p4,p5:variant);overload;
procedure Write(var f:text;p1,p2,p3,p4,p5,p6:variant);overload;
procedure Writeln(var f:text;p1,p2,p3,p4,p5,p6:variant);overload;

{DO ROZSZERZENIA O TO CZEGO W ALGO NIE MA}
{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw¹, np. readln}
procedure AlgoSync;
{Funkcja pozwalaj¹ca otrzymaæ uchwyt do formularza - trzeba go zrzutowac}
function GetMyForm:pointer;

{IMPLEMENTACJA - NAJLEPIEJ NIE DOTYKAÆ :-) }
implementation
uses  Windows, Messages, SysUtils, Variants, Classes,
      Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,MPlayer;

{$IF DELPHI_VERSION <= 7 } //W starszych wersjach musi byæ plik Algo.dfm
{$R *.dfm}
{$IFEND}

type
  TMyThread = class(TThread)
  private    { Private declarations }
    Main:MainProcedure;
  public
    Completed:boolean;
  protected
    procedure Execute; override;
    Procedure UpdateVCLfromThread;
  end;

var  MyThread:TMyThread;

type
     TQueue = array of record  k,x,y:integer; end;

     TAlgoForm = class(TForm)
     StartStopButton: TButton;
     ImagePaintBoxButton: TButton;
     SavePictButton: TButton;
     MyArea:TPaintBox;
     MyImage:TImage;
     Grabber: TEdit;

     procedure GrabberKeyDown(Sender: TObject; var Key: Word;
                                      Shift: TShiftState);
     procedure GrabberKeyPress(Sender: TObject; var Key: Char);
     procedure GrabberKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
     procedure PaintboxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
     procedure PaintboxMouseClick(Sender: TObject; Button: TMouseButton;
                                  Shift: TShiftState; X, Y: Integer);
     procedure PaintBoxRepaint(Sender: TObject);
     procedure StartStop(Sender: TObject);
     procedure ImageArea(Sender: TObject);
     procedure SaveImage(Sender: TObject);
     procedure WhenClosed(Sender: TObject);
     private
    { Private declarations }
      cx,cy:integer;
      Qlen:integer;
      Queue:TQueue;
      ApplicationName:string;       
     public
    { Public declarations }
      CurrCanvas:TCanvas;
      procedure QInit;
      procedure QAdd(k,x,y:integer);
      function  QGet(var k,x,y:integer):boolean;
      function  QEmpty:boolean;
     end;

var MyForm:TAlgoForm;

{Grafika podstawowa}
Procedure Line(x1, y1, x2, y2: Integer);
{Rysuje odcinek linii prostej ³¹cz¹cy punkt o wspó³rzêdnych (x1, y1)
z punktem o wspó³rzêdnych (x2, y2).
Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x2, y2).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.MoveTo(x1,y1);
MyForm.CurrCanvas.LineTo(x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure LineTo(x, y: Integer);
{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu
 o wspó³rzêdnych (x, y).
 Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.LineTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure MoveTo(x, y: Integer);
{Przemieszcza kursor graficzny do punktu o wspó³rzêdnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.MoveTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure Coordinates(Var x, y: Integer);
{Zwraca informacjê o wspó³rzêdnych kursora graficznego.}
begin
MyForm.CurrCanvas.Lock;
x:=MyForm.CurrCanvas.PenPos.X;
y:=MyForm.CurrCanvas.PenPos.Y;
MyForm.CurrCanvas.Unlock;
end;

Procedure Pen(n, r, g, b: Integer);
{Ustala kolor i gruboœæ rysowanych linii. Parametry r, g, b –
to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - gruboœæ.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pen.Color:=RGB(r,g,b);
MyForm.CurrCanvas.Pen.Width:=n;
MyForm.CurrCanvas.Unlock;
end;

Procedure Brush(k, r, g, b: Integer);
{Ustala kolor i styl wype³nienia. Parametry r, g, b –
to nasycenie kolorami czerwonym, zielonym i niebieskim.
Jeœli k=1 to figury s¹ zamalowywane wybranym kolorem pêdzla,
jeœli k=0 to kolor jest przezroczysty.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Brush.Color:=RGB(r,g,b);
if k>0 then
  MyForm.CurrCanvas.Brush.Style:=bsSolid
  else
  MyForm.CurrCanvas.Brush.Style:=bsClear;//Czy tak zrobiæ przezroczysty brush?
MyForm.CurrCanvas.Unlock;
end;

Procedure Rectangle(x1, y1, x2, y2: Integer);
{Rysuje prostok¹t, którego przeciwleg³e wierzcho³ki maj¹ wspó³rzêdne
(x1, y1) i (x2, y2).
Przesuwa tak¿e kursor graficzny do punktu o wspó³rzêdnych (x2, y2).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Rectangle(x1,y1,x2,y2);
MyForm.CurrCanvas.MoveTo(x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure Ellipse(x1, y1, x2, y2: Integer);
{Rysuje elipsê. Parametry okreœlaj¹ wspó³rzêdne dwóch przeciwleg³ych wierzcho³ków
prostok¹ta opisanego na elipsie. Wspó³rzêdne kursora graficznego nie ulegaj¹ zmianie.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Ellipse(x1,y1,x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure Point(x, y: Integer);
{Zaznacza punkt o wspó³rzêdnych (x, y) w kolorze pisaka.
Przemieszcza tak¿e kursor graficzny do punktu o wspó³rzêdnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pixels[x,y]:=MyForm.CurrCanvas.Pen.Color;
MyForm.CurrCanvas.MoveTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure Fill(x, y: Integer);
{Wype³nia zadanym kolorem pêdzla wnêtrze obszaru obejmuj¹cego punkt o wspó³rzêdnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
//MyForm.CurrCanvas.Pixels[x,y]:=MyForm.CurrCanvas.Brush.Color; ???
MyForm.CurrCanvas.FloodFill(x,y,MyForm.CurrCanvas.Pixels[x,y],fsSurface);
MyForm.CurrCanvas.Unlock;
end;

Procedure TextColor(r, g, b: Integer);
{Okreœla kolor dla wypisywanych tekstów procedurami Pisz i PiszLn.
Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Font.Color:=RGB(r,g,b);//Chyba nie dzia³a poprawnie
MyForm.CurrCanvas.Unlock;
end;

Procedure Font(rozmiar, kierunek, grubosc: Integer);
{Wybiera rozmiar (6..72), kierunek (0..359) i gruboœæ (1..1000)
wypisywanych tekstów procedurami Pisz i PiszLn. Argumentami procedury Czcionka
mog¹ byæ dowolne wyra¿enia ca³kowite.}
begin
MyForm.CurrCanvas.Lock;                    //TFont
MyForm.CurrCanvas.Font.Size:=rozmiar;
{$IF DELPHI_VERSION > 7 } //Mo¿e nie byæ dfm'a
MyForm.CurrCanvas.Font.Orientation:=kierunek*10;//Jakie tu s¹ jednostki???
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Weight
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Font.Pitch???
{$IFEND}
MyForm.CurrCanvas.Unlock;
end;

Procedure Clear;
{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym górnym rogu okna wyników.
Oprócz wyczyszczenia okna, procedura wykonuje nastêpuj¹ce czynnoœci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype³nienia;
- ustawia czcionkê (8,0,400).
}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Brush.Color:=RGB(255,255,255);
MyForm.CurrCanvas.Brush.Style:=bsSolid;
MyForm.CurrCanvas.FillRect(MyForm.CurrCanvas.ClipRect);
MyForm.CurrCanvas.Unlock;
Pen(1,0,0,0);
TextColor(0,0,0);
Brush(0,0,0,0);
Font(8,0,400);
MoveTo(0,0);
end;

{Inne}
Procedure Date(Var rok, miesiac, dzien: integer);
{Procedura wylicza aktualn¹ datê, czyli rok (1900..2099), miesi¹c (1..12), dzieñ i dzieñ (1.. 31).}
var curtime:TDateTime;
    Year: Word;
    Month: Word;
    Day: Word;
begin
curtime:=SysUtils.Date();
DecodeDate(curtime,Year,Month,Day);
rok:=Year;
miesiac:=Month;
dzien:=Day;
end;

Procedure Time(Var godzina, minuta, sekunda: Integer);
{Procedura wylicza aktualny czas, czyli godzinê (0..23), minuty (0..59) i sekundy (0..59).}
var curtime:TDateTime;
    Hour: Word;
    Min: Word;
    Sec: Word;
    MSec: Word;
begin
curtime:=SysUtils.Time();
DecodeTime(curtime,Hour,Min,Sec,MSec);
godzina:=Hour;
minuta:=Min;
sekunda:=Sec;
end;

Procedure Delay(ms: Integer);
{Wstrzymanie wykonywania programu na okres ms milisekund.
Czyli usypianie w¹tku "Main"}
begin
   Sleep(ms*3); {Traktowanie doslowne daje bardzo krotkie uœpienie - Why???}
end;

Procedure PlaySound(atr: Integer; plik: string);
{Odtwarza pliki dŸwiêkowe typu *.wav.
Pierwszym parametrem jest wyra¿enie ca³kowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - jeœli w momencie wywo³ania jest odtwarzany inny dŸwiêk to zostanie przerwany;
3 - odtwarzanie w pêtli bez koñca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis okreœlaj¹cy nazwê pliku typu *.wav.
W ogólnym przypadku nazwa okreœla pe³n¹ œcie¿kê dostêpu do pliku -
dysk, folder i jego nazwê.
}
begin
beep();sleep(200);beep();//Not implemented yet...
//Windows  PlaySound(plik); czy mo¿e :=TMediaPlayer.Create(); Stop;  ???
end;

function GetMyForm:pointer;
begin
  GetMyForm:=MyForm;
end;

{Okienne wejœcie-wyjœcie}
procedure OutVar(p:variant);
var outstr:string;
begin
if system.IsConsole then
    system.write(p);
MyForm.CurrCanvas.Lock;
with MyForm.CurrCanvas do
begin
  outstr:=p;
  if outstr=(chr(10)+chr(13)) then
    begin
    MoveTo(0,PenPos.Y-(Font.Height*10)div 8);
    end
    else
    TextOut(PenPos.X,PenPos.Y,outstr);
  end;
MyForm.CurrCanvas.UnLock;
end;

procedure Writeln;overload;
begin
OutVar(chr(10)+chr(13));
end;

procedure Write(p1:variant);overload;
begin
OutVar(p1);
end;

procedure Writeln(p1:variant);overload;
begin
OutVar(p1);Writeln;
end;

procedure Write(p1,p2:variant);overload;
begin
OutVar(p1);OutVar(p2);
end;

procedure Writeln(p1,p2:variant);overload;
begin
OutVar(p1);OutVar(p2);Writeln;
end;

procedure Write(p1,p2,p3:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);
end;

procedure Writeln(p1,p2,p3:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);Writeln;
end;

procedure Write(p1,p2,p3,p4:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);
end;

procedure Writeln(p1,p2,p3,p4:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);Writeln;
end;

procedure Write(p1,p2,p3,p4,p5:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);
end;

procedure Writeln(p1,p2,p3,p4,p5:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);Writeln;
end;

procedure Write(p1,p2,p3,p4,p5,p6:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);
end;

procedure Writeln(p1,p2,p3,p4,p5,p6:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);Writeln;
end;

{OBS£UGA PLIKÓW - Ach gdzie s¹ procedury ze swobodn¹ liczb¹ parametrów!??}
procedure Writeln(var f:text);overload;
begin
  system.Writeln(f);
end;

procedure Write(var f:text;p1:variant);overload;
begin
  system.Write(f,p1);
end;
procedure Writeln(var f:text;p1:variant);overload;
begin
  system.Writeln(f,p1);
end;

procedure Write(var f:text;p1,p2:variant);overload;
begin
  system.Write(f,p1,p2);
end;
procedure Writeln(var f:text;p1,p2:variant);overload;
begin
  system.Writeln(f,p1,p2);
end;

procedure Write(var f:text;p1,p2,p3:variant);overload;
begin
  system.Write(f,p1,p2,p3);
end;
procedure Writeln(var f:text;p1,p2,p3:variant);overload;
begin
  system.Writeln(f,p1,p2,p3);
end;

procedure Write(var f:text;p1,p2,p3,p4:variant);overload;
begin
  system.Write(f,p1,p2,p3,p4);
end;
procedure Writeln(var f:text;p1,p2,p3,p4:variant);overload;
begin
  system.Writeln(f,p1,p2,p3,p4);
end;

procedure Write(var f:text;p1,p2,p3,p4,p5:variant);overload;
begin
  system.Write(f,p1,p2,p3,p4,p5);
end;
procedure Writeln(var f:text;p1,p2,p3,p4,p5:variant);overload;
begin
  system.Writeln(f,p1,p2,p3,p4,p5);
end;

procedure Write(var f:text;p1,p2,p3,p4,p5,p6:variant);overload;
begin
  system.Write(f,p1,p2,p3,p4,p5,p6);
end;
procedure Writeln(var f:text;p1,p2,p3,p4,p5,p6:variant);overload;
begin
  system.Writeln(f,p1,p2,p3,p4,p5,p6);
end;

Function IsEvent: Boolean;
{Wynikiem funkcji jest wartoœæ logiczna prawda, jeœli od ostatniego wywo³ania
procedury Zdarzenie zasz³o jakieœ zdarzenie (naciœniêcie klawisza klawiatury
lub lewego przycisku myszy w obrêbie okna wyników), w przeciwnym przypadku fa³sz.}
begin
AlgoSync;
MyForm.CurrCanvas.Lock;
result:=not MyForm.QEmpty;
MyForm.CurrCanvas.UnLock;
end;

Procedure Event(Var k, x, y: Integer);
{Za zdarzenie uwa¿a siê naciœniêcie klawisza na klawiaturze lub wciœniêcie
lewego przycisku myszki w obrêbie okna wyników. Jeœli w momencie wywo³ania
procedury zdarzenia jeszcze nie by³o, to program oczekuje zdarzenia.
Wywo³anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y wartoœci:
k=1, x=kod, y=0 - naciœniêto klawisz steruj¹cy nie maj¹cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciœniêto klawisz steruj¹cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciœniêto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wspó³rzêdne kursora myszy - wciœniêto lewy przycisk myszy;
k=3, x, y=wspó³rzêdne kursora myszy - mysz przemieszcza siê z wciœniêtym lewym przyciskiem.
}
begin
AlgoSync;
MyForm.CurrCanvas.Lock;
MyForm.Grabber.Color:=clGray;
MyForm.Grabber.Update;
while MyForm.QEmpty do
      begin //Aktywne czekanie - niezbyt, ale interface watku nie ma innych
      MyForm.CurrCanvas.UnLock;
      AlgoSync;
      MyForm.CurrCanvas.Lock;
      end;

MyForm.QGet(k,x,y);  //Pobierz zdarzenie z kolejki

MyForm.Grabber.Color:=clLtGray;
MyForm.Grabber.Update;
MyForm.CurrCanvas.UnLock;
AlgoSync;
end;

procedure TAlgoForm.QInit;
begin
SetLength(Queue,10000);
QLen:=0;
end;

function TAlgoForm.QEmpty:boolean;
begin
  result:=(QLen=0);
end;

procedure TAlgoForm.QAdd(k,x,y:integer);
begin
Queue[QLen].k:=k;
Queue[QLen].x:=x;
Queue[QLen].y:=y;
inc(QLen);
end;

function TAlgoForm.QGet(var k,x,y:integer):boolean;
begin
if QLen>0 then
  begin
    k:=Queue[0].k;
    x:=Queue[0].x;
    y:=Queue[0].y;
    dec(QLen);
    system.Move(Queue[1],Queue[0],(QLen)*sizeof(Queue[1]));
    result:=true;
  end
  else
    result:=false;
end;

{
k=1, x=kod, y=0 - naciœniêto klawisz steruj¹cy nie maj¹cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciœniêto klawisz steruj¹cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciœniêto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wspó³rzêdne kursora myszy - wciœniêto lewy przycisk myszy;
k=3, x, y=wspó³rzêdne kursora myszy - mysz przemieszcza siê z wciœniêtym lewym przyciskiem.\
}
procedure TAlgoForm.GrabberKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
MyArea.Canvas.Lock;
QAdd(1,Key,0);//Ka¿dy klawisz - tak¿e bez reprezentacji ASCII
//beep();
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.GrabberKeyPress(Sender: TObject; var Key: Char);
begin
MyArea.Canvas.Lock;
dec(QLen); //Jednak jest reprezentacja ASCII
if (Key<chr(31)) then
            QAdd(1,ord(Key),1)//Klawisz sterujacy ASCII
            else
            QAdd(1,ord(Key),2);//Zwyk³y kod ascii
//beep();
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.GrabberKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
MyArea.Canvas.Lock;
 Grabber.Text:='';//Puszczony - czyœcimy
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.paintboxMouseClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MyArea.Canvas.Lock;
QAdd(2,X,Y);//wciœniêto lewy przycisk myszy
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.paintboxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
MyArea.Canvas.Lock;
Grabber.SetFocus();
if ssLeft in Shift then
         QAdd(3,X,Y);//mysz przemieszcza siê z wciœniêtym lewym przyciskiem
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.PaintBoxRepaint(Sender: TObject);
{Odrysowywanie paintboxa prze odslonieciu - tylko t³o}
begin
MyArea.Canvas.Lock;
MyArea.Canvas.FillRect(MyArea.Canvas.ClipRect);
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.StartStop(Sender: TObject);
{Wstrzymywanie wlasciwego watku roboczego}
begin
CurrCanvas.Lock; {Nie mo¿na wstrzymywaæ jeœli wlaœnie rysuje}
if StartStopButton.Caption='Start' then
  begin
  MyThread.Resume; { Uruchamia ten watek}
  StartStopButton.Caption:='Pause'
  end
  else
  begin
  MyThread.Suspend;{ Wstrzymuje w¹tek}
  StartStopButton.Caption:='Start'
  end;
CurrCanvas.UnLock;
end;

procedure TAlgoForm.ImageArea(Sender: TObject);
{Przelaczanie z PaintArea na Image i odwrotnie}
begin
MyForm.Update;
Application.ProcessMessages;//W innym watku, czy to OK?
CurrCanvas.Lock;{Ma byæ zmiana canvasu - trzeba go uchwyciæ!}
if not MyImage.Visible then
begin
  MyImage.Visible:=true;
  MyArea.Visible:=false;
  SavePictButton.Enabled:=true;
  ImagePaintBoxButton.Caption:='Paint fastest';

  CurrCanvas:=MyImage.Canvas;
  MyArea.Canvas.Unlock;
end
else
begin
  MyImage.Visible:=false;
  MyArea.Visible:=true;
  SavePictButton.Enabled:=false;
  ImagePaintBoxButton.Caption:='Paint image';

  CurrCanvas:=MyArea.Canvas;
  MyImage.Canvas.Unlock;
end;
end;

procedure TAlgoForm.SaveImage(Sender: TObject);
begin
  CurrCanvas.Lock;
  MyImage.Picture.SaveToFile(ApplicationName+'.bmp');
  CurrCanvas.UnLock;
end;

procedure PrepareALGOWindow(MyForm:TAlgoForm;setcaption:string;NWidth,NHeight:integer);
{Przygotowywanie Form-y do pracy}
begin
  with MyForm do
   begin
    QInit;
{$IF DELPHI_VERSION > 7 } //Mo¿e nie byæ dfm'a
    MyImage:=TImage.Create(MyForm);
    MyArea:=TPaintBox.Create(MyForm);
    StartStopButton:=TButton.Create(MyForm);
    ImagePaintBoxButton:=TButton.Create(MyForm);;
    SavePictButton:=TButton.Create(MyForm);
    Grabber:=TEdit.Create(MyForm);
    {POWI¥ZANIE UTWORZONYCH "KONTROLEK" Z FORM¥}
    MyImage.Parent:=MyForm;
    MyArea.Parent:=MyForm;
    StartStopButton.Parent:=MyForm;
    ImagePaintBoxButton.Parent:=MyForm;
    SavePictButton.Parent:=MyForm;
    Grabber.Parent:=MyForm;
{$IFEND}

    Caption:='"'+setcaption+'" in ALGO like graphics window';
    ApplicationName:=setcaption;
    MyForm.Width:=NWidth+20;
    if MyForm.Width<350 then
               MyForm.Width:=350;//Musi zostaæ miejsce na przyciski i editbox
    MyForm.Height:=NHeight+70;
    OnDestroy:=WhenClosed;

    StartStopButton.Top:=1;
    StartStopButton.Left:=1;
    StartStopButton.Width:=100;
    StartStopButton.Height:=20;
    StartStopButton.Caption:='Start';
    StartStopButton.OnClick:=StartStop;

    ImagePaintBoxButton.Top:=1;
    ImagePaintBoxButton.Left:=101;
    ImagePaintBoxButton.Width:=100;
    ImagePaintBoxButton.Height:=20;
    ImagePaintBoxButton.Caption:='Paint image';
    ImagePaintBoxButton.OnClick:=ImageArea;

    SavePictButton.Top:=1;
    SavePictButton.Left:=202;
    SavePictButton.Width:=100;
    SavePictButton.Height:=20;
    SavePictButton.Caption:='Save image';
    SavePictButton.Enabled:=false;
    SavePictButton.OnClick:=SaveImage;

    Grabber.Top:=1;
    Grabber.Left:=303;
    Grabber.Height:=20;
    Grabber.Width:=MyForm.ClientWidth-303;
    Grabber.Color:=clLtGray;
    Grabber.OnKeyPress:=GrabberKeyPress;
    Grabber.OnKeyDown:=GrabberKeyDown;
    Grabber.OnKeyUp:=GrabberKeyUp;

    MyImage.Width:=NWidth;
    MyImage.Height:=NHeight;
    MyArea.Width:=NWidth;
    MyArea.Height:=NHeight;

    MyImage.Top:=StartStopButton.Top+StartStopButton.Height;
    MyImage.Left:=(MyForm.ClientWidth-MyImage.Width)div 2;
    MyImage.Visible:=false;
    MyImage.OnMouseDown:=PaintboxMouseClick;
    MyImage.OnMouseMove:=PaintboxMouseMove;

    MyArea.Top:=MyImage.Top;
    MyArea.Left:=MyImage.Left;
    MyArea.Color:=clWhite;
    MyArea.OnPaint:=PaintBoxRepaint;
    MyArea.Visible:=true;
    MyArea.OnMouseDown:=PaintboxMouseClick;
    MyArea.OnMouseMove:=PaintboxMouseMove;

    CurrCanvas:=MyArea.Canvas;
   end;
end;

Procedure TMyThread.Execute;
begin
  Completed:=false;
  { Wykonanie procedury zapamietanej jako "Main" }
  Main;
  {Trochê do zrobienia po "Main"}
  MyForm.CurrCanvas.Lock; {W sumie to chyba wsio ryba gdzie ten semafor?}
  MyForm.StartStopButton.Enabled:=false;
  MyForm.ImagePaintBoxButton.Enabled:=false;
  MyForm.CurrCanvas.UnLock;
  Completed:=true;
end;

Procedure TMyThread.UpdateVCLfromThread;
begin
MyForm.Update;
Application.ProcessMessages;
end;

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw¹, np. readln}
procedure AlgoSync;
begin
//MyThread.Synchronize(MyThread.UpdateVCLfromThread); //TO BARDZO SPOWALNIA
MyThread.UpdateVCLfromThread  //A TAK TE¯ DZIA£A I NIE WIDZIALEM KLOPOTÓW
end;

procedure TAlgoForm.WhenClosed(Sender: TObject);
begin
CurrCanvas.Lock; {Nie mo¿na wstrzymywaæ jeœli wlaœnie rysuje}
if (not MyThread.Suspended)and(not MyThread.Completed)and(not MyThread.Terminated) then
        MyThread.Suspend;
CurrCanvas.UnLock;
end;

{INICJACJA OKNA GRAFICZNEGO I W¥TKU OBSLUGI}
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{Uruchamia procedure zrobiona z programu g³ownego w osobnym w¹tku, ktory mo¿e uzywaæ poni¿szego interfaceu}
begin
  Application.Initialize;
{$IF DELPHI_VERSION <= 7 } //Mo¿e nie byæ dfm'a
  Application.CreateForm(TAlgoForm, MyForm);
{$ELSE}
  Application.CreateForm(TForm, MyForm);//Nie mo¿e byæ TAlgoForm bo wtedy szuka resourców
{$IFEND}
  PrepareALGOWindow(MyForm,AppName,Width,Height);
  {Przygotowuje w¹tek wykonuj¹cy "Main"}
  MyThread:=TMyThread.Create(true);
  MyThread.Main:=Main;
  MyThread.Priority:=tpNormal;//tpLowest;
  Application.Run; {Oddaje sterowanie g³ównego w¹tku do pêtli aplikacji}
  //MyThread.Break;
   //WriteComponentResFile('TAlgoForm.dfm',MyForm);
end;

end.

