unit SetupFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, Algo, ExtCtrls;

const
{Maksymalne i monimalene warto�ci wybranych zmiennych}
   MaxSampleInt=500;
   MinSampleFloat=0;
   MaxSampleFloat=1;
var
   SampleInteger:integer=256;//Przyk�adowa warto�� ca�kowita
   SampleFloat:double=0.49; //Przyk�adowa warto�� zmiennoprzecinkowa
   SampleString:string='Dzi�kuj� za uwag�';//Przyk�adowy tekst

{Parametry wizualizacji. Przedrostek S od SCREEN}
   SWIDTH:integer=400;    {Szeroko�� obszaru roboczego g��wnego okna}
   SHEIGHT:integer=400;   {Wysoko�� obszaru roboczego g��wnego okna}

type
  TSetupForm = class(TForm)
    OKButton: TButton;
    SetupPagesControl: TPageControl;
    MainTabSheet: TTabSheet;
    VisualTabSheet: TTabSheet;

    SampleSpinEdit: TSpinEdit;
    SampleFloatEdit: TEdit;
    SampleStringEdit: TEdit;

    HeightSpinEdit: TSpinEdit;
    WidthSpinEdit: TSpinEdit;
    Ozdoba: TImage;

    MainWarningLabel: TLabel;
    SampleIntLabel: TLabel;
    SampleFloatLabel: TLabel;
    SampleStringLabel: TLabel;
    HeightLabel: TLabel;
    WidthLabel: TLabel;

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SampleStringEditChange(Sender: TObject);
    procedure HeightSpinEditChange(Sender: TObject);
    procedure WidthSpinEditChange(Sender: TObject);
    
    procedure FormCreate(Sender: TObject);
    procedure SampleSpinEditChange(Sender: TObject);
    procedure SampleFloatEditChange(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ScreenRealW,ScreenRealH:integer;
  end;

var
  SetupForm: TSetupForm;

implementation

{$R *.dfm}
procedure TSetupForm.OKButtonClick(Sender: TObject);
{Jawne zamkni�cie formularza konfiguracyjnego}
begin
self.Close;
end;

procedure TSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
{Akcje kt�re musz� by� podj�te przy ka�dym zamkni�ciu formy w dowolny spos�b}
begin
Algo.ChangeSize(SWIDTH,SHEIGHT);
end;

procedure TSetupForm.FormActivate(Sender: TObject);
begin
 {Odczytanie warto�ci prametr�w, kt�re mog�y zosta� zmienione w kodzie programu}
  {KOD DLA P�L PRZYK�ADOWYCH}
  SampleSpinEdit.MaxValue:=MaxSampleInt;
  SampleSpinEdit.Value:=SampleInteger;
  SampleFloatEdit.Text:=floattostr(SampleFloat);
  SampleStringEdit.Text:=SampleString;

  {TU WSTAW SW�J KOD}
  //............

  {Na wypadek zmiany dokonanej w kodzie}
  if ScreenRealW>SetupFormUnit.SWIDTH then
        WidthSpinEdit.Value:=SWIDTH
        else
        WidthSpinEdit.Value:=WidthSpinEdit.MaxValue;

  if ScreenRealH>SetupFormUnit.SHEIGHT then
        HeightSpinEdit.Value:=SHEIGHT
        else
        HeightSpinEdit.Value:=HeightSpinEdit.MaxValue;
end;

procedure TSetupForm.FormCreate(Sender: TObject);
{Ustawia w formularzu na podstwaie warto�ci zadeklarowanych w kodzie}
{Oraz gwarantuje, �e nie da si� ustawi� okna wi�kszego do ekranu}
var myDC:HDC;
begin
  {Trzeba odczyta� parametry ekranu. GetDC(0) daje uchhwyt do ca�ego pulpitu}
  myDC:=GetDC(0);
  ScreenRealW:=GetDeviceCaps(myDC,HORZRES);
  ScreenRealH:=GetDeviceCaps(myDC,VERTRES);
  ReleaseDC(0,myDC);

  {Dla w�a�ciwej wizualizacji}
  WidthSpinEdit.MaxValue:=ScreenRealW;
  HeightSpinEdit.MaxValue:=ScreenRealH;

  if ScreenRealW>SetupFormUnit.SWIDTH then
        WidthSpinEdit.Value:=SWIDTH
        else
        WidthSpinEdit.Value:=WidthSpinEdit.MaxValue;

  if ScreenRealH>SetupFormUnit.SHEIGHT then
        HeightSpinEdit.Value:=SHEIGHT
        else
        HeightSpinEdit.Value:=HeightSpinEdit.MaxValue;
end;

procedure TSetupForm.SampleFloatEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U�YWA KROPKI JAKO SEPARATORA!
 code:=0;
 try
 pom:=strtofloat( SampleFloatEdit.Text );
 except
 on EConvertError do code:=1
 end;

 if code<>0 then SampleFloatEdit.color:=clRed
    else
    begin
    SampleFloat:=pom;
    SampleFloatEdit.color:=clWhite;
    if SampleFloat<MinSampleFloat then
        begin
        SampleFloat:=MinSampleFloat;
        SampleFloatEdit.color:=clTeal;
        end;
    if SampleFloat>MaxSampleFloat then
        begin
        SampleFloat:=MaxSampleFloat;
        SampleFloatEdit.color:=clYellow;
        end;
    end;
end;

procedure TSetupForm.SampleSpinEditChange(Sender: TObject);
begin
  SampleInteger:=SampleSpinEdit.Value;
end;

procedure TSetupForm.SampleStringEditChange(Sender: TObject);
begin
 SampleString:=SampleStringEdit.Text;
end;

procedure TSetupForm.WidthSpinEditChange(Sender: TObject);
begin
  SWIDTH:=WidthSpinEdit.Value;
end;

procedure TSetupForm.HeightSpinEditChange(Sender: TObject);
begin
  SHEIGHT:=HeightSpinEdit.Value;
end;

end.
