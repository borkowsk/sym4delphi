unit SetupFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, Algo, ExtCtrls;

const
{Maksymalna i u¿yta d³ugoœæ boku œwiata}
   MaxBok=500;
var
   Bok:integer=300;//Bok obszaru roboczego
   Prob:double=0.49; //Prawdopodobienstwo kolorowego
   Dziek:string='Thank you for attention!';//treœæ podziekowania

{Parametry wizualizacji. Przedrostek S od SCREEN}
   SWIDTH:integer=500;    {Szerokoœæ obszaru roboczego g³ównego okna}
   SHEIGHT:integer=500;   {Wysokoœæ obszaru roboczego g³ównego okna}

type
  TSetupForm = class(TForm)
    OKButton: TButton;
    SetupPagesControl: TPageControl;
    MainTabSheet: TTabSheet;
    VisualTabSheet: TTabSheet;

    SideSpinEdit: TSpinEdit;
    ProbEdit: TEdit;
    HeightSpinEdit: TSpinEdit;
    WidthSpinEdit: TSpinEdit;
    MainWarningLabel: TLabel;

    SideLabel: TLabel;
    ProbLabel: TLabel;
    HeightLabel: TLabel;
    WidthLabel: TLabel;
    ThankTextEdit: TEdit;
    ThankLabel: TLabel;
    Ozdoba: TImage;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ThankTextEditChange(Sender: TObject);
    procedure HeightSpinEditChange(Sender: TObject);
    procedure WidthSpinEditChange(Sender: TObject);
    
    procedure FormCreate(Sender: TObject);
    procedure SideSpinEditChange(Sender: TObject);
    procedure ProbEditChange(Sender: TObject);
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
{Jawne zamkniêcie formularza konfiguracyjnego}
begin
self.Close;
end;

procedure TSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
{Akcje które musz¹ byæ podjête przy ka¿dym zamkniêciu formy w dowolny sposób}
begin
Algo.ChangeSize(SWIDTH,SHEIGHT);
end;

procedure TSetupForm.FormActivate(Sender: TObject);
begin
 {Odczytanie wartoœci prametrów, które mog³y zostaæ zmienione w kodzie programu}
  {KOD DLA PÓL PRZYK£ADOWYCH}
  SideSpinEdit.MaxValue:=MaxBok;
  SideSpinEdit.Value:=Bok;
  ProbEdit.Text:=floattostr(Prob);
  ThankTextEdit.Text:=Dziek;

  {TU WSTAW SWÓJ KOD}
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
{Ustawia w formularzu na podstwaie wartoœci zadeklarowanych w kodzie}
{Oraz gwarantuje, ¿e nie da siê ustawiæ okna wiêkszego do ekranu}
var myDC:HDC;
begin
  {Trzeba odczytaæ parametry ekranu. GetDC(0) daje uchhwyt do ca³ego pulpitu}
  myDC:=GetDC(0);
  ScreenRealW:=GetDeviceCaps(myDC,HORZRES);
  ScreenRealH:=GetDeviceCaps(myDC,VERTRES);
  ReleaseDC(0,myDC);

  {Dla w³aœciwej wizualizacji}
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

procedure TSetupForm.ProbEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U¯YWA KROPKI JAKO SEPARATORA!
 code:=0;
 try
 pom:=strtofloat( ProbEdit.Text );
 except
 on EConvertError do code:=1
 end;

 if code<>0 then ProbEdit.color:=clRed
    else
    begin
    Prob:=pom;
    ProbEdit.color:=clWhite;
    if Prob<0 then
        begin
        Prob:=0;
        ProbEdit.color:=clTeal;
        end;
    if Prob>1 then
        begin
        Prob:=1;
        ProbEdit.color:=clYellow;
        end;
    end;
end;

procedure TSetupForm.SideSpinEditChange(Sender: TObject);
begin
  Bok:=SideSpinEdit.Value;
end;

procedure TSetupForm.ThankTextEditChange(Sender: TObject);
begin
 Dziek:=ThankTextEdit.Text;
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
