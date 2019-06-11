unit Algo;
(*
IMPLEMENTACJA CZʌCI NIESTANDARDOWEGO INTERFEJSU "ALGO" DLA DELPHI   wersja 0.22
================================================================================
Autor: Wojciech Borkowski,                                            28.03.2007
          Instytut Studi�w Spo�ecznych UW: borkowsk@samba.iss.uw.edu.pl
          Spo�eczna Psychologia Informatyki i Komunikacji (SPIK) SWPS:
                                           borkowsk@spik.swps.edu.pl

Unit ma przygotowywa� "form�" z obrazkiem do rysowania i implementowa� funkcje
graficzne i inne niezb�dne (IsEvent i Event) specyficzne dla kompilatorka ALGO.
Ponadto ma zaimplementowany zestaw procedur Write/Writeln, zeby pisanie odbywa�o
si� jak w ALGO na okno graficzne. Nie ma natomiast w�asnego zestawu read co
mo�e objawiac sie brakiem synchronizacji okna graficznego i konsoli na ktorej
dziala read bez parametru plikowego.
*)

interface
const DELPHI_VERSION=8;{7,8...Warunkowa kompilacja w zalezno�ci od wersji Delphi}

(*
SPOS�B U�YCIA:
Program dla ALGO nale�y zapisac pod nazw� z rozszerzeniem dpr (Delphi project)
i umiescic w koatalogu razem z plikami Algo.pas i Algo.dfm. Plik dfm nie jest potrzebnym gdy
kompilator Delphi jest w wersji wiekszej ni� 7 - ale trzeba wtedy zmieni� definicje DELPHI_VERSION w pliku Algo.pas na warto�� wi�ksz� ni� 7.

Po pierwszej linii programu w pliku dpr, brzmi�cej zwykle jakos tak:

Program Nazwaprogramu;

Trzeba umie�ci� lini�:

uses Algo in 'Algo.pas';  {$APPTYPE CONSOLE}

Nast�pnie pierwotny program g��wny nale�y przekszta�ci� w procedur�
(nazwan� np. Main), a w nowym programie g��wnym umie�ci� jedynie wywo�anie
procedury uruchamiaj�cej aplikacje:

begin
RunAsALGO(Main,'Nazwa aplikacji')
end.

czyli podaj�c jako pierwszy parametr procedur� reprezentuj�c� dawny program
g��wny, a jako drugi nazw� dla okna. Mo�na poda� te� wymagane rozmiary u�ytkowe
okna grafiki jako dwa kolejne parametry. Np.:

RunAsALGO(Main,'Moja aplikacja',800,600)

Po nacisnieciu pierwszego przycisku w oknie graficznym procedura Main zostanie
uruchomiona w osobnym w�tku mog�cym u�ywa� interfejsu kompatybilnego z
rozszerzeniami ALGO w stosunku do standardu PASCALa.
Wyj�cie graficzne zostanie skierowane, w zaleznosci od stanu drugiego przycisku,
na paintbox lub image okna graficznego, a tekstowe do okna oraz jednocze�nie na
konsol�.
Gdy dzia�anie w�tku "g��wnego" si� zako�czy, wszystkie przyciski okna graficznego 
staj� si� szare i mozna je jedynie zamkn��.


POPRAWKI W WERSJACH: 
0.22: 
 * Dodano wywo�anie procedury Randomize w inicjacji w�tku g��wnego dla poprawienia zgodno�ci z tym co robi ALGO
 * Usuni�cie b��du w wariantowej kompilacji dla wersji 6 i 7 (z plikiem dfm) i wyzszych (bez pliku)

ZNANE NIEKOMPATYBILNO��I I B��DY:
 * Ze wzgledu na brak parametr�w otwartych w Delphi procedury write[ln]
akceptuj� jedynie do 6 parametr�w. Wywo�ania z wi�ksz� liczb� parametr�w trzeba
podzieli�.

 * Brak jest wlasnej implementacji Read, Readln, wi�c procedury te mog� nie
dzia�ac asynchronicznie w stosunku do okna graficznego. Mo�na u�yc przed
dodatkowej procedury AlgoSync;

 * Funkcje readln/read czytaj� tre�� tylko z konsoli tekstowej nie pozostawiaj�c echa na ekranie graficznym i nie przechodz�c tam do nast�pnej linii. 

 * W wersji 6 i 7 nie dzia�a nachylenie tekstu, a  �adnej nie dzia�a wyt�uszczanie

 * Rysowanie w trybie pliku graficznego - czyli przygotowanie do zapisu "obrazka" jest bardzo powolne, a ponadto cz�sto potrafi pomija� fragmenty rysunku. Wynika to z nieodkrytego b��du wsp�dzia�ania obu w�tk�w programu i okaza�o si� niezwykle trudne do usuni�cia
 
 * Nie zaimplementowano PlaySound - zamiast tego jest prosty sygna� d�wi�kowy
*)

