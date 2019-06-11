unit Algo;
(*
IMPLEMENTACJA CZʌCI NIESTANDARDOWEGO INTERFEJSU "ALGO" DLA DELPHI  wersja 0.31
================================================================================
Autor: Wojciech Borkowski,                                            29.02.2012
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
i umiescic w katalogu razem z plikami Algo.pas i Algo.dfm. Plik dfm nie jest potrzebnym gdy
kompilator Delphi jest w wersji wiekszej ni� 7 - ale trzeba wtedy zmieni�
definicje DELPHI_VERSION w pliku Algo.pas na warto�� wi�ksz� ni� 7.

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

POPRAWKI W WERSJACH:
0.31:
  * Dodanie funkcji fillpoly, typu xypoint i przykladowego wielokata ludzik.
  * Reorganizacja kolejno�ci procedur i tre�ci komentarzy
  * Komunikat o nieprawid�owej kolejno�ci wywo�a� w przypadku u�ycia InsertSecondaryForm
    a w�a�ciwie CreateForm bez wywo�ania InitialiseUnit.
0.30:
  * Uelastycznienie sterowania inicializacj�: zmienna Initialised, i procedura InitiolisedUnit;

0.290:
  * Problem czyszczenia ekranu przez Clear - nie zawsze by�o na bia�o
  * Wprowadzenie flagi AlgoSyncPedantic sposobu synchronizacji (wersja "pedantic" jest powolna)
  * Rozbudowa funkcji writeLn do 8 argument�w
  * Dodanie do funkcji format domy�lnych warto�ci parametr�w
0.289:
  * Problem inicjalizacji pocz�tkowego p�dzla w Clear niezgodnej z pisaniem tekstu
    bo ALGO ma zawsze wymazuj�ce t�o dla tekst�w
  * Pr�by lepszego rozwi�zania zakonczania aplikacji - czasem bywaj� wyj�tki przy
    klikni�ciu X. Ale na nic bo Delphi nie daje szansy na bezwzgl�dne wyczyszczenie
    w�tku w TThread. Liczy na to �e w�tek sam si� zawsze zako�czy!!!
0.285:
  *  Wi�cej parametr�w w Write i Writeln
  *  Jakie� inne poprawki techniczne??? To do sprawdzenia.
0.281:
  * Etykieta autorska przenosz�ca na stron� www.iss.uw.edu.pl/borkowski
0.28:
  * Zablokowanie wywo�ania formy, gdy w�tek g��wny dzia�a i nie jest zawieszony
0.272:
  * ...........walka z synchronizacj� :((((   Bez skutku, nadal TPicture rysuje si� kawa�kami
0.271:
 * Poprawienie kompatybilnosci z Delphi 7 (WindowHandle zamiast GetOwnerWindow)
 * i przywr�cenie zaginionego wywo�ania Randomize w inicjlizacji modu�u
0.27:
 * Poprawione zarz�dzanie wywo�ywaniem formularza konfiguracyjnego
 * G��wna forma jest chowana, a w�tek zawieszany je�li konfiguracja zostanie
   wywo�ana bez jawnego zawieszenia w�tku g��wnego
 * Funkcja daj�ca dost�p do surowego uchwytu okna
 * Dodanie ikonki z kwadracikami do domy�lnego DFMa
 * Dodanie 2 przyk�ad�w z oknem konfiguracyjnym
0.25-26:
 * Funkcja zmiany rozmiaru ekranu
 * Zabezpieczenie zawieszania w�tku w czasie wywo�ywania setupu
 * Dodanie automatycznej numeracji obrazk�w
0.24:
 * Dodano mozliwo�� restartu g��wnego w�tku
 * Dodano mo�liwo�� podpieci� dodakowej formy zrobionej w kreatorze, a z ni�
   ca�ej praktycznie ca�ej aplikacji Delphi, pod warunkiem r�cznej inicjalizacji
   form w programie g��wnym.
0.23:
 * Dodano wywo�ani AlgoSync; w procedurze Delay()
 * Dodano komunikat o zakonczeniu w�tku aplikacyjnego
 * Dodano procedure Randomize(seed) kt�rej nie ma w Delphi
 * Dodano funkcje format(v:number,f,f):string zast�puj�c� nieprzykrywalne konstrukcje
   formatuj�ce liczby w wywo�aniach writeln.
0.22:
 * Dodano wywo�anie procedury Randomize w inicjacji w�tku g��wnego dla poprawienia
   zgodno�ci z tym co robi ALGO
 * Usuni�cie b��du w wariantowej kompilacji dla wersji 6 i 7 (z plikiem dfm)
   i wyzszych (bez pliku)

ZNANE NIEKOMPATYBILNO��I I B��DY:
 * Ze wzgledu na brak parametr�w otwartych w Delphi procedury write[ln]
   akceptuj� jedynie do 7 parametr�w. Wywo�ania z wi�ksz� liczb� parametr�w
   trzeba podzieli�.

 * Brak jest wlasnej implementacji Read, Readln, wi�c procedury te mog� nie
   dzia�ac asynchronicznie w stosunku do okna graficznego.
   Pomaga wywo�anie przed ich u�yciem dodatkowej procedury AlgoSync;

 * Funkcje readln/read czytaj� tre�� tylko z konsoli tekstowej nie pozostawiaj�c
    echa na ekranie graficznym i nie przechodz�c tam do nast�pnej linii.

 * W wersji 6 i 7 nie dzia�a nachylenie tekstu, a  �adnej nie dzia�a wyt�uszczanie

 * Rysowanie w trybie pliku graficznego - czyli przygotowanie do zapisu "obrazka"
   jest bardzo powolne, a ponadto cz�sto potrafi pomija� fragmenty rysunku.
   Wynika to z nieodkrytego b��du wsp�dzia�ania obu w�tk�w programu i okaza�o
   si� niezwykle trudne do usuni�cia

 * Nie zaimplementowano PlaySound - zamiast tego jest prosty sygna� d�wi�kowy
*)

{   TO CO KONIECZNE DO URUCHOMIENIA MODULU I APLIKACJI GO U�YWAJACEJ           }
{==============================================================================}
{
Procedura uruchamiania aplikacji:
Uruchamia procedure zrobion� z programu g�ownego ALGO w osobnym w�tku,
ktory mo�e uzywa� szerokiego podzbioru funkcji i procedur interfejsu ALGO.}
type MainProcedure=procedure;
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{
Procedura umo�liwia uruchamienie us�ug unitu i obiektu Application
przed wywo�aniem RunAsALGO. Jest to potrzebne, gdy u�ywane s� dodatkowe
formularze Delphi pod��czane poprzez InsertSecondaryForm}
procedure InitialiseUnit;

{
Procedura pozwalajaca rozbudowa� aplikacje o normalne formularze ObjectPascala.
�eby zadzia�a�a trzeba j� wywo�ac PRZED wywo�aniem RunAsALGO().}
Procedure InsertSecondaryForm(Form:pointer;
                           ButtName:string;
                           RunFirst:boolean=true
                           );

var DefaultDumpName:string;{Rdzen nazwy zrzut�w ekranu. Potem jest numer zrzutu}
                {Domyslnie ustawiony na nazw� zplikacji, ale mo�e by� co chcesz}



{   FUNKCJE   I   PROCEDURY   ZGODNO�CI   Z   ALGO                             }
{==============================================================================}

{Grafika podstawowa}
Procedure Clear;{ Wyczyszczenie ekranu graficznego i usytuowanie kursora
                  graficznego w lewym g�rnym rogu okna grafiki.
Opr�cz wyczyszczenia okna, procedura wykonuje nast�puj�ce czynno�ci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype�nienia;
- ustawia czcionk� (8,0,400).
}
Procedure Font(rozmiar, kierunek, grubosc: Integer);{Wybiera rozmiar (6..72), kierunek (0..359) i grubo�� (1..1000) wypisywanych tekst�w procedurami Pisz i PiszLn. Argumentami procedury Czcionka mog� by� dowolne wyra�enia ca�kowite.}
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
//Procedure Fillpoly; - Nie wyst�puj�ce w ALGO, ale dodana, w sekcji rozszerze� }

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

{Obs�uga zdarze� czyli okiennego wej�cia-wyj�cia}
Function IsEvent: Boolean;{Wynikiem funkcji jest warto�� logiczna prawda, je�li od ostatniego wywo�ania procedury Zdarzenie zasz�o jakie� zdarzenie (naci�ni�cie klawisza klawiatury lub lewego przycisku myszy w obr�bie okna wynik�w), w przeciwnym przypadku fa�sz.}
Procedure Event(Var k, x, y: Integer);{Za zdarzenie uwa�a si� naci�ni�cie klawisza na klawiaturze lub wci�ni�cie lewego przycisku myszki w obr�bie okna wynik�w. Je�li w momencie wywo�ania procedury zdarzenia jeszcze nie by�o, to program oczekuje zdarzenia.
Wywo�anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y warto�ci:
k=1, x=kod, y=0 - naci�ni�to klawisz steruj�cy nie maj�cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naci�ni�to klawisz steruj�cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naci�ni�to klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wsp�rz�dne kursora myszy - wci�ni�to lewy przycisk myszy;
k=3, x, y=wsp�rz�dne kursora myszy - mysz przemieszcza si� z wci�ni�tym lewym przyciskiem.
}

{Obsluga Write[ln] pisz�cego r�wnocze�nie na okno graficzne i konsole tekstow�}
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
procedure Write(p1,p2,p3,p4,p5,p6,p7:variant);overload;
procedure Writeln(p1,p2,p3,p4,p5,p6,p7:variant);overload;
procedure Write(p1,p2,p3,p4,p5,p6,p7,p8:variant);overload;
procedure Writeln(p1,p2,p3,p4,p5,p6,p7,p8:variant);overload;

{I do tego niestety plikowe, bo inaczej nie dzia�a, chyba �e za pomoc�
      system.write(...) system.writeln(...)                                    }
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
procedure Write(var f:text;p1,p2,p3,p4,p5,p6,p7:variant);overload;
procedure Writeln(var f:text;p1,p2,p3,p4,p5,p6,p7:variant);overload;

{DO ROZSZERZENIA O TO CZEGO W ALGO NIE MA, LUB NIE MUSI BY� - DLA POPRAWIENIA ZGODNO�CI}
{======================================================================================}
{ FillPoly() nie wyst�puj�ce w ALGO, ale bardzo potrzebne rysowanie wype�nionego wielok�ta}
type xypoint=record
        x,y:integer;
        end;
Procedure Fillpoly(const lst{:array[0..10000] of xypoint};size:Integer;x:Integer=0;y:Integer=0;sca:real=1);
{U�YCIE:}
{lst to lista punkt�w wielok�ta, automatycznie domykana}
{x,y s� traktowane jako przemieszczenie wielok�ta do tego punktu}
{sca to skala - mo�na dora�nie zwi�kszy� lub zmniejszy�, ale nie za darmo}

const Ludzik:array[1..28] of xypoint=
(
(x:0;y:-12),(x:1;y:-12),(x:2;y:-11),(x:2;y:-10),(x:1;y:-8),(x:4;y:-6),(x:4;y:3),
(x:3;y:2),(x:3;y:-3),(x:3;y:0),(x:2;y:11),(x:3;y:11),(x:3;y:12),(x:0;y:12),(x:0;y:2),
(x:0;y:12),(x:-3;y:12),(x:-3;y:11),(x:-2;y:11),(x:-3;y:0),(x:-3;y:-3),(x:-3;y:2),
(x:-4;y:3),(x:-4;y:-6),(x:-1;y:-8),(x:-2;y:-10),(x:-2;y:-11),(x:-1;y:-12));
const LudzikWidth=8;
const LudzikHeight=24;

{Algopodobne Randomize}
procedure Randomize;overload;
procedure Randomize(seed:integer);overload;
function  GetLastRandSeed:longint;

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw�, np. readln}
procedure AlgoSync;
var AlgoSyncPedantic:boolean=true; {Wersja pedenatic jest bezpieczna, ale wolniejsza}

{Funkcja formatuj�ca reale i integery zamiast paskalowej sk�adni write/string x:c:p,
kt�rej nie da si� "przeci��y�"}
function Format(v:real;c:integer=-1;ap:integer=3):string;overload;
function Format(v:integer;c:integer=-1):string;overload;

{Mo�na zmieni� rozmiar okna i odczyta� aktualny   }
Procedure ChangeSize(NWidth,NHeight:integer);
Procedure GetSize(var Width,Height:integer);

{Mozna ustalic now� nazw� dla g��wnego formularza }
Procedure SetTitle(tit:string);

{Funkcje pozwalaj�ce otrzyma� uchwyt do g��wnego formularza i do surowego okna
- trzeba je zrzutowac i u�ywa� bardzo ostro�nie, bo omija si� normalny kod obs�ugi.
Np. nie wolno zmienia� rozmiar�w okien!}
function GetMyForm:pointer;
function GetMyHwnd:LongWord;


{IMPLEMENTACJA - NAJLEPIEJ NIE DOTYKA� :-) }
implementation
uses  Windows,ShellAPI, Messages, SysUtils, Variants, Classes,
      Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,AppEvnts;//,MPlayer; NIE MA KODU PRZYK�ADOWEGO

{$IF DELPHI_VERSION <= 7 } //W starszych wersjach musi by� plik Algo.dfm
{$R *.dfm}
{$IFEND}
var
  AlgoHWND:HWND=0;
  Initialised:boolean=false;
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

type
     TQueue = array of record  k,x,y:integer; end;

     TAlgoForm = class(TForm)
     StartStopButton: TButton; //Sterowanie w�tkiem symulacji
     ImagePaintBoxButton: TButton;//Zmiana sposobu rysowania
     SavePictButton: TButton;  //Zapis zawarto�ci okna rysowanego na TImage
     Additional: TButton;      //Odpalanie dodatkowej formy o ile jest

     MyArea:TPaintBox;	       //Canvas do szybkiego rysowania
     MyImage:TImage;	       //Canvas do przygotowania do zapisu (powolne rysowanie)
     Grabber: TEdit;	       //Do przechwytywania znak�w z klawiatury
     etykieta:TLabel;        //Do informacji o stronie domowej unitu
     AlgoAppEvents: TApplicationEvents;
     procedure AlgoAppEventsIdle(Sender: TObject; var Done: Boolean);

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
     procedure AdditionalClick(Sender: TObject);
     //procedure WhenCreate(Sender: TObject); //Not used now...
     procedure WhenClosed(Sender: TObject);
     procedure Resized(Sender: TObject);
     procedure WBAbout(Sender: TObject);
     private
    { Private declarations }
      //cx,cy:integer;         ???
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

procedure TAlgoForm.AlgoAppEventsIdle(Sender: TObject; var Done: Boolean);
begin
CheckSynchronize;
end;

var MyForm:TAlgoForm;
    MyThread:TMyThread;
    MyMain:MainProcedure;

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
if MyForm.CurrCanvas=nil then
  begin
    system.write('.');
    exit;//Niewypa� :-)
  end;
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
if MyForm.CurrCanvas=nil then exit;//Niewypa� :-)
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pen.Color:=RGB(abs(r) mod 256,abs(g) mod 256, abs(b) mod 256);
MyForm.CurrCanvas.Pen.Width:=n;
MyForm.CurrCanvas.Unlock;
end;

var  BrushStyleForText:TBrushStyle=bsSolid; {Do tekstu musi by� od pocz�tku solid
                                             bo tak jest domyslnie w ALGO, i si�
                                             nie zmienia!
                                             }
Procedure Brush(k, r, g, b: Integer);
{Ustala kolor i styl wype�nienia. Parametry r, g, b �
to nasycenie kolorami czerwonym, zielonym i niebieskim.
Je�li k=1 to figury s� zamalowywane wybranym kolorem p�dzla,
je�li k=0 to kolor jest przezroczysty.}
begin
if MyForm.CurrCanvas=nil then exit;//Niewypa� :-)
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Brush.Color:=RGB(r,g,b);
if k>0 then
  begin
  //BrushStyleForText:=bsSolid;
  MyForm.CurrCanvas.Brush.Style:=bsSolid
  end
  else
  begin
  //BrushStyleForText:=bsClear;
  MyForm.CurrCanvas.Brush.Style:=bsClear;//Czy tak zrobi� przezroczysty brush?
  end;
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
{$IF DELPHI_VERSION > 7 } //Mo�e nie by� tej w�asciwo�ci w starszych
MyForm.CurrCanvas.Font.Orientation:=kierunek*10;//Jakie tu s� jednostki???
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Weight
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Font.Pitch???
{$IFEND}
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

Procedure Fillpoly(const lst{:array[0..10000] of xypoint};size:Integer;x:Integer=0;y:Integer=0;sca:real=1);
var lstgl:array[0..10000] of xypoint absolute lst;
    lstloc:array of TPoint;
    I: Integer;
begin
MyForm.CurrCanvas.Lock;

setlength(lstloc,size);
if sca<>1 then
begin
for I := 0 to size - 1 do
  begin
  lstloc[I].X:=round(lstgl[I].x*sca+x);
  lstloc[I].Y:=round(lstgl[I].y*sca+y);
  end;
end
else
for I := 0 to size - 1 do
  begin
  lstloc[I].X:=lstgl[I].x+x;
  lstloc[I].Y:=lstgl[I].y+y;
  end;

MyForm.CurrCanvas.Polygon(lstloc);

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
if (not Initialised) or (MyForm.CurrCanvas=nil) then exit;//Niewypa� :-)
Brush(1,255,255,255);  {Do czyszczenia}
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.FillRect(MyForm.CurrCanvas.ClipRect);
MyForm.CurrCanvas.Unlock;
Pen(1,0,0,0);
TextColor(0,0,0);
Brush(0,0,0,0);
BrushStyleForText:=bsSolid;{Ale tekst zawsze ma zamazuj�ce t�o!!!}
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
   if Initialised then AlgoSync;   {Delay si� przydaje i przed iicjalizacj� aplikacji}
   Sleep(ms*2); {Traktowanie doslowne daje bardzo krotkie u�pienie - Why???}
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
windows.Beep(600,900);windows.Beep(300,900);windows.beep(600,900);//Not implemented yet...
//Windows  PlaySound(plik); czy mo�e :=TMediaPlayer.Create(); Stop;  ???
end;

function GetMyForm:pointer;
begin
  GetMyForm:=MyForm;
end;

function GetMyHwnd:LongWord;
begin
  GetMyHwnd:=AlgoHWND;
end;

{Okienne wej�cie-wyj�cie}
procedure OutVar(p:variant);
var outstr:string;
    CurrBrushStyle:TBrushStyle;
begin
if system.IsConsole then
    system.write(p); {�eby si� nie wywala� jak nie ma konsoli}
if (MyForm=nil) or (MyForm.CurrCanvas=nil) then
          exit; {�eby si� nie wywala�, jak forma nie do konca stworzona}
MyForm.CurrCanvas.Lock;
with MyForm.CurrCanvas do
begin
  outstr:=p;
  CurrBrushStyle:=Brush.Style;
  Brush.Style:=BrushStyleForText;{Domyslny styl pedzla dla tekstu}
  if outstr=(chr(10)+chr(13)) then
    begin
    MoveTo(0,PenPos.Y-(Font.Height*10)div 8);
    end
    else
    TextOut(PenPos.X,PenPos.Y,outstr);
    Moveto(PenPos.X+1,PenPos.Y);{Bo czasem nast�pny tekst w�azi na poprzedni}
    Brush.Style:=CurrBrushStyle;
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
OutVar(p1);
Writeln;
end;

procedure Write(p1,p2:variant);overload;
begin
OutVar(p1);OutVar(p2);
end;

procedure Writeln(p1,p2:variant);overload;
begin
OutVar(p1);OutVar(p2);
Writeln;
end;

procedure Write(p1,p2,p3:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);
end;

procedure Writeln(p1,p2,p3:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);
Writeln;
end;

procedure Write(p1,p2,p3,p4:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);
end;

procedure Writeln(p1,p2,p3,p4:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);
Writeln;
end;

procedure Write(p1,p2,p3,p4,p5:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);
end;

procedure Writeln(p1,p2,p3,p4,p5:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);
Writeln;
end;

procedure Write(p1,p2,p3,p4,p5,p6:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);
end;

procedure Writeln(p1,p2,p3,p4,p5,p6:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);
Writeln;
end;

procedure Write(p1,p2,p3,p4,p5,p6,p7:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);OutVar(p7);
end;

procedure Writeln(p1,p2,p3,p4,p5,p6,p7:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);OutVar(p7);
Writeln;
end;

procedure Write(p1,p2,p3,p4,p5,p6,p7,p8:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);OutVar(p7);OutVar(p8);
end;

procedure Writeln(p1,p2,p3,p4,p5,p6,p7,p8:variant);overload;
begin
OutVar(p1);OutVar(p2);OutVar(p3);OutVar(p4);OutVar(p5);OutVar(p6);OutVar(p7);;OutVar(p8);
Writeln;
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

procedure Write(var f:text;p1,p2,p3,p4,p5,p6,p7:variant);overload;
begin
  system.Write(f,p1,p2,p3,p4,p5,p6,p7);
end;

procedure Writeln(var f:text;p1,p2,p3,p4,p5,p6,p7:variant);overload;
begin
  system.Writeln(f,p1,p2,p3,p4,p5,p6,p7);
end;

function Format(v:real;c:integer;ap:integer):string;
var bufor:string;
begin
if c<0 then
    str(v,bufor)
    else
    str(v:c:ap,bufor);
Format:=bufor;
end;

function Format(v:integer;c:integer):string;
var bufor:string;
begin
if c<0 then
    str(v,bufor)
    else
    str(v:c,bufor);
Format:=bufor;
end;

//RandSeed: Integer      assert!!!  typeof(RandSeed)
var lastSeed:Integer=0;{Do zapami�tania ostatniego Randomize}
procedure Randomize;
{Algopodobne Randomize}
begin
Algo.lastSeed:=system.randseed;
system.randomize;
Algo.lastSeed:=system.randseed;
end;

procedure Randomize(seed:integer);
{Algopodobne Randomize}
begin
system.randseed:=seed;
Algo.lastSeed:=system.randseed;
end;

function  GetLastRandSeed:longint;
begin
 GetLastRandSeed:=Algo.lastSeed;
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
{Odrysowywanie paintboxa przy odslonieciu - tylko t�o}
begin
MyArea.Canvas.Lock;
MyArea.Canvas.FillRect(MyArea.Canvas.ClipRect);
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.ImageArea(Sender: TObject);
{Przelaczanie z PaintArea na Image i odwrotnie}
var cp:TBrush;
    pn:TPen;
begin
MyForm.Update;
Application.ProcessMessages;//W innym watku?

CurrCanvas.Lock;{Ma by� zmiana canvasu - trzeba go uchwyci�!}
if not MyImage.Visible then
begin
  MyImage.Visible:=true;
  MyArea.Visible:=false;
  SavePictButton.Enabled:=true;
  ImagePaintBoxButton.Caption:='Paint fastest';

  CurrCanvas:=MyImage.Canvas;
  cp:=CurrCanvas.Brush;
  pn:=CurrCanvas.Pen;
 { CurrCanvas.Brush.Style := bsDiagCross;}
  CurrCanvas.Brush.Style := bsSolid;
  CurrCanvas.Brush.Color :=clLtGray;
  CurrCanvas.Pen.Color :=clGray;
  CurrCanvas.FillRect(CurrCanvas.ClipRect);
  CurrCanvas.Brush:=cp;
  CurrCanvas.Pen:=pn; 
  MyForm.AutoScroll:=true; //Na wypadek gdyby si� user upar� zmienia� rozmiar
  MyArea.Canvas.Unlock;
end
else
begin
  MyImage.Visible:=false;
  MyArea.Visible:=true;
  SavePictButton.Enabled:=false;
  ImagePaintBoxButton.Caption:='Paint image';
  CurrCanvas:=MyArea.Canvas;
  MyForm.AutoScroll:=false; //I tak nie dzia�a - wymaga implementacji "repaint"
  MyImage.Canvas.Unlock;
end;
end;

var liczbmp:integer=1;
procedure TAlgoForm.SaveImage(Sender: TObject);
var numer:string;
begin
  MyForm.Update;
  Application.ProcessMessages;
  CurrCanvas.Lock;
  str(liczbmp:3,numer);
  MyImage.Picture.SaveToFile(DefaultDumpName+Numer+'.bmp');
  inc(liczbmp);
  CurrCanvas.UnLock;
end;

//Dane i rejestracja dodatkowej formy
//////////////////////////////////////////
var AddForm:TForm=nil;
    ButtonName:string='';
    RunBeforeMain:boolean=false;

Procedure InsertSecondaryForm(Form:pointer;
                           ButtName:string;
                           RunFirst:boolean=true
                           );
begin
  if not Initialised then
    begin
      if system.IsConsole then
        begin
        system.writeln('Uzywajac dodatkowych okienek musisz najpierw uzyc InitialiseUnit');
        windows.Beep(600,900); windows.Sleep(2000)
        end
        else
        Windows.MessageBox(0,'U�ywaj�c dodatkowych okienek musisz najpierw u�y� InitialiseUnit','Unit ALGO',MB_ICONSTOP);
      halt;
    end;
  RunBeforeMain:=RunFirst;
  ButtonName:=ButtName;
  AddForm:=Form;
end;

//Rozmiary ekrany
/////////////////////////////////////////////
var LastWidth,LastHeight:integer; //Zapami�tane z ostatniej zmiany

Procedure GetSize(var Width,Height:integer);
begin
 Width:=LastWidth;
 Height:=LastHeight;
end;

Procedure ChangeSize(NWidth,NHeight:integer);
begin
 LastWidth:=NWidth;  //Zapisanie �yczenia u�ytkownika
 LastHeight:=NHeight;

MyForm.Width:=NWidth+20;
    if MyForm.Width<370 then
               MyForm.Width:=370;//Musi zosta� miejsce na przyciski i editbox
    MyForm.Height:=NHeight+70;

with MyForm do
  begin
    MyImage.Width:=NWidth;
    MyImage.Height:=NHeight;

    MyArea.Width:=NWidth;
    MyArea.Height:=NHeight;

    MyImage.Top:=StartStopButton.Top+StartStopButton.Height;
    MyImage.Left:=(MyForm.ClientWidth-MyImage.Width)div 2;

    MyArea.Top:=MyImage.Top;
    MyArea.Left:=MyImage.Left;

    etykieta.Left:=MyForm.MyArea.Width-etykieta.Width;
    etykieta.Top:=MyForm.StartStopButton.Height+MyForm.MyArea.Height+1; //-etykieta.Height;
  end;
end;

// Przygotowywanie g��wnej Form-y do pracy
///////////////////////////////////////////////////////////////////
procedure PrepareALGOWindow(MyForm:TAlgoForm;setcaption:string;NWidth,NHeight:integer);
{W wersjach Delphi powy�ej 6 (?) mo�e si� oby� bez pliku dfm}
var saveleft:integer;
begin
 LastWidth:=NWidth;  //Zapisanie �yczenia u�ytkownika
 LastHeight:=NHeight;

  with MyForm do
   begin
    QInit;
{$IF DELPHI_VERSION > 7 } //Mo�e nie by� dfm'a
    //Czy jeste� pewny �e nie potrzebujesz pliku DFM?
    MyImage:=TImage.Create(MyForm);
    MyArea:=TPaintBox.Create(MyForm);
    StartStopButton:=TButton.Create(MyForm);
    ImagePaintBoxButton:=TButton.Create(MyForm);
    SavePictButton:=TButton.Create(MyForm);
    Additional:=TButton.Create(MyForm);
    Grabber:=TEdit.Create(MyForm);
    AlgoAppEvents:=TApplicationEvents.Create(MyForm);
    {POWI�ZANIE UTWORZONYCH "KONTROLEK" Z FORM�}
    MyImage.Parent:=MyForm;
    MyArea.Parent:=MyForm;
    StartStopButton.Parent:=MyForm;
    ImagePaintBoxButton.Parent:=MyForm;
    SavePictButton.Parent:=MyForm;
    Additional.Parent:=MyForm;
    Grabber.Parent:=MyForm;
{$IFEND}
    saveleft:=MyForm.Left;
    Caption:='"'+setcaption+'" (using unit ALGO graphics)';
    ApplicationName:=setcaption;
    MyForm.Width:=NWidth+20;
    if MyForm.Width<350 then
               MyForm.Width:=350;//Musi zosta� miejsce na przyciski i editbox
    MyForm.Height:=NHeight+70;
    //MyForm.Left:=saveleft;   i tak nie dzia�a, Winda robi swoje

 //   OnCreate:=WhenCreate;
    OnDestroy:=WhenClosed;
    OnDblClick:=WBAbout;

    StartStopButton.Top:=1;
    StartStopButton.Left:=1;
    StartStopButton.Width:=100;
    StartStopButton.Height:=20;
    StartStopButton.Caption:='Start';
    StartStopButton.Hint := 'Start/suspend/resume the aplication thread';
    StartStopButton.ShowHint:=true;
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

    Additional.Top:=1;
    Additional.Left:=303;
    Additional.Width:=100;
    Additional.Height:=20;
    Additional.OnClick:=AdditionalClick;

    if (ButtonName<>'') then
      begin
      Grabber.Left:=404;
      Grabber.Width:=MyForm.ClientWidth-404;
      Additional.Caption:=ButtonName;
      Additional.Enabled:=true;
      end
      else
      begin
      Additional.Caption:='.............';
      Additional.Enabled:=false;
      Grabber.Left:=303;
      Grabber.Width:=MyForm.ClientWidth-303;
      end;

    Grabber.Top:=1;
    Grabber.Height:=20;
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

    //�eby tekst zachowywa� si� jak w ALGO
    MyImage.Canvas.TextFlags:=ETO_OPAQUE;
    MyArea.Canvas.TextFlags:=ETO_OPAQUE;

    CurrCanvas:=MyArea.Canvas;
    MyForm.AlgoAppEvents.OnIdle:=AlgoAppEventsIdle;

    //Informacja o autorze
    etykieta:=TLabel.Create(MyForm);
    etykieta.Parent:=MyForm;
    etykieta.Color:=clLtGray;
    etykieta.Font.Color:=clBlue;
    etykieta.Caption:=' -> Unit ALGO home page ';
    etykieta.OnClick:=WBAbout;
    etykieta.Left:=MyForm.MyArea.Width-etykieta.Width;
    etykieta.Top:=MyForm.StartStopButton.Height+MyForm.MyArea.Height+1;//-etykieta.Height;               //MyArea.
    //OnResize:=Resized; //Poprawia po�o�enie etykiety przy zmianie rozmiar�w okna
   end;
end;

procedure TAlgoForm.StartStop(Sender: TObject);
{Wstrzymywanie wlasciwego watku roboczego}
begin
MyForm.Update;
Application.ProcessMessages;
CurrCanvas.Lock; {Nie mo�na wstrzymywa� je�li wla�nie rysuje}
if StartStopButton.Caption='Start' then
  begin
  Additional.Enabled:=false;{Blokuje setup na czas wykonaia watku}
  {Przygotowuje w�tek wykonuj�cy "Main"}
  QInit;
  Clear;
  StartStopButton.Caption:='Pause';
  MyThread:=TMyThread.Create(true);
  MyThread.Completed:=false;
  MyThread.Main:=MyMain;
  MyThread.Priority:=tpNormal;//tpLowest;
  MyThread.Resume; { Wznawia ten watek}
  end
  else
if StartStopButton.Caption='Resume' then
  begin
  Additional.Enabled:=false;{Blokuje setup na czas wykonaia watku}
  MyThread.Resume; { Wznawia ten watek}
  StartStopButton.Caption:='Pause'
  end
  else  {Caption = Pause}
  begin
  MyThread.Suspend;{ Wstrzymuje w�tek}
  Additional.Enabled:=true;{Odblokowuje setup na czas zawieszenia watku}
  StartStopButton.Caption:='Resume'
  end;
CurrCanvas.UnLock;
end;

procedure TAlgoForm.AdditionalClick(Sender: TObject);
var flaga:boolean;
begin
  MyForm.Update;
  Application.ProcessMessages;

  //Je�li w�tek g��wny dzia�a to wr�y k�opoty...
  flaga:=(MyThread=nil) OR MyThread.Suspended OR MyThread.Completed;
  if not flaga then  {Ale to i tak rzadko zabezpiecza}
    begin
       MyForm.Hide;{ Tak jest najbezpieczniej ...}
       MyThread.Suspend;{ Wstrzymuje w�tek}
       StartStopButton.Caption:='PAUSED'; {Jakby kto� "z modalu" ujawni� jednak to okno}
       AddForm.Left:=MyForm.Left;{W miejsce orginalnego okna }
       AddForm.Top:=MyForm.Top;
    end;

  AddForm.ShowModal();

 if not flaga then
    begin
       MyThread.Resume;{ Je�li wstrzyma� w�tek to rusza}
       StartStopButton.Caption:='Pause';
       MyForm.Show;
    end;
end;

Procedure TMyThread.Execute;
begin
  Completed:=false;
  { Wykonanie procedury zapamietanej jako "Main" }
  Main;
  {Troch� do zrobienia po "Main"}
  MyForm.CurrCanvas.Lock; {W sumie to chyba wsio ryba gdzie ten semafor???}
  MyForm.StartStopButton.Enabled:=false; {Zeby teraz kto� nie zastartowa�!}
  MyForm.CurrCanvas.UnLock;{Ale po co tu odblokowanie semafora?}
  Completed:=true;
  if system.IsConsole then
     system.Writeln(MyForm.ApplicationName,' : ','Watek aplikacji pomyslnie zakonczony')
     else
     Application.MessageBox('W�tek aplikacji pomy�lnie zako�czony',PChar(MyForm.ApplicationName));
  MyForm.Additional.Enabled:=true;{Odblokowuje setup bo juz nie ma watku}
  MyForm.StartStopButton.Caption:='Start'; {Przywraca nazwe przycisku startowego}
  MyForm.StartStopButton.Enabled:=true;{Teraz ju� mo�na ponownie startowac}
end;

procedure TAlgoForm.WBAbout(Sender: TObject);
{Home page of "unit ALGO" author - Wojciech Borkowski}
begin
ShellExecute(0,'open','http://www.iss.uw.edu.pl/borkowski','','.',SW_SHOWNORMAL );
end;

procedure TAlgoForm.Resized(Sender: TObject);
begin
 etykieta.Top:=MyForm.Height-etykieta.Height;
 etykieta.Left:=MyForm.Width-etykieta.Width;
end;

(*
procedure TAlgoForm.WhenCreate(Sender: TObject);
begin
//CurrCanvas.Lock;
CurrCanvas.Brush.Color:=RGB(255,255,255);
CurrCanvas.Brush.Style:=bsSolid;
//CurrCanvas.Unlock;
end;
*)

procedure TAlgoForm.WhenClosed(Sender: TObject);
begin
CurrCanvas.Lock; {Nie mo�na wstrzymywa� je�li wla�nie rysuje}
if (MyThread<>nil)and(not MyThread.Suspended)and(not MyThread.Completed)
    //and(not MyThread.Terminated) //Terminated to tylko sugestia!!!
    then
    begin
    MyThread.Suspend;
    end;
CurrCanvas.UnLock;
end;

Procedure SetTitle(tit:string);
begin
 MyForm.Caption:=tit;
end;

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw�, np. readln}
Procedure TMyThread.UpdateVCLfromThread;
begin
Application.ProcessMessages;
MyForm.Update;
Application.ProcessMessages;
end;

procedure AlgoSync;
begin
if MyForm.CurrCanvas=nil then exit;//Niewypa� :-)
MyThread.Synchronize(MyThread.UpdateVCLfromThread); //TO BARDZO SPOWALNIA
//MyThread.UpdateVCLfromThread  //A TAK TE� DZIA�A I NIE WIDZIALEM KLOPOT�W ?
end;

{INICJACJA OKNA GRAFICZNEGO I W�TKU OBSLUGI}
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{Uruchamia procedure zrobiona z programu g�ownego w osobnym w�tku, ktory mo�e uzywa� poni�szego interfaceu}
begin
  InitialiseUnit;  {Przygotowuje co trzeba jesli wczesniej nie zostalo wykonane}
  DefaultDumpName:=AppName;{Mo�e by� dlugie...}
  PrepareALGOWindow(MyForm,AppName,Width,Height);
  MyMain:=Main;
  if RunBeforeMain then
       AddForm.ShowModal();
  Application.Run; {Oddaje sterowanie g��wnego w�tku do p�tli aplikacji}
  //Windows.TerminateThread(MyThread.Handle,0); //Bezwzgl�dnie zabija w�tek
  //MyThread.Destroy;        //Usuwa struktury DElphi ale w�tek Win zostaje!!!!!
  //WriteComponentResFile('TAlgoForm.dfm',MyForm); //Zrzut DFMa, gdyby by�o trzeba
end;

procedure InitialiseUnit;
begin
  if Initialised then exit;
{INICJACJA APLIKACJI Delphi I REJESTRACJA G��WNEJ FORMY}
  Application.Initialize;
{$IF DELPHI_VERSION <= 7 } //Mo�e nie by� dfm'a w wersji od 7 wzwy�
  Application.CreateForm(TAlgoForm, MyForm);//Z DFMem
{$ELSE}
  Application.CreateForm(TForm, MyForm);//...i bez. Nie mo�e by� TAlgoForm bo wtedy szuka resourc�w
  AlgoHWND:=MyForm.GetOwnerWindow;
{$IFEND}
  AlgoHWND:=MyForm.WindowHandle;
  Initialised:=true;
end;

begin
  Randomize;
  //InitialiseUnit;  ???
end.





