unit Algo;
(*
IMPLEMENTACJA CZÊŒCI NIESTANDARDOWEGO INTERFEJSU "ALGO" DLA DELPHI  wersja 0.31
================================================================================
Autor: Wojciech Borkowski,                                            29.02.2012
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
i umiescic w katalogu razem z plikami Algo.pas i Algo.dfm. Plik dfm nie jest potrzebnym gdy
kompilator Delphi jest w wersji wiekszej ni¿ 7 - ale trzeba wtedy zmieniæ
definicje DELPHI_VERSION w pliku Algo.pas na wartoœæ wiêksz¹ ni¿ 7.

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

POPRAWKI W WERSJACH:
0.31:
  * Dodanie funkcji fillpoly, typu xypoint i przykladowego wielokata ludzik.
  * Reorganizacja kolejnoœci procedur i treœci komentarzy
  * Komunikat o nieprawid³owej kolejnoœci wywo³añ w przypadku u¿ycia InsertSecondaryForm
    a w³aœciwie CreateForm bez wywo³ania InitialiseUnit.
0.30:
  * Uelastycznienie sterowania inicializacj¹: zmienna Initialised, i procedura InitiolisedUnit;

0.290:
  * Problem czyszczenia ekranu przez Clear - nie zawsze by³o na bia³o
  * Wprowadzenie flagi AlgoSyncPedantic sposobu synchronizacji (wersja "pedantic" jest powolna)
  * Rozbudowa funkcji writeLn do 8 argumentów
  * Dodanie do funkcji format domyœlnych wartoœci parametrów
0.289:
  * Problem inicjalizacji pocz¹tkowego pêdzla w Clear niezgodnej z pisaniem tekstu
    bo ALGO ma zawsze wymazuj¹ce t³o dla tekstów
  * Próby lepszego rozwi¹zania zakonczania aplikacji - czasem bywaj¹ wyj¹tki przy
    klikniêciu X. Ale na nic bo Delphi nie daje szansy na bezwzglêdne wyczyszczenie
    w¹tku w TThread. Liczy na to ¿e w¹tek sam siê zawsze zakoñczy!!!
0.285:
  *  Wiêcej parametrów w Write i Writeln
  *  Jakieœ inne poprawki techniczne??? To do sprawdzenia.
0.281:
  * Etykieta autorska przenosz¹ca na stronê www.iss.uw.edu.pl/borkowski
0.28:
  * Zablokowanie wywo³ania formy, gdy w¹tek g³ówny dzia³a i nie jest zawieszony
0.272:
  * ...........walka z synchronizacj¹ :((((   Bez skutku, nadal TPicture rysuje siê kawa³kami
0.271:
 * Poprawienie kompatybilnosci z Delphi 7 (WindowHandle zamiast GetOwnerWindow)
 * i przywrócenie zaginionego wywo³ania Randomize w inicjlizacji modu³u
0.27:
 * Poprawione zarz¹dzanie wywo³ywaniem formularza konfiguracyjnego
 * G³ówna forma jest chowana, a w¹tek zawieszany jeœli konfiguracja zostanie
   wywo³ana bez jawnego zawieszenia w¹tku g³ównego
 * Funkcja daj¹ca dostêp do surowego uchwytu okna
 * Dodanie ikonki z kwadracikami do domyœlnego DFMa
 * Dodanie 2 przyk³adów z oknem konfiguracyjnym
0.25-26:
 * Funkcja zmiany rozmiaru ekranu
 * Zabezpieczenie zawieszania w¹tku w czasie wywo³ywania setupu
 * Dodanie automatycznej numeracji obrazków
0.24:
 * Dodano mozliwoœæ restartu g³ównego w¹tku
 * Dodano mo¿liwoœæ podpieci¹ dodakowej formy zrobionej w kreatorze, a z ni¹
   ca³ej praktycznie ca³ej aplikacji Delphi, pod warunkiem rêcznej inicjalizacji
   form w programie g³ównym.
0.23:
 * Dodano wywo³ani AlgoSync; w procedurze Delay()
 * Dodano komunikat o zakonczeniu w¹tku aplikacyjnego
 * Dodano procedure Randomize(seed) której nie ma w Delphi
 * Dodano funkcje format(v:number,f,f):string zastêpuj¹c¹ nieprzykrywalne konstrukcje
   formatuj¹ce liczby w wywo³aniach writeln.
0.22:
 * Dodano wywo³anie procedury Randomize w inicjacji w¹tku g³ównego dla poprawienia
   zgodnoœci z tym co robi ALGO
 * Usuniêcie b³êdu w wariantowej kompilacji dla wersji 6 i 7 (z plikiem dfm)
   i wyzszych (bez pliku)

ZNANE NIEKOMPATYBILNOŒÆI I B£ÊDY:
 * Ze wzgledu na brak parametrów otwartych w Delphi procedury write[ln]
   akceptuj¹ jedynie do 7 parametrów. Wywo³ania z wiêksz¹ liczb¹ parametrów
   trzeba podzieliæ.

 * Brak jest wlasnej implementacji Read, Readln, wiêc procedury te mog¹ nie
   dzia³ac asynchronicznie w stosunku do okna graficznego.
   Pomaga wywo³anie przed ich u¿yciem dodatkowej procedury AlgoSync;

 * Funkcje readln/read czytaj¹ treœæ tylko z konsoli tekstowej nie pozostawiaj¹c
    echa na ekranie graficznym i nie przechodz¹c tam do nastêpnej linii.

 * W wersji 6 i 7 nie dzia³a nachylenie tekstu, a  ¿adnej nie dzia³a wyt³uszczanie

 * Rysowanie w trybie pliku graficznego - czyli przygotowanie do zapisu "obrazka"
   jest bardzo powolne, a ponadto czêsto potrafi pomijaæ fragmenty rysunku.
   Wynika to z nieodkrytego b³êdu wspó³dzia³ania obu w¹tków programu i okaza³o
   siê niezwykle trudne do usuniêcia

 * Nie zaimplementowano PlaySound - zamiast tego jest prosty sygna³ dŸwiêkowy
*)

{   TO CO KONIECZNE DO URUCHOMIENIA MODULU I APLIKACJI GO U¯YWAJACEJ           }
{==============================================================================}
{
Procedura uruchamiania aplikacji:
Uruchamia procedure zrobion¹ z programu g³ownego ALGO w osobnym w¹tku,
ktory mo¿e uzywaæ szerokiego podzbioru funkcji i procedur interfejsu ALGO.}
type MainProcedure=procedure;
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{
Procedura umo¿liwia uruchamienie us³ug unitu i obiektu Application
przed wywo³aniem RunAsALGO. Jest to potrzebne, gdy u¿ywane s¹ dodatkowe
formularze Delphi pod³¹czane poprzez InsertSecondaryForm}
procedure InitialiseUnit;

{
Procedura pozwalajaca rozbudowaæ aplikacje o normalne formularze ObjectPascala.
¯eby zadzia³a³a trzeba j¹ wywo³ac PRZED wywo³aniem RunAsALGO().}
Procedure InsertSecondaryForm(Form:pointer;
                           ButtName:string;
                           RunFirst:boolean=true
                           );

var DefaultDumpName:string;{Rdzen nazwy zrzutów ekranu. Potem jest numer zrzutu}
                {Domyslnie ustawiony na nazwê zplikacji, ale mo¿e byæ co chcesz}



{   FUNKCJE   I   PROCEDURY   ZGODNOŒCI   Z   ALGO                             }
{==============================================================================}

{Grafika podstawowa}
Procedure Clear;{ Wyczyszczenie ekranu graficznego i usytuowanie kursora
                  graficznego w lewym górnym rogu okna grafiki.
Oprócz wyczyszczenia okna, procedura wykonuje nastêpuj¹ce czynnoœci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype³nienia;
- ustawia czcionkê (8,0,400).
}
Procedure Font(rozmiar, kierunek, grubosc: Integer);{Wybiera rozmiar (6..72), kierunek (0..359) i gruboœæ (1..1000) wypisywanych tekstów procedurami Pisz i PiszLn. Argumentami procedury Czcionka mog¹ byæ dowolne wyra¿enia ca³kowite.}
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
//Procedure Fillpoly; - Nie wystêpuj¹ce w ALGO, ale dodana, w sekcji rozszerzeñ }

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

{Obs³uga zdarzeñ czyli okiennego wejœcia-wyjœcia}
Function IsEvent: Boolean;{Wynikiem funkcji jest wartoœæ logiczna prawda, jeœli od ostatniego wywo³ania procedury Zdarzenie zasz³o jakieœ zdarzenie (naciœniêcie klawisza klawiatury lub lewego przycisku myszy w obrêbie okna wyników), w przeciwnym przypadku fa³sz.}
Procedure Event(Var k, x, y: Integer);{Za zdarzenie uwa¿a siê naciœniêcie klawisza na klawiaturze lub wciœniêcie lewego przycisku myszki w obrêbie okna wyników. Jeœli w momencie wywo³ania procedury zdarzenia jeszcze nie by³o, to program oczekuje zdarzenia.
Wywo³anie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y wartoœci:
k=1, x=kod, y=0 - naciœniêto klawisz steruj¹cy nie maj¹cy reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciœniêto klawisz steruj¹cy ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciœniêto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=wspó³rzêdne kursora myszy - wciœniêto lewy przycisk myszy;
k=3, x, y=wspó³rzêdne kursora myszy - mysz przemieszcza siê z wciœniêtym lewym przyciskiem.
}

{Obsluga Write[ln] pisz¹cego równoczeœnie na okno graficzne i konsole tekstow¹}
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

{I do tego niestety plikowe, bo inaczej nie dzia³a, chyba ¿e za pomoc¹
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

{DO ROZSZERZENIA O TO CZEGO W ALGO NIE MA, LUB NIE MUSI BYÆ - DLA POPRAWIENIA ZGODNOŒCI}
{======================================================================================}
{ FillPoly() nie wystêpuj¹ce w ALGO, ale bardzo potrzebne rysowanie wype³nionego wielok¹ta}
type xypoint=record
        x,y:integer;
        end;
Procedure Fillpoly(const lst{:array[0..10000] of xypoint};size:Integer;x:Integer=0;y:Integer=0;sca:real=1);
{U¯YCIE:}
{lst to lista punktów wielok¹ta, automatycznie domykana}
{x,y s¹ traktowane jako przemieszczenie wielok¹ta do tego punktu}
{sca to skala - mo¿na doraŸnie zwiêkszyæ lub zmniejszyæ, ale nie za darmo}

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

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw¹, np. readln}
procedure AlgoSync;
var AlgoSyncPedantic:boolean=true; {Wersja pedenatic jest bezpieczna, ale wolniejsza}

{Funkcja formatuj¹ca reale i integery zamiast paskalowej sk³adni write/string x:c:p,
której nie da siê "przeci¹¿yæ"}
function Format(v:real;c:integer=-1;ap:integer=3):string;overload;
function Format(v:integer;c:integer=-1):string;overload;

{Mo¿na zmieniæ rozmiar okna i odczytaæ aktualny   }
Procedure ChangeSize(NWidth,NHeight:integer);
Procedure GetSize(var Width,Height:integer);

{Mozna ustalic now¹ nazwê dla g³ównego formularza }
Procedure SetTitle(tit:string);

{Funkcje pozwalaj¹ce otrzymaæ uchwyt do g³ównego formularza i do surowego okna
- trzeba je zrzutowac i u¿ywaæ bardzo ostro¿nie, bo omija siê normalny kod obs³ugi.
Np. nie wolno zmieniaæ rozmiarów okien!}
function GetMyForm:pointer;
function GetMyHwnd:LongWord;


{IMPLEMENTACJA - NAJLEPIEJ NIE DOTYKAÆ :-) }
implementation
uses  Windows,ShellAPI, Messages, SysUtils, Variants, Classes,
      Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,AppEvnts;//,MPlayer; NIE MA KODU PRZYK£ADOWEGO

{$IF DELPHI_VERSION <= 7 } //W starszych wersjach musi byæ plik Algo.dfm
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
     StartStopButton: TButton; //Sterowanie w¹tkiem symulacji
     ImagePaintBoxButton: TButton;//Zmiana sposobu rysowania
     SavePictButton: TButton;  //Zapis zawartoœci okna rysowanego na TImage
     Additional: TButton;      //Odpalanie dodatkowej formy o ile jest

     MyArea:TPaintBox;	       //Canvas do szybkiego rysowania
     MyImage:TImage;	       //Canvas do przygotowania do zapisu (powolne rysowanie)
     Grabber: TEdit;	       //Do przechwytywania znaków z klawiatury
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
if MyForm.CurrCanvas=nil then
  begin
    system.write('.');
    exit;//Niewypa³ :-)
  end;
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
if MyForm.CurrCanvas=nil then exit;//Niewypa³ :-)
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pen.Color:=RGB(abs(r) mod 256,abs(g) mod 256, abs(b) mod 256);
MyForm.CurrCanvas.Pen.Width:=n;
MyForm.CurrCanvas.Unlock;
end;

var  BrushStyleForText:TBrushStyle=bsSolid; {Do tekstu musi byæ od pocz¹tku solid
                                             bo tak jest domyslnie w ALGO, i siê
                                             nie zmienia!
                                             }
Procedure Brush(k, r, g, b: Integer);
{Ustala kolor i styl wype³nienia. Parametry r, g, b –
to nasycenie kolorami czerwonym, zielonym i niebieskim.
Jeœli k=1 to figury s¹ zamalowywane wybranym kolorem pêdzla,
jeœli k=0 to kolor jest przezroczysty.}
begin
if MyForm.CurrCanvas=nil then exit;//Niewypa³ :-)
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
  MyForm.CurrCanvas.Brush.Style:=bsClear;//Czy tak zrobiæ przezroczysty brush?
  end;
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
{$IF DELPHI_VERSION > 7 } //Mo¿e nie byæ tej w³asciwoœci w starszych
MyForm.CurrCanvas.Font.Orientation:=kierunek*10;//Jakie tu s¹ jednostki???
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Weight
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Font.Pitch???
{$IFEND}
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
{ Wyczyszczenie ekranu graficznego i usytuowanie kursora graficznego w lewym górnym rogu okna wyników.
Oprócz wyczyszczenia okna, procedura wykonuje nastêpuj¹ce czynnoœci:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wype³nienia;
- ustawia czcionkê (8,0,400).
}
begin
if (not Initialised) or (MyForm.CurrCanvas=nil) then exit;//Niewypa³ :-)
Brush(1,255,255,255);  {Do czyszczenia}
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.FillRect(MyForm.CurrCanvas.ClipRect);
MyForm.CurrCanvas.Unlock;
Pen(1,0,0,0);
TextColor(0,0,0);
Brush(0,0,0,0);
BrushStyleForText:=bsSolid;{Ale tekst zawsze ma zamazuj¹ce t³o!!!}
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
   if Initialised then AlgoSync;   {Delay siê przydaje i przed iicjalizacj¹ aplikacji}
   Sleep(ms*2); {Traktowanie doslowne daje bardzo krotkie uœpienie - Why???}
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
windows.Beep(600,900);windows.Beep(300,900);windows.beep(600,900);//Not implemented yet...
//Windows  PlaySound(plik); czy mo¿e :=TMediaPlayer.Create(); Stop;  ???
end;

function GetMyForm:pointer;
begin
  GetMyForm:=MyForm;
end;

function GetMyHwnd:LongWord;
begin
  GetMyHwnd:=AlgoHWND;
end;

{Okienne wejœcie-wyjœcie}
procedure OutVar(p:variant);
var outstr:string;
    CurrBrushStyle:TBrushStyle;
begin
if system.IsConsole then
    system.write(p); {¯eby siê nie wywala³ jak nie ma konsoli}
if (MyForm=nil) or (MyForm.CurrCanvas=nil) then
          exit; {¯eby siê nie wywala³, jak forma nie do konca stworzona}
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
    Moveto(PenPos.X+1,PenPos.Y);{Bo czasem nastêpny tekst w³azi na poprzedni}
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
var lastSeed:Integer=0;{Do zapamiêtania ostatniego Randomize}
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
{Odrysowywanie paintboxa przy odslonieciu - tylko t³o}
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

CurrCanvas.Lock;{Ma byæ zmiana canvasu - trzeba go uchwyciæ!}
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
  MyForm.AutoScroll:=true; //Na wypadek gdyby siê user upar³ zmieniaæ rozmiar
  MyArea.Canvas.Unlock;
end
else
begin
  MyImage.Visible:=false;
  MyArea.Visible:=true;
  SavePictButton.Enabled:=false;
  ImagePaintBoxButton.Caption:='Paint image';
  CurrCanvas:=MyArea.Canvas;
  MyForm.AutoScroll:=false; //I tak nie dzia³a - wymaga implementacji "repaint"
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
        Windows.MessageBox(0,'U¿ywaj¹c dodatkowych okienek musisz najpierw u¿yæ InitialiseUnit','Unit ALGO',MB_ICONSTOP);
      halt;
    end;
  RunBeforeMain:=RunFirst;
  ButtonName:=ButtName;
  AddForm:=Form;
end;

//Rozmiary ekrany
/////////////////////////////////////////////
var LastWidth,LastHeight:integer; //Zapamiêtane z ostatniej zmiany

Procedure GetSize(var Width,Height:integer);
begin
 Width:=LastWidth;
 Height:=LastHeight;
end;

Procedure ChangeSize(NWidth,NHeight:integer);
begin
 LastWidth:=NWidth;  //Zapisanie ¿yczenia u¿ytkownika
 LastHeight:=NHeight;

MyForm.Width:=NWidth+20;
    if MyForm.Width<370 then
               MyForm.Width:=370;//Musi zostaæ miejsce na przyciski i editbox
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

// Przygotowywanie g³ównej Form-y do pracy
///////////////////////////////////////////////////////////////////
procedure PrepareALGOWindow(MyForm:TAlgoForm;setcaption:string;NWidth,NHeight:integer);
{W wersjach Delphi powy¿ej 6 (?) mo¿e siê obyæ bez pliku dfm}
var saveleft:integer;
begin
 LastWidth:=NWidth;  //Zapisanie ¿yczenia u¿ytkownika
 LastHeight:=NHeight;

  with MyForm do
   begin
    QInit;
{$IF DELPHI_VERSION > 7 } //Mo¿e nie byæ dfm'a
    //Czy jesteœ pewny ¿e nie potrzebujesz pliku DFM?
    MyImage:=TImage.Create(MyForm);
    MyArea:=TPaintBox.Create(MyForm);
    StartStopButton:=TButton.Create(MyForm);
    ImagePaintBoxButton:=TButton.Create(MyForm);
    SavePictButton:=TButton.Create(MyForm);
    Additional:=TButton.Create(MyForm);
    Grabber:=TEdit.Create(MyForm);
    AlgoAppEvents:=TApplicationEvents.Create(MyForm);
    {POWI¥ZANIE UTWORZONYCH "KONTROLEK" Z FORM¥}
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
               MyForm.Width:=350;//Musi zostaæ miejsce na przyciski i editbox
    MyForm.Height:=NHeight+70;
    //MyForm.Left:=saveleft;   i tak nie dzia³a, Winda robi swoje

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

    //¯eby tekst zachowywa³ siê jak w ALGO
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
    //OnResize:=Resized; //Poprawia po³o¿enie etykiety przy zmianie rozmiarów okna
   end;
end;

procedure TAlgoForm.StartStop(Sender: TObject);
{Wstrzymywanie wlasciwego watku roboczego}
begin
MyForm.Update;
Application.ProcessMessages;
CurrCanvas.Lock; {Nie mo¿na wstrzymywaæ jeœli wlaœnie rysuje}
if StartStopButton.Caption='Start' then
  begin
  Additional.Enabled:=false;{Blokuje setup na czas wykonaia watku}
  {Przygotowuje w¹tek wykonuj¹cy "Main"}
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
  MyThread.Suspend;{ Wstrzymuje w¹tek}
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

  //Jeœli w¹tek g³ówny dzia³a to wró¿y k³opoty...
  flaga:=(MyThread=nil) OR MyThread.Suspended OR MyThread.Completed;
  if not flaga then  {Ale to i tak rzadko zabezpiecza}
    begin
       MyForm.Hide;{ Tak jest najbezpieczniej ...}
       MyThread.Suspend;{ Wstrzymuje w¹tek}
       StartStopButton.Caption:='PAUSED'; {Jakby ktoœ "z modalu" ujawni³ jednak to okno}
       AddForm.Left:=MyForm.Left;{W miejsce orginalnego okna }
       AddForm.Top:=MyForm.Top;
    end;

  AddForm.ShowModal();

 if not flaga then
    begin
       MyThread.Resume;{ Jeœli wstrzyma³ w¹tek to rusza}
       StartStopButton.Caption:='Pause';
       MyForm.Show;
    end;
end;

Procedure TMyThread.Execute;
begin
  Completed:=false;
  { Wykonanie procedury zapamietanej jako "Main" }
  Main;
  {Trochê do zrobienia po "Main"}
  MyForm.CurrCanvas.Lock; {W sumie to chyba wsio ryba gdzie ten semafor???}
  MyForm.StartStopButton.Enabled:=false; {Zeby teraz ktoœ nie zastartowa³!}
  MyForm.CurrCanvas.UnLock;{Ale po co tu odblokowanie semafora?}
  Completed:=true;
  if system.IsConsole then
     system.Writeln(MyForm.ApplicationName,' : ','Watek aplikacji pomyslnie zakonczony')
     else
     Application.MessageBox('W¹tek aplikacji pomyœlnie zakoñczony',PChar(MyForm.ApplicationName));
  MyForm.Additional.Enabled:=true;{Odblokowuje setup bo juz nie ma watku}
  MyForm.StartStopButton.Caption:='Start'; {Przywraca nazwe przycisku startowego}
  MyForm.StartStopButton.Enabled:=true;{Teraz ju¿ mo¿na ponownie startowac}
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
CurrCanvas.Lock; {Nie mo¿na wstrzymywaæ jeœli wlaœnie rysuje}
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

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerw¹, np. readln}
Procedure TMyThread.UpdateVCLfromThread;
begin
Application.ProcessMessages;
MyForm.Update;
Application.ProcessMessages;
end;

procedure AlgoSync;
begin
if MyForm.CurrCanvas=nil then exit;//Niewypa³ :-)
MyThread.Synchronize(MyThread.UpdateVCLfromThread); //TO BARDZO SPOWALNIA
//MyThread.UpdateVCLfromThread  //A TAK TE¯ DZIA£A I NIE WIDZIALEM KLOPOTÓW ?
end;

{INICJACJA OKNA GRAFICZNEGO I W¥TKU OBSLUGI}
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{Uruchamia procedure zrobiona z programu g³ownego w osobnym w¹tku, ktory mo¿e uzywaæ poni¿szego interfaceu}
begin
  InitialiseUnit;  {Przygotowuje co trzeba jesli wczesniej nie zostalo wykonane}
  DefaultDumpName:=AppName;{Mo¿e byæ dlugie...}
  PrepareALGOWindow(MyForm,AppName,Width,Height);
  MyMain:=Main;
  if RunBeforeMain then
       AddForm.ShowModal();
  Application.Run; {Oddaje sterowanie g³ównego w¹tku do pêtli aplikacji}
  //Windows.TerminateThread(MyThread.Handle,0); //Bezwzglêdnie zabija w¹tek
  //MyThread.Destroy;        //Usuwa struktury DElphi ale w¹tek Win zostaje!!!!!
  //WriteComponentResFile('TAlgoForm.dfm',MyForm); //Zrzut DFMa, gdyby by³o trzeba
end;

procedure InitialiseUnit;
begin
  if Initialised then exit;
{INICJACJA APLIKACJI Delphi I REJESTRACJA G£ÓWNEJ FORMY}
  Application.Initialize;
{$IF DELPHI_VERSION <= 7 } //Mo¿e nie byæ dfm'a w wersji od 7 wzwy¿
  Application.CreateForm(TAlgoForm, MyForm);//Z DFMem
{$ELSE}
  Application.CreateForm(TForm, MyForm);//...i bez. Nie mo¿e byæ TAlgoForm bo wtedy szuka resourców
  AlgoHWND:=MyForm.GetOwnerWindow;
{$IFEND}
  AlgoHWND:=MyForm.WindowHandle;
  Initialised:=true;
end;

begin
  Randomize;
  //InitialiseUnit;  ???
end.