{
Procedura uruchamiania aplikacji:
Uruchamia procedure zrobion� z programu g�ownego ALGO w osobnym w�tku,
ktory mo�e uzywa� poni�szego podzbioru interfejsu ALGO.
}
type MainProcedure=procedure;
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application'; 
                    Width:integer=800;
                    Height:integer=800
                    );

{Grafika podstawowa}
Procedure Line(x1, y1, x2, y2: Integer);{Rysuje odcinek linii prostej ��cz�cy punkt o wsp�rz�dnych (x1, y1) z punktem o wsp�rz�dnych (x2, y2). Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x2, y2).}
Procedure LineTo(x, y: Integer);{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu o wsp�rz�dnych (x, y). Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x, y).}
Procedure MoveTo(x, y: Integer);{Przemieszcza kursor graficzny do punktu o wsp�rz�dnych (x, y).}
Procedure Coordinates(Var x, y: Integer);{Zwraca informacj� o wsp�rz�dnych kursora graficznego.}
Procedure Pen(n, r, g, b: Integer);{Ustala kolor i grubo�� rysowanych linii. Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - grubo��.}
Procedure Brush(k, r, g, b: Integer);{Ustala kolor i styl wype�nienia. Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim. Je�li k=1 to figury s� zamalowywane wybranym kolorem p�dzla, je�li k=0 to kolor jest przezroczysty.}
Procedure TextColor(r, g, b: Integer);{Okre�la kolor dla wypisywanych tekst�w procedurami Pisz i PiszLn. Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim.}
Procedure Rectangle(x1, y1, x2, y2: Integer);{Rysuje prostok�t, kt�rego przeciwleg�e wierzcho�ki maj� wsp�rz�dne (x1, y1) i (x2, y2). Przesuwa tak�e kursor graficzny do punktu o wsp�rz�dnych (x2, y2).}
Procedure Ellipse(x1, y1, x2, y2: Integer);{Rysuje elips�. Parametry okre�laj� wsp�rz�dne dw�ch przeciwleg�ych wierzcho�k�w prostok�ta opisanego na elipsie. Wsp�rz�dne kursora graficznego nie ulegaj� zmianie.}
Procedure Point(x, y: Integer);{Zaznacza punkt o wsp�rz�dnych (x, y) w kolorze pisaka. Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x, y).}
Procedure Fill(x, y: Integer);{Wype�nia zadanym kolorem p�dzla wn�trze obszaru obejmuj�cego punkt o wsp�rz�dnych (x, y).}
Procedure Font(rozmiar, kierunek, grubosc: Integer);{Wybiera rozmiar (6..72), kierunek (0..359) i grubo�� (1..1000) wypisywanych tekst�w procedurami Pisz i PiszLn. Argumentami procedury Czcionka mog� by� dowolne wyra�enia ca�kowite.}
Procedure Clear;{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym g�rnym rogu okna wynik�w.
Opr�cz wyczyszczenia okna, procedura wykonuje nast�puj�ce czynno�ci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype�nienia;
- ustawia czcionk� (8,0,400).
}

{Inne}
Procedure Date(Var rok, miesiac, dzien: integer);{Procedura wylicza aktualn� dat�, czyli rok (1900..2099), miesi�c (1..12), dzie� i dzie� (1.. 31).}
Procedure Time(Var godzina, minuta, sekunda: Integer);{Procedura wylicza aktualny czas, czyli godzin� (0..23), minuty (0..59) i sekundy (0..59).}
Procedure Delay(ms: Integer);{Wstrzymanie wykonywania programu na okres ms milisekund.}
Procedure PlaySound(atr: Integer; plik: string);{ NIE ZAIMPLEMENTOWANA!
Odtwarza pliki d�wi�kowe typu *.wav.
Pierwszym parametrem jest wyra�enie ca�kowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - je�li w momencie wywo�ania jest odtwarzany inny d�wi�k to zostanie przerwany;
3 - odtwarzanie w p�tli bez ko�ca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis okre�laj�cy nazw� pliku typu *.wav. W og�lnym przypadku nazwa okre�la pe�n� �cie�k� dost�pu do pliku - dysk, folder i jego nazw�.
}

