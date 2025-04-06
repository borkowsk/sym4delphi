unit Algo;
(*
IMPLEMENTACJA CZĘŚCI NIESTANDARDOWEGO INTERFEJSU "ALGO" DLA DELPHI  wersja 0.31
================================================================================
Autor: Wojciech Borkowski,                                            29.02.2012
          Instytut Studiów Społecznych UW: borkowsk@samba.iss.uw.edu.pl
          Społeczna Psychologia Informatyki i Komunikacji (SPIK) SWPS:
                                           borkowsk@spik.swps.edu.pl

Unit ma przygotowywać "formę" z obrazkiem do rysowania i implementować funkcje
graficzne i inne niezbędne (IsEvent i Event) specyficzne dla kompilatorka ALGO.
Ponadto ma zaimplementowany zestaw procedur Write/Writeln, zeby pisanie odbywało
się jak w ALGO na okno graficzne. Nie ma natomiast własnego zestawu read co
może objawiac sie brakiem synchronizacji okna graficznego i konsoli na ktorej
dziala read bez parametru plikowego.
*)

interface
const DELPHI_VERSION=8;{7,8...Warunkowa kompilacja w zalezności od wersji Delphi}

(*
SPOSÓB UŻYCIA:
Program dla ALGO należy zapisac pod nazwą z rozszerzeniem dpr (Delphi project)
i umiescic w katalogu razem z plikami Algo.pas i Algo.dfm. Plik dfm nie jest potrzebnym gdy
kompilator Delphi jest w wersji wiekszej niż 7 - ale trzeba wtedy zmienić
definicje DELPHI_VERSION w pliku Algo.pas na wartość większą niż 7.

Po pierwszej linii programu w pliku dpr, brzmiącej zwykle jakos tak:

Program Nazwaprogramu;

Trzeba umieścić linię:

uses Algo in 'Algo.pas';  {$APPTYPE CONSOLE}

Następnie pierwotny program główny należy przekształcić w procedurę
(nazwaną np. Main), a w nowym programie głównym umieścić jedynie wywołanie
procedury uruchamiającej aplikacje:

begin
RunAsALGO(Main,'Nazwa aplikacji')
end.

czyli podając jako pierwszy parametr procedurę reprezentującą dawny program
główny, a jako drugi nazwę dla okna. Można podać też wymagane rozmiary użytkowe
okna grafiki jako dwa kolejne parametry. Np.:

RunAsALGO(Main,'Moja aplikacja',800,600)

Po nacisnieciu pierwszego przycisku w oknie graficznym procedura Main zostanie
uruchomiona w osobnym wątku mogącym używać interfejsu kompatybilnego z
rozszerzeniami ALGO w stosunku do standardu PASCALa.
Wyjście graficzne zostanie skierowane, w zaleznosci od stanu drugiego przycisku,
na paintbox lub image okna graficznego, a tekstowe do okna oraz jednocześnie na
konsolę.

POPRAWKI W WERSJACH:
0.31:
  * Dodanie funkcji fillpoly, typu xypoint i przykladowego wielokata ludzik.
  * Reorganizacja kolejności procedur i treści komentarzy
  * Komunikat o nieprawidłowej kolejności wywołań w przypadku użycia InsertSecondaryForm
    a właściwie CreateForm bez wywołania InitialiseUnit.
0.30:
  * Uelastycznienie sterowania inicializacją: zmienna Initialised, i procedura InitiolisedUnit;

0.290:
  * Problem czyszczenia ekranu przez Clear - nie zawsze było na biało
  * Wprowadzenie flagi AlgoSyncPedantic sposobu synchronizacji (wersja "pedantic" jest powolna)
  * Rozbudowa funkcji writeLn do 8 argumentów
  * Dodanie do funkcji format domyślnych wartości parametrów
0.289:
  * Problem inicjalizacji początkowego pędzla w Clear niezgodnej z pisaniem tekstu
    bo ALGO ma zawsze wymazujące tło dla tekstów
  * Próby lepszego rozwiązania zakonczania aplikacji - czasem bywają wyjątki przy
    kliknięciu X. Ale na nic bo Delphi nie daje szansy na bezwzględne wyczyszczenie
    wątku w TThread. Liczy na to że wątek sam się zawsze zakończy!!!
0.285:
  *  Więcej parametrów w Write i Writeln
  *  Jakieś inne poprawki techniczne??? To do sprawdzenia.
0.281:
  * Etykieta autorska przenosząca na stronę www.iss.uw.edu.pl/borkowski
0.28:
  * Zablokowanie wywołania formy, gdy wątek główny działa i nie jest zawieszony
0.272:
  * ...........walka z synchronizacją :((((   Bez skutku, nadal TPicture rysuje się kawałkami
0.271:
 * Poprawienie kompatybilnosci z Delphi 7 (WindowHandle zamiast GetOwnerWindow)
 * i przywrócenie zaginionego wywołania Randomize w inicjlizacji modułu
0.27:
 * Poprawione zarządzanie wywoływaniem formularza konfiguracyjnego
 * Główna forma jest chowana, a wątek zawieszany jeśli konfiguracja zostanie
   wywołana bez jawnego zawieszenia wątku głównego
 * Funkcja dająca dostęp do surowego uchwytu okna
 * Dodanie ikonki z kwadracikami do domyślnego DFMa
 * Dodanie 2 przykładów z oknem konfiguracyjnym
0.25-26:
 * Funkcja zmiany rozmiaru ekranu
 * Zabezpieczenie zawieszania wątku w czasie wywoływania setupu
 * Dodanie automatycznej numeracji obrazków
0.24:
 * Dodano mozliwość restartu głównego wątku
 * Dodano możliwość podpiecią dodakowej formy zrobionej w kreatorze, a z nią
   całej praktycznie całej aplikacji Delphi, pod warunkiem ręcznej inicjalizacji
   form w programie głównym.
0.23:
 * Dodano wywołani AlgoSync; w procedurze Delay()
 * Dodano komunikat o zakonczeniu wątku aplikacyjnego
 * Dodano procedure Randomize(seed) której nie ma w Delphi
 * Dodano funkcje format(v:number,f,f):string zastępującą nieprzykrywalne konstrukcje
   formatujące liczby w wywołaniach writeln.
0.22:
 * Dodano wywołanie procedury Randomize w inicjacji wątku głównego dla poprawienia
   zgodności z tym co robi ALGO
 * Usunięcie błędu w wariantowej kompilacji dla wersji 6 i 7 (z plikiem dfm)
   i wyzszych (bez pliku)

ZNANE NIEKOMPATYBILNOŚĆI I BŁĘDY:
 * Ze wzgledu na brak parametrów otwartych w Delphi procedury write[ln]
   akceptują jedynie do 7 parametrów. Wywołania z większą liczbą parametrów
   trzeba podzielić.

 * Brak jest wlasnej implementacji Read, Readln, więc procedury te mogą nie
   działac asynchronicznie w stosunku do okna graficznego.
   Pomaga wywołanie przed ich użyciem dodatkowej procedury AlgoSync;

 * Funkcje readln/read czytają treść tylko z konsoli tekstowej nie pozostawiając
    echa na ekranie graficznym i nie przechodząc tam do następnej linii.

 * W wersji 6 i 7 nie działa nachylenie tekstu, a  żadnej nie działa wytłuszczanie

 * Rysowanie w trybie pliku graficznego - czyli przygotowanie do zapisu "obrazka"
   jest bardzo powolne, a ponadto często potrafi pomijać fragmenty rysunku.
   Wynika to z nieodkrytego błędu współdziałania obu wątków programu i okazało
   się niezwykle trudne do usunięcia

 * Nie zaimplementowano PlaySound - zamiast tego jest prosty sygnał dźwiękowy
*)

{   TO CO KONIECZNE DO URUCHOMIENIA MODULU I APLIKACJI GO UŻYWAJACEJ           }
{==============================================================================}
{
Procedura uruchamiania aplikacji:
Uruchamia procedure zrobioną z programu głownego ALGO w osobnym wątku,
ktory może uzywać szerokiego podzbioru funkcji i procedur interfejsu ALGO.}
type MainProcedure=procedure;
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{
Procedura umożliwia uruchamienie usług unitu i obiektu Application
przed wywołaniem RunAsALGO. Jest to potrzebne, gdy używane są dodatkowe
formularze Delphi podłączane poprzez InsertSecondaryForm}
procedure InitialiseUnit;

{
Procedura pozwalajaca rozbudować aplikacje o normalne formularze ObjectPascala.
Żeby zadziałała trzeba ją wywołac PRZED wywołaniem RunAsALGO().}
Procedure InsertSecondaryForm(Form:pointer;
                           ButtName:string;
                           RunFirst:boolean=true
                           );

var DefaultDumpName:string; {< Rdzen nazwy zrzutów ekranu. Potem jest numer zrzutu
                               Domyslnie ustawiony na nazwę zplikacji, 
                               ale może być co chcesz
                               }



{   FUNKCJE   I   PROCEDURY   ZGODNOŚCI   Z   ALGO                             }
{==============================================================================}

{Grafika podstawowa
==================}
Procedure Clear; {< Wyczyszczenie ekranu graficznego i usytuowanie kursora
                  graficznego w lewym górnym rogu okna grafiki.
Oprócz wyczyszczenia okna, procedura wykonuje następujące czynności:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wypełnienia;
- ustawia czcionkę (8,0,400).
}
Procedure Font(rozmiar, kierunek, grubosc: Integer); {< Wybiera rozmiar (6..72), kierunek (0..359) i grubość (1..1000) wypisywanych tekstów procedurami Pisz i PiszLn. Argumentami procedury Czcionka mogą być dowolne wyrażenia całkowite.}
Procedure Line(x1, y1, x2, y2: Integer); {< Rysuje odcinek linii prostej łączący punkt o współrzędnych (x1, y1) z punktem o współrzędnych (x2, y2). Przemieszcza także kursor graficzny do punktu o współrzędnych (x2, y2).}
Procedure LineTo(x, y: Integer); {< Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu o współrzędnych (x, y). Przemieszcza także kursor graficzny do punktu o współrzędnych (x, y).}
Procedure MoveTo(x, y: Integer); {< Przemieszcza kursor graficzny do punktu o współrzędnych (x, y).}
Procedure Coordinates(Var x, y: Integer); {< Zwraca informację o współrzędnych kursora graficznego.}
Procedure Pen(n, r, g, b: Integer); {< Ustala kolor i grubość rysowanych linii. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - grubość.}
Procedure Brush(k, r, g, b: Integer); {< Ustala kolor i styl wypełnienia. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim. Jeśli k=1 to figury są zamalowywane wybranym kolorem pędzla, jeśli k=0 to kolor jest przezroczysty.}
Procedure TextColor(r, g, b: Integer); {< Określa kolor dla wypisywanych tekstów procedurami Pisz i PiszLn. Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim.}
Procedure Rectangle(x1, y1, x2, y2: Integer); {< Rysuje prostokąt, którego przeciwległe wierzchołki mają współrzędne (x1, y1) i (x2, y2). Przesuwa także kursor graficzny do punktu o współrzędnych (x2, y2).}
Procedure Ellipse(x1, y1, x2, y2: Integer); {< Rysuje elipsę. Parametry określają współrzędne dwóch przeciwległych wierzchołków prostokąta opisanego na elipsie. Współrzędne kursora graficznego nie ulegają zmianie.}
Procedure Point(x, y: Integer); {< Zaznacza punkt o współrzędnych (x, y) w kolorze pisaka. Przemieszcza także kursor graficzny do punktu o współrzędnych (x, y).}
Procedure Fill(x, y: Integer); {< Wypełnia zadanym kolorem pędzla wnętrze obszaru obejmującego punkt o współrzędnych (x, y).}
//forward Procedure Fillpoly; - Nie występujące w ALGO, ale dodana, w sekcji rozszerzeń }

{Inne
=====}
Procedure Date(Var rok, miesiac, dzien: integer);{< Procedura wylicza i zwraca na parametry aktualną datę, czyli rok (1900..2099), miesiąc (1..12), dzień i dzień (1.. 31).}
Procedure Time(Var godzina, minuta, sekunda: Integer);{< Procedura wylicza  i zwraca na parametry aktualny czas, czyli godzinę (0..23), minuty (0..59) i sekundy (0..59).}
Procedure Delay(ms: Integer);{Wstrzymanie wykonywania programu na okres ms milisekund.}
Procedure PlaySound(atr: Integer; plik: string);{<  Odtwarazanie plików wav.
                                                        Pierwszym parametrem jest wyrażenie całkowite atr. oznaczające akcję.
                                                        0 - wstrzymuje wykonywania programu na czas odtwarzania;
                                                        1 - odtwarza plik bez wstrzymania programu;
                                                        2 - jeśli w momencie wywołania jest odtwarzany inny dźwięk to zostanie przerwany;
                                                        3 - odtwarzanie w pętli bez końca;
                                                        4 - wstrzymanie odtwarzania pliku.
                                                        Drugim parametrem jest napis określający nazwę pliku typu *.wav. 
                                                        W ogólnym przypadku nazwa określa pełną ścieżkę dostępu do pliku - dysk, folder i jego nazwę.
                                                }

{ Obsługa zdarzeń czyli okiennego wejścia-wyjścia
-------------------------------------------------}
Function IsEvent: Boolean;{< Wynikiem funkcji jest wartość logiczna prawda, jeśli od ostatniego wywołania procedury Zdarzenie zaszło jakieś zdarzenie (naciśnięcie klawisza klawiatury lub lewego przycisku myszy w obrębie okna wyników), w przeciwnym przypadku fałsz.}
Procedure Event(Var k, x, y: Integer);{< Za zdarzenie uważa się naciśnięcie klawisza na klawiaturze lub wciśnięcie lewego przycisku myszki w obrębie okna wyników. Jeśli w momencie wywołania procedury zdarzenia jeszcze nie było, to program oczekuje zdarzenia.
                                        Wywołanie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y wartości:
                                        k=1, x=kod, y=0 - naciśnięto klawisz sterujący nie mający reprezentacji ASCII (np. Home, F5);
                                        k=1, x=kod, y=1 - naciśnięto klawisz sterujący ASCII (np. Enter, Tab);
                                        k=1, x=kod, y=2 - naciśnięto klawisz ASCII o kodzie >31 (np. t, H, O);
                                        k=2, x, y=współrzędne kursora myszy - wciśnięto lewy przycisk myszy;
                                        k=3, x, y=współrzędne kursora myszy - mysz przemieszcza się z wciśniętym lewym przyciskiem.
                                      }

{ Obsługa `Write` i `Writeln` piszących równocześnie na okno graficzne i konsolę tekstową
-----------------------------------------------------------------------------------------
Niestety w Delphi `Write` i `Writeln` ukryte są w module system, którego nazwy trzeba 
jawnie użyć, co jest dodatkowa, i niepotrzebną modyfikacja w kodzie wziętym z ALGO.}
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

{ I do tego niestety to samo dla plików
---------------------------------------
Niestety inaczej nie działa w Delphi, chyba że za pomocą `system.write(...)` 
czy `system.writeln(...)`, ale to już są kolejne modyfikacje kodu              }
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

{DO ROZSZERZENIA O TO CZEGO W ALGO NIE MA, LUB NIE MUSI BYĆ - DLA POPRAWIENIA ZGODNOŚCI}
{======================================================================================}

{ Wymuszenie uaktualnienia okna graficznego przed spodziewana przerwą, np. readln }
procedure AlgoSync;
var AlgoSyncPedantic:boolean=true; {< Wersja pedantyczna jest bezpieczna, ale wolniejsza }

{ Algopodobne Randomize }
procedure Randomize;overload;
procedure Randomize(seed:integer);overload;
function  GetLastRandSeed:longint;


{ Funkcja formatująca reale i integery do uzycia zamiast paskalowej składni 
write/string x:c:p, której nie da się tak "przeciążyć" w Delphi }
function Format(v:real;c:integer=-1;ap:integer=3):string;overload;
function Format(v:integer;c:integer=-1):string;overload;

{ Zmiana rozmiaru okna i odczytanie aktualnego rozmiaru.   }
Procedure ChangeSize(NWidth,NHeight:integer);
Procedure GetSize(var Width,Height:integer);

{ Zmiana nazwy głównego okna z grafiką }
Procedure SetTitle(tit:string);

{ Funkcje pozwalające otrzymać uchwyt do głównego formularza aplikacji Delphi i do całego surowego okna
- trzeba je zrzutowac i używać bardzo ostrożnie, bo omija się normalny kod obsługi.
Np. nie wolno zmieniać za ich pomocą rozmiarów okien! }
function GetMyForm:pointer;
function GetMyHwnd:LongWord;

{ FillPoly() nie występujące w ALGO, ale jest to bardzo potrzebne rysowanie wypełnionego wielokąta.}
{ typ xypoint konieczny do definiowania WIEŻCHOŁKÓW wielokąta }
type xypoint=record
        x,y:integer;
        end;
{Właściwa procedura FillPoly() rysująca wielokąt. }
{lst to lista punktów wielokąta, automatycznie domykana}
{x,y są traktowane jako przemieszczenie wielokąta do tego punktu}
{sca to skala - można doraźnie zwiększyć lub zmniejszyć, ale nie za darmo}
Procedure Fillpoly(const lst{:array[0..10000] of xypoint};size:Integer;x:Integer=0;y:Integer=0;sca:real=1);

{ przykładowy wielokąt}
const Ludzik:array[1..28] of xypoint=
(
(x:0;y:-12),(x:1;y:-12),(x:2;y:-11),(x:2;y:-10),(x:1;y:-8),(x:4;y:-6),(x:4;y:3),
(x:3;y:2),(x:3;y:-3),(x:3;y:0),(x:2;y:11),(x:3;y:11),(x:3;y:12),(x:0;y:12),(x:0;y:2),
(x:0;y:12),(x:-3;y:12),(x:-3;y:11),(x:-2;y:11),(x:-3;y:0),(x:-3;y:-3),(x:-3;y:2),
(x:-4;y:3),(x:-4;y:-6),(x:-1;y:-8),(x:-2;y:-10),(x:-2;y:-11),(x:-1;y:-12));
const LudzikWidth=8;
const LudzikHeight=24;

{DALEJ IMPLEMENTACJA MODUŁU - NAJLEPIEJ NIE DOTYKAĆ :-) 
======================================================}
implementation
uses  Windows,ShellAPI, Messages, SysUtils, Variants, Classes,
      Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,AppEvnts;//,MPlayer; NIE MA KODU PRZYKŁADOWEGO

{$IF DELPHI_VERSION <= 7 } //W starszych wersjach musi być plik Algo.dfm
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
     StartStopButton: TButton; //Sterowanie wątkiem symulacji
     ImagePaintBoxButton: TButton;//Zmiana sposobu rysowania
     SavePictButton: TButton;  //Zapis zawartości okna rysowanego na TImage
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
{Rysuje odcinek linii prostej łączący punkt o współrzędnych (x1, y1)
z punktem o współrzędnych (x2, y2).
Przemieszcza także kursor graficzny do punktu o współrzędnych (x2, y2).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.MoveTo(x1,y1);
MyForm.CurrCanvas.LineTo(x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure LineTo(x, y: Integer);
{Rysuje odcinek linii prostej od aktualnej pozycji kursora graficznego do punktu
 o współrzędnych (x, y).
 Przemieszcza także kursor graficzny do punktu o współrzędnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.LineTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure MoveTo(x, y: Integer);
{Przemieszcza kursor graficzny do punktu o współrzędnych (x, y).}
begin
if MyForm.CurrCanvas=nil then
  begin
    system.write('.');
    exit;//Niewypał :-)
  end;
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.MoveTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure Coordinates(Var x, y: Integer);
{Zwraca informację o współrzędnych kursora graficznego.}
begin
MyForm.CurrCanvas.Lock;
x:=MyForm.CurrCanvas.PenPos.X;
y:=MyForm.CurrCanvas.PenPos.Y;
MyForm.CurrCanvas.Unlock;
end;

Procedure Pen(n, r, g, b: Integer);
{Ustala kolor i grubość rysowanych linii. Parametry r, g, b –
to nasycenie kolorami czerwonym, zielonym i niebieskim, a parametr n - grubość.}
begin
if MyForm.CurrCanvas=nil then exit;//Niewypał :-)
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pen.Color:=RGB(abs(r) mod 256,abs(g) mod 256, abs(b) mod 256);
MyForm.CurrCanvas.Pen.Width:=n;
MyForm.CurrCanvas.Unlock;
end;

var  BrushStyleForText:TBrushStyle=bsSolid; {Do tekstu musi być od początku solid
                                             bo tak jest domyslnie w ALGO, i się
                                             nie zmienia!
                                             }
Procedure Brush(k, r, g, b: Integer);
{Ustala kolor i styl wypełnienia. Parametry r, g, b –
to nasycenie kolorami czerwonym, zielonym i niebieskim.
Jeśli k=1 to figury są zamalowywane wybranym kolorem pędzla,
jeśli k=0 to kolor jest przezroczysty.}
begin
if MyForm.CurrCanvas=nil then exit;//Niewypał :-)
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
  MyForm.CurrCanvas.Brush.Style:=bsClear;//Czy tak zrobić przezroczysty brush?
  end;
MyForm.CurrCanvas.Unlock;
end;

Procedure TextColor(r, g, b: Integer);
{Określa kolor dla wypisywanych tekstów procedurami Pisz i PiszLn.
Parametry r, g, b – to nasycenie kolorami czerwonym, zielonym i niebieskim.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Font.Color:=RGB(r,g,b);//Chyba nie działa poprawnie
MyForm.CurrCanvas.Unlock;
end;

Procedure Font(rozmiar, kierunek, grubosc: Integer);
{Wybiera rozmiar (6..72), kierunek (0..359) i grubość (1..1000)
wypisywanych tekstów procedurami Pisz i PiszLn. Argumentami procedury Czcionka
mogą być dowolne wyrażenia całkowite.}
begin
MyForm.CurrCanvas.Lock;                    //TFont
MyForm.CurrCanvas.Font.Size:=rozmiar;
{$IF DELPHI_VERSION > 7 } //Może nie być tej własciwości w starszych
MyForm.CurrCanvas.Font.Orientation:=kierunek*10;//Jakie tu są jednostki???
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Weight
//MyForm.CurrCanvas.Font.
//MyForm.CurrCanvas.Font.Pitch???
{$IFEND}
MyForm.CurrCanvas.Unlock;
end;

Procedure Rectangle(x1, y1, x2, y2: Integer);
{Rysuje prostokąt, którego przeciwległe wierzchołki mają współrzędne
(x1, y1) i (x2, y2).
Przesuwa także kursor graficzny do punktu o współrzędnych (x2, y2).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Rectangle(x1,y1,x2,y2);
MyForm.CurrCanvas.MoveTo(x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure Ellipse(x1, y1, x2, y2: Integer);
{Rysuje elipsę. Parametry określają współrzędne dwóch przeciwległych wierzchołków
prostokąta opisanego na elipsie. Współrzędne kursora graficznego nie ulegają zmianie.}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Ellipse(x1,y1,x2,y2);
MyForm.CurrCanvas.Unlock;
end;

Procedure Point(x, y: Integer);
{Zaznacza punkt o współrzędnych (x, y) w kolorze pisaka.
Przemieszcza także kursor graficzny do punktu o współrzędnych (x, y).}
begin
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.Pixels[x,y]:=MyForm.CurrCanvas.Pen.Color;
MyForm.CurrCanvas.MoveTo(x,y);
MyForm.CurrCanvas.Unlock;
end;

Procedure Fill(x, y: Integer);
{Wypełnia zadanym kolorem pędzla wnętrze obszaru obejmującego punkt o współrzędnych (x, y).}
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
Oprócz wyczyszczenia okna, procedura wykonuje następujące czynności:
- ustawia czarny pisak;
- ustawia czarny kolor tekstu;
- ustawia przezroczysty kolor wypełnienia;
- ustawia czcionkę (8,0,400).
}
begin
if (not Initialised) or (MyForm.CurrCanvas=nil) then exit;//Niewypał :-)
Brush(1,255,255,255);  {Do czyszczenia}
MyForm.CurrCanvas.Lock;
MyForm.CurrCanvas.FillRect(MyForm.CurrCanvas.ClipRect);
MyForm.CurrCanvas.Unlock;
Pen(1,0,0,0);
TextColor(0,0,0);
Brush(0,0,0,0);
BrushStyleForText:=bsSolid;{Ale tekst zawsze ma zamazujące tło!!!}
Font(8,0,400);
MoveTo(0,0);
end;

{Inne}
Procedure Date(Var rok, miesiac, dzien: integer);
{Procedura wylicza aktualną datę, czyli rok (1900..2099), miesiąc (1..12), dzień i dzień (1.. 31).}
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
{Procedura wylicza aktualny czas, czyli godzinę (0..23), minuty (0..59) i sekundy (0..59).}
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
Czyli usypianie wątku "Main"}
begin
   if Initialised then AlgoSync;   {Delay się przydaje i przed iicjalizacją aplikacji}
   Sleep(ms*2); {Traktowanie doslowne daje bardzo krotkie uśpienie - Why???}
end;

Procedure PlaySound(atr: Integer; plik: string);
{Odtwarza pliki dźwiękowe typu *.wav.
Pierwszym parametrem jest wyrażenie całkowite atr.
0 - wstrzymuje wykonywania programu na czas odtwarzania;
1 - odtwarza plik bez wstrzymania programu;
2 - jeśli w momencie wywołania jest odtwarzany inny dźwięk to zostanie przerwany;
3 - odtwarzanie w pętli bez końca;
4 - wstrzymanie odtwarzania pliku.
Drugim parametrem jest napis określający nazwę pliku typu *.wav.
W ogólnym przypadku nazwa określa pełną ścieżkę dostępu do pliku -
dysk, folder i jego nazwę.
}
begin
windows.Beep(600,900);windows.Beep(300,900);windows.beep(600,900);//Not implemented yet...
//Windows  PlaySound(plik); czy może :=TMediaPlayer.Create(); Stop;  ???
end;

function GetMyForm:pointer;
begin
  GetMyForm:=MyForm;
end;

function GetMyHwnd:LongWord;
begin
  GetMyHwnd:=AlgoHWND;
end;

{Okienne wejście-wyjście}
procedure OutVar(p:variant);
var outstr:string;
    CurrBrushStyle:TBrushStyle;
begin
if system.IsConsole then
    system.write(p); {Żeby się nie wywalał jak nie ma konsoli}
if (MyForm=nil) or (MyForm.CurrCanvas=nil) then
          exit; {Żeby się nie wywalał, jak forma nie do konca stworzona}
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
    Moveto(PenPos.X+1,PenPos.Y);{Bo czasem następny tekst włazi na poprzedni}
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

{OBSŁUGA PLIKÓW - Ach gdzie są procedury ze swobodną liczbą parametrów!??}
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
var lastSeed:Integer=0;{Do zapamiętania ostatniego Randomize}
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
{Wynikiem funkcji jest wartość logiczna prawda, jeśli od ostatniego wywołania
procedury Zdarzenie zaszło jakieś zdarzenie (naciśnięcie klawisza klawiatury
lub lewego przycisku myszy w obrębie okna wyników), w przeciwnym przypadku fałsz.}
begin
AlgoSync;
MyForm.CurrCanvas.Lock;
result:=not MyForm.QEmpty;
MyForm.CurrCanvas.UnLock;
end;

Procedure Event(Var k, x, y: Integer);
{Za zdarzenie uważa się naciśnięcie klawisza na klawiaturze lub wciśnięcie
lewego przycisku myszki w obrębie okna wyników. Jeśli w momencie wywołania
procedury zdarzenia jeszcze nie było, to program oczekuje zdarzenia.
Wywołanie procedury Zdarzenie powoduje przypisanie zmiennym k, x, y wartości:
k=1, x=kod, y=0 - naciśnięto klawisz sterujący nie mający reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciśnięto klawisz sterujący ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciśnięto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=współrzędne kursora myszy - wciśnięto lewy przycisk myszy;
k=3, x, y=współrzędne kursora myszy - mysz przemieszcza się z wciśniętym lewym przyciskiem.
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
k=1, x=kod, y=0 - naciśnięto klawisz sterujący nie mający reprezentacji ASCII (np. Home, F5);
k=1, x=kod, y=1 - naciśnięto klawisz sterujący ASCII (np. Enter, Tab);
k=1, x=kod, y=2 - naciśnięto klawisz ASCII o kodzie >31 (np. t, H, O);
k=2, x, y=współrzędne kursora myszy - wciśnięto lewy przycisk myszy;
k=3, x, y=współrzędne kursora myszy - mysz przemieszcza się z wciśniętym lewym przyciskiem.\
}
procedure TAlgoForm.GrabberKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
MyArea.Canvas.Lock;
QAdd(1,Key,0);//Każdy klawisz - także bez reprezentacji ASCII
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
            QAdd(1,ord(Key),2);//Zwykły kod ascii
//beep();
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.GrabberKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
MyArea.Canvas.Lock;
 Grabber.Text:='';//Puszczony - czyścimy
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.paintboxMouseClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MyArea.Canvas.Lock;
QAdd(2,X,Y);//wciśnięto lewy przycisk myszy
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.paintboxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
MyArea.Canvas.Lock;
Grabber.SetFocus();
if ssLeft in Shift then
         QAdd(3,X,Y);//mysz przemieszcza się z wciśniętym lewym przyciskiem
MyArea.Canvas.UnLock;
end;

procedure TAlgoForm.PaintBoxRepaint(Sender: TObject);
{Odrysowywanie paintboxa przy odslonieciu - tylko tło}
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

CurrCanvas.Lock;{Ma być zmiana canvasu - trzeba go uchwycić!}
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
  MyForm.AutoScroll:=true; //Na wypadek gdyby się user uparł zmieniać rozmiar
  MyArea.Canvas.Unlock;
end
else
begin
  MyImage.Visible:=false;
  MyArea.Visible:=true;
  SavePictButton.Enabled:=false;
  ImagePaintBoxButton.Caption:='Paint image';
  CurrCanvas:=MyArea.Canvas;
  MyForm.AutoScroll:=false; //I tak nie działa - wymaga implementacji "repaint"
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
        Windows.MessageBox(0,'Używając dodatkowych okienek musisz najpierw użyć InitialiseUnit','Unit ALGO',MB_ICONSTOP);
      halt;
    end;
  RunBeforeMain:=RunFirst;
  ButtonName:=ButtName;
  AddForm:=Form;
end;

//Rozmiary ekrany
/////////////////////////////////////////////
var LastWidth,LastHeight:integer; //Zapamiętane z ostatniej zmiany

Procedure GetSize(var Width,Height:integer);
begin
 Width:=LastWidth;
 Height:=LastHeight;
end;

Procedure ChangeSize(NWidth,NHeight:integer);
begin
 LastWidth:=NWidth;  //Zapisanie życzenia użytkownika
 LastHeight:=NHeight;

MyForm.Width:=NWidth+20;
    if MyForm.Width<370 then
               MyForm.Width:=370;//Musi zostać miejsce na przyciski i editbox
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

// Przygotowywanie głównej Form-y do pracy
///////////////////////////////////////////////////////////////////
procedure PrepareALGOWindow(MyForm:TAlgoForm;setcaption:string;NWidth,NHeight:integer);
{W wersjach Delphi powyżej 6 (?) może się obyć bez pliku dfm}
var saveleft:integer;
begin
 LastWidth:=NWidth;  //Zapisanie życzenia użytkownika
 LastHeight:=NHeight;

  with MyForm do
   begin
    QInit;
{$IF DELPHI_VERSION > 7 } //Może nie być dfm'a
    //Czy jesteś pewny że nie potrzebujesz pliku DFM?
    MyImage:=TImage.Create(MyForm);
    MyArea:=TPaintBox.Create(MyForm);
    StartStopButton:=TButton.Create(MyForm);
    ImagePaintBoxButton:=TButton.Create(MyForm);
    SavePictButton:=TButton.Create(MyForm);
    Additional:=TButton.Create(MyForm);
    Grabber:=TEdit.Create(MyForm);
    AlgoAppEvents:=TApplicationEvents.Create(MyForm);
    {POWIĄZANIE UTWORZONYCH "KONTROLEK" Z FORMĄ}
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
               MyForm.Width:=350;//Musi zostać miejsce na przyciski i editbox
    MyForm.Height:=NHeight+70;
    //MyForm.Left:=saveleft;   i tak nie działa, Winda robi swoje

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

    //Żeby tekst zachowywał się jak w ALGO
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
    //OnResize:=Resized; //Poprawia położenie etykiety przy zmianie rozmiarów okna
   end;
end;

procedure TAlgoForm.StartStop(Sender: TObject);
{Wstrzymywanie wlasciwego watku roboczego}
begin
MyForm.Update;
Application.ProcessMessages;
CurrCanvas.Lock; {Nie można wstrzymywać jeśli wlaśnie rysuje}
if StartStopButton.Caption='Start' then
  begin
  Additional.Enabled:=false;{Blokuje setup na czas wykonaia watku}
  {Przygotowuje wątek wykonujący "Main"}
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
  MyThread.Suspend;{ Wstrzymuje wątek}
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

  //Jeśli wątek główny działa to wróży kłopoty...
  flaga:=(MyThread=nil) OR MyThread.Suspended OR MyThread.Completed;
  if not flaga then  {Ale to i tak rzadko zabezpiecza}
    begin
       MyForm.Hide;{ Tak jest najbezpieczniej ...}
       MyThread.Suspend;{ Wstrzymuje wątek}
       StartStopButton.Caption:='PAUSED'; {Jakby ktoś "z modalu" ujawnił jednak to okno}
       AddForm.Left:=MyForm.Left;{W miejsce orginalnego okna }
       AddForm.Top:=MyForm.Top;
    end;

  AddForm.ShowModal();

 if not flaga then
    begin
       MyThread.Resume;{ Jeśli wstrzymał wątek to rusza}
       StartStopButton.Caption:='Pause';
       MyForm.Show;
    end;
end;

Procedure TMyThread.Execute;
begin
  Completed:=false;
  { Wykonanie procedury zapamietanej jako "Main" }
  Main;
  {Trochę do zrobienia po "Main"}
  MyForm.CurrCanvas.Lock; {W sumie to chyba wsio ryba gdzie ten semafor???}
  MyForm.StartStopButton.Enabled:=false; {Zeby teraz ktoś nie zastartował!}
  MyForm.CurrCanvas.UnLock;{Ale po co tu odblokowanie semafora?}
  Completed:=true;
  if system.IsConsole then
     system.Writeln(MyForm.ApplicationName,' : ','Watek aplikacji pomyslnie zakonczony')
     else
     Application.MessageBox('Wątek aplikacji pomyślnie zakończony',PChar(MyForm.ApplicationName));
  MyForm.Additional.Enabled:=true;{Odblokowuje setup bo juz nie ma watku}
  MyForm.StartStopButton.Caption:='Start'; {Przywraca nazwe przycisku startowego}
  MyForm.StartStopButton.Enabled:=true;{Teraz już można ponownie startowac}
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
CurrCanvas.Lock; {Nie można wstrzymywać jeśli wlaśnie rysuje}
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

{Zapewnia uaktualnienie okna graficznego przed spodziewana przerwą, np. readln}
Procedure TMyThread.UpdateVCLfromThread;
begin
Application.ProcessMessages;
MyForm.Update;
Application.ProcessMessages;
end;

procedure AlgoSync;
begin
if MyForm.CurrCanvas=nil then exit;//Niewypał :-)
MyThread.Synchronize(MyThread.UpdateVCLfromThread); //TO BARDZO SPOWALNIA
//MyThread.UpdateVCLfromThread  //A TAK TEŻ DZIAŁA I NIE WIDZIALEM KLOPOTÓW ?
end;

{INICJACJA OKNA GRAFICZNEGO I WĄTKU OBSLUGI}
Procedure RunAsALGO(Main:MainProcedure;
                    AppName:string='Application';
                    Width:integer=800;
                    Height:integer=800
                    );
{Uruchamia procedure zrobiona z programu głownego w osobnym wątku, ktory może uzywać poniższego interfaceu}
begin
  InitialiseUnit;  {Przygotowuje co trzeba jesli wczesniej nie zostalo wykonane}
  DefaultDumpName:=AppName;{Może być dlugie...}
  PrepareALGOWindow(MyForm,AppName,Width,Height);
  MyMain:=Main;
  if RunBeforeMain then
       AddForm.ShowModal();
  Application.Run; {Oddaje sterowanie głównego wątku do pętli aplikacji}
  //Windows.TerminateThread(MyThread.Handle,0); //Bezwzględnie zabija wątek
  //MyThread.Destroy;        //Usuwa struktury DElphi ale wątek Win zostaje!!!!!
  //WriteComponentResFile('TAlgoForm.dfm',MyForm); //Zrzut DFMa, gdyby było trzeba
end;

procedure InitialiseUnit;
begin
  if Initialised then exit;
{INICJACJA APLIKACJI Delphi I REJESTRACJA GŁÓWNEJ FORMY}
  Application.Initialize;
{$IF DELPHI_VERSION <= 7 } //Może nie być dfm'a w wersji od 7 wzwyż
  Application.CreateForm(TAlgoForm, MyForm);//Z DFMem
{$ELSE}
  Application.CreateForm(TForm, MyForm);//...i bez. Nie może być TAlgoForm bo wtedy szuka resourców
  AlgoHWND:=MyForm.GetOwnerWindow;
{$IFEND}
  AlgoHWND:=MyForm.WindowHandle;
  Initialised:=true;
end;

begin
  Randomize;
  //InitialiseUnit;  ???
end.





