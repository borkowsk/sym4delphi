Program ProstaGrafika;
{SZABLON - PRZED EDYCJ� POZAMIENIAJ NAZWY PRZEZ "ZAPISZ JAKO"!}
{Proste zestawienie formularza konfiguracyjnego z rysowaniem grafiki}

uses
  Algo in '..\..\Algo.pas',
  Forms,
  SetupFormUnit in 'SetupFormUnit.pas' {SetupForm};

{<--Wszystkie parametry pracy s� zdefiniowane jako zmienne w formularzu}

procedure Main;
var i:integer;
Begin
  {Kolorowy tr�jk�t}
  For i:=0 to SampleInteger do
    Begin
      MoveTo(SampleInteger,i);
      Pen(1,0,(2*i+50) mod 256,trunc(SampleFloat*i+50)mod 256);
      LineTo(0, 50)
    end;
   moveto(0,0);
   write(SampleString);
end;

{Szablonowy program g��wny inicjuj�cy formularze i uruchamiaj�cy modu� ALGO}
begin
Application.Title := 'Szablon grafiki';
Application.CreateForm(TSetupForm, SetupForm);
{Tworzenie formy konfiguracyjnej}
InsertSecondaryForm(SetupForm,'Konfiguracja',true);{Wpi�cie jej do struktur modu�u}
RunAsALGO(Main,'Prosta grafika',SWIDTH,SHEIGHT);{Uruchomienie modu�u}
{Kod umieszczony poni�ej wykona si� po zamkni�ciu g��wnego okna, albo i nigdy...}
end.