{Okienne wej�cie-wyj�cie}
Function IsEvent: Boolean;{Wynikiem funkcji jest warto�� logiczna prawda, je�li od ostatniego wywo�ania procedury Zdarzenie zasz�o jakie� zdarzenie (naci�ni�cie klawisza klawiatury lub lewego przycisku myszy w obr�bie okna wynik�w), w przeciwnym przypadku fa�sz.}

Procedure Event(Var k, x, y: Integer);{Za zdarzenie uwa�a si� naci�ni�cie klawisza na klawiaturze lub wci�ni�cie lewego przycisku myszki w obr�bie okna wynik�w. Je�li w momencie wywo�ania procedury zdarzenia jeszcze nie by�o, to program oczekuje zdarzenia.
Wywo�anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y warto�ci:
k=1, x=kod, y=0 - naci�ni�to klawisz steruj�cy nie maj�cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naci�ni�to klawisz steruj�cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naci�ni�to klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wsp�rz�dne kursora myszy - wci�ni�to lewy przycisk myszy;
k=3, x, y=wsp�rz�dne kursora myszy - mysz przemieszcza si� z wci�ni�tym lewym przyciskiem.
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

{I niestety plikowe, bo inaczej nie dzia�a}
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
{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw�, np. readln}
procedure AlgoSync;
{Funkcja pozwalaj�ca otrzyma� uchwyt do formularza - trzeba go zrzutowac}
function GetMyForm:pointer;

{IMPLEMENTACJA - NAJLEPIEJ NIE DOTYKA� :-) }
implementation
uses  Windows, Messages, SysUtils, Variants, Classes,
      Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,MPlayer;

{$IF DELPHI_VERSION <= 7 } //W starszych wersjach musi by� plik Algo.dfm
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
{Rysuje odcinek linii prostej ��cz�cy punkt o wsp�rz�dnych (x1, y1)
z punktem o wsp�rz�dnych (x2, y2).
Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x2, y2).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.MoveTo(x1,y1);
MyForm.CurrCanvas.LineTo(x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure LineTo(x, y: Integer);
{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu
 o wsp�rz�dnych (x, y).
 Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.LineTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure MoveTo(x, y: Integer);
{Przemieszcza kursor graficzny do punktu o wsp�rz�dnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.MoveTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure Coordinates(Var x, y: Integer);
{Zwraca informacj� o wsp�rz�dnych kursora graficznego.}
begin
MyForm.CurrCanvas.Lock;
x:=MyForm.CurrCanvas.PenPos.X;
y:=MyForm.CurrCanvas.PenPos.Y;
MyForm.CurrCanvas.Unlock;
end;

Procedure Pen(n, r, g, b: Integer);
{Ustala kolor i grubo�� rysowanych linii. Parametry r, g, b �
to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - grubo��.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pen.Color:=RGB(r,g,b);
MyForm.CurrCanvas.Pen.Width:=n;
MyForm.CurrCanvas.Unlock;
end;

Procedure Brush(k, r, g, b: Integer);
{Ustala kolor i styl wype�nienia. Parametry r, g, b �
to nasycenie kolorami czerwonym, zielonym i niebieskim.
Je�li k=1 to figury s� zamalowywane wybranym kolorem p�dzla,
je�li k=0 to kolor jest przezroczysty.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Brush.Color:=RGB(r,g,b);
if k>0 then
  MyForm.CurrCanvas.Brush.Style:=bsSolid
  else
  MyForm.CurrCanvas.Brush.Style:=bsClear;//Czy tak zrobi� przezroczysty brush?
MyForm.CurrCanvas.Unlock;
end;

Procedure Rectangle(x1, y1, x2, y2: Integer);
{Rysuje prostok�t, kt�rego przeciwleg�e wierzcho�ki maj� wsp�rz�dne
(x1, y1) i (x2, y2).
Przesuwa tak�e kursor graficzny do punktu o wsp�rz�dnych (x2, y2).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Rectangle(x1,y1,x2,y2);
MyForm.CurrCanvas.MoveTo(x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure Ellipse(x1, y1, x2, y2: Integer);
{Rysuje elips�. Parametry okre�laj� wsp�rz�dne dw�ch przeciwleg�ych wierzcho�k�w
prostok�ta opisanego na elipsie. Wsp�rz�dne kursora graficznego nie ulegaj� zmianie.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Ellipse(x1,y1,x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure Point(x, y: Integer);
{Zaznacza punkt o wsp�rz�dnych (x, y) w kolorze pisaka.
Przemieszcza tak�e kursor graficzny do punktu o wsp�rz�dnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pixels[x,y]:=MyForm.CurrCanvas.Pen.Color;
MyForm.CurrCanvas.MoveTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure Fill(x, y: Integer);
{Wype�nia zadanym kolorem p�dzla wn�trze obszaru obejmuj�cego punkt o wsp�rz�dnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
//MyForm.CurrCanvas.Pixels[x,y]:=MyForm.CurrCanvas.Brush.Color; ???
MyForm.CurrCanvas.FloodFill(x,y,MyForm.CurrCanvas.Pixels[x,y],fsSurface);
MyForm.CurrCanvas.Unlock;
end;

Procedure TextColor(r, g, b: Integer);
{Okre�la kolor dla wypisywanych tekst�w procedurami Pisz i PiszLn.
Parametry r, g, b � to nasycenie kolorami czerwonym, zielonym i niebieskim.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Font.Color:=RGB(r,g,b);//Chyba nie dzia�a poprawnie
MyForm.CurrCanvas.Unlock;
end;

Procedure Font(rozmiar, kierunek, grubosc: Integer);
{Wybiera rozmiar (6..72), kierunek (0..359) i grubo�� (1..1000)
wypisywanych tekst�w procedurami Pisz i PiszLn. Argumentami procedury Czcionka
mog� by� dowolne wyra�enia ca�kowite.}
begin
MyForm.CurrCanvas.Lock;                    //TFont
MyForm.CurrCanvas.Font.Size:=rozmiar;
{$IF DELPHI_VERSION > 7 } //Mo�e nie by� dfm'a
MyForm.CurrCanvas.Font.Orientation:=kierunek*10;//Jakie tu s� jednostki???
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Weight
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Font.Pitch???
{$IFEND}
MyForm.CurrCanvas.Unlock;
end;

Procedure Clear;
{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym g�rnym rogu okna wynik�w.
Opr�cz wyczyszczenia okna, procedura wykonuje nast�puj�ce czynno�ci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype�nienia;
- ustawia czcionk� (8,0,400).
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
{Procedura wylicza aktualn� dat�, czyli rok (1900..2099), miesi�c (1..12), dzie� i dzie� (1.. 31).}
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
{Procedura wylicza aktualny czas, czyli godzin� (0..23), minuty (0..59) i sekundy (0..59).}
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
Czyli usypianie w�tku "Main"}
begin
   Sleep(ms*3); {Traktowanie doslowne daje bardzo krotkie u�pienie - Why???}
end;

Procedure PlaySound(atr: Integer; plik: string);
{Odtwarza pliki d�wi�kowe typu *.wav.
Pierwszym parametrem jest wyra�enie ca�kowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - je�li w momencie wywo�ania jest odtwarzany inny d�wi�k to zostanie przerwany;
3 - odtwarzanie w p�tli bez ko�ca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis okre�laj�cy nazw� pliku typu *.wav.
W og�lnym przypadku nazwa okre�la pe�n� �cie�k� dost�pu do pliku -
dysk, folder i jego nazw�.
}
begin
beep();sleep(200);beep();//Not implemented yet...
//Windows  PlaySound(plik); czy mo�e :=TMediaPlayer.Create(); Stop;  ???
end;

function GetMyForm:pointer;
begin
  GetMyForm:=MyForm;
end;

{Okienne wej�cie-wyj�cie}
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

{OBS�UGA PLIK�W - Ach gdzie s� procedury ze swobodn� liczb� parametr�w!??}
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
{Wynikiem funkcji jest warto�� logiczna prawda, je�li od ostatniego wywo�ania
procedury Zdarzenie zasz�o jakie� zdarzenie (naci�ni�cie klawisza klawiatury
lub lewego przycisku myszy w obr�bie okna wynik�w), w przeciwnym przypadku fa�sz.}
begin
AlgoSync;
MyForm.CurrCanvas.Lock;
result:=not MyForm.QEmpty;
MyForm.CurrCanvas.UnLock;
end;

Procedure Event(Var k, x, y: Integer);
{Za zdarzenie uwa�a si� naci�ni�cie klawisza na klawiaturze lub wci�ni�cie
lewego przycisku myszki w obr�bie okna wynik�w. Je�li w momencie wywo�ania
procedury zdarzenia jeszcze nie by�o, to program oczekuje zdarzenia.
Wywo�anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y warto�ci:
k=1, x=kod, y=0 - naci�ni�to klawisz steruj�cy nie maj�cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naci�ni�to klawisz steruj�cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naci�ni�to klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wsp�rz�dne kursora myszy - wci�ni�to lewy przycisk myszy;
k=3, x, y=wsp�rz�dne kursora myszy - mysz przemieszcza si� z wci�ni�tym lewym przyciskiem.
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
k=1, x=kod, y=0 - naci�ni�to klawisz steruj�cy nie maj�cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naci�ni�to klawisz steruj�cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naci�ni�to klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wsp�rz�dne kursora myszy - wci�ni�to lewy przycisk myszy;
k=3, x, y=wsp�rz�dne kursora myszy - mysz przemieszcza si� z wci�ni�tym lewym przyciskiem.\
}
procedure TAlgoForm.GrabberKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
MyArea.Canvas.Lock;
QAdd(1,Key,0);//Ka�dy klawisz - tak�e bez reprezentacji ASCII
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
            QAdd(1,ord(Key),2);//Zwyk�y kod ascii
//beep();
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.GrabberKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
MyArea.Canvas.Lock;
 Grabber.Text:='';//Puszczony - czy�cimy
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.paintboxMouseClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MyArea.Canvas.Lock;
QAdd(2,X,Y);//wci�ni�to lewy przycisk myszy
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.paintboxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
MyArea.Canvas.Lock;
Grabber.SetFocus();
if ssLeft in Shift then
         QAdd(3,X,Y);//mysz przemieszcza si� z wci�ni�tym lewym przyciskiem
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.PaintBoxRepaint(Sender: TObject);
{Odrysowywanie paintboxa prze odslonieciu - tylko t�o}
begin
MyArea.Canvas.Lock;
MyArea.Canvas.FillRect(MyArea.Canvas.ClipRect);
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.StartStop(Sender: TObject);
{Wstrzymywanie wlasciwego watku roboczego}
begin
CurrCanvas.Lock; {Nie mo�na wstrzymywa� je�li wla�nie rysuje}
if StartStopButton.Caption='Start' then
  begin
  MyThread.Resume; { Uruchamia ten watek}
  StartStopButton.Caption:='Pause'
  end
  else
  begin
  MyThread.Suspend;{ Wstrzymuje w�tek}
  StartStopButton.Caption:='Start'
  end;
CurrCanvas.UnLock;
end;

procedure TAlgoForm.ImageArea(Sender: TObject);
{Przelaczanie z PaintArea na Image i odwrotnie}
begin
MyForm.Update;
Application.ProcessMessages;//W innym watku, czy to OK?
CurrCanvas.Lock;{Ma by� zmiana canvasu - trzeba go uchwyci�!}
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
{$IF DELPHI_VERSION > 7 } //Mo�e nie by� dfm'a
    MyImage:=TImage.Create(MyForm);
    MyArea:=TPaintBox.Create(MyForm);
    StartStopButton:=TButton.Create(MyForm);
    ImagePaintBoxButton:=TButton.Create(MyForm);;
    SavePictButton:=TButton.Create(MyForm);
    Grabber:=TEdit.Create(MyForm);
    {POWI�ZANIE UTWORZONYCH "KONTROLEK" Z FORM�}
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
               MyForm.Width:=350;//Musi zosta� miejsce na przyciski i editbox
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
  {Troch� do zrobienia po "Main"}
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

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw�, np. readln}
procedure AlgoSync;
begin
//MyThread.Synchronize(MyThread.UpdateVCLfromThread); //TO BARDZO SPOWALNIA
MyThread.UpdateVCLfromThread  //A TAK TE� DZIA�A I NIE WIDZIALEM KLOPOT�W
end;

procedure TAlgoForm.WhenClosed(Sender: TObject);
begin
CurrCanvas.Lock; {Nie mo�na wstrzymywa� je�li wla�nie rysuje}
if (not MyThread.Suspended)and(not MyThread.Completed)and(not MyThread.Terminated) then
        MyThread.Suspend;
CurrCanvas.UnLock;
end;

{INICJACJA OKNA GRAFICZNEGO I W�TKU OBSLUGI}
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{Uruchamia procedure zrobiona z programu g�ownego w osobnym w�tku, ktory mo�e uzywa� poni�szego interfaceu}
begin
  Application.Initialize;
{$IF DELPHI_VERSION <= 7 } //Mo�e nie by� dfm'a
  Application.CreateForm(TAlgoForm, MyForm);
{$ELSE}
  Application.CreateForm(TForm, MyForm);//Nie mo�e by� TAlgoForm bo wtedy szuka resourc�w
{$IFEND}
  PrepareALGOWindow(MyForm,AppName,Width,Height);
  {Przygotowuje w�tek wykonuj�cy "Main"}
  MyThread:=TMyThread.Create(true);
  MyThread.Main:=Main;
  MyThread.Priority:=tpNormal;//tpLowest;
  Application.Run; {Oddaje sterowanie g��wnego w�tku do p�tli aplikacji}
  //MyThread.Break;
   //WriteComponentResFile('TAlgoForm.dfm',MyForm);
end;

end.

