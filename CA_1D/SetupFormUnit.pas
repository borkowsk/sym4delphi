unit SetupFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, Algo,  ExtCtrls;

const
{Maksymalne i monimalene warto�ci wybranych zmiennych}
   MaxLast=1001;
   MinProb0=0;
   MaxProb0=1;
   stat_offset=25; {O ile odsun�� wypisywanie statystyki}

var
   Last:integer=251;//Uzywany rozmiar tablicy - Musi byc wi�ksze ni� 1 i nieparzyste
   Steps:integer=750;//Ile krok�w mo�na wykona�
   Prob0:double=0.5; //Przyk�adowa warto�� zmiennoprzecinkowa
   OutFileName:string='CA1Dout';
   SaveStates:boolean=true;//Czy zapisywac stan automatu?

{Parametry wizualizacji. Przedrostek S od SCREEN}
   SWIDTH:integer=400;    {Szeroko�� obszaru roboczego g��wnego okna}
   SHEIGHT:integer=400;   {Wysoko�� obszaru roboczego g��wnego okna}

type
  TSetupForm = class(TForm)
    OKButton: TButton;
    SetupPagesControl: TPageControl;
    MainTabSheet: TTabSheet;
    VisualTabSheet: TTabSheet;

    LastSpinEdit: TSpinEdit;
    Prob0Edit: TEdit;
    FileNameEdit: TEdit;

    HeightSpinEdit: TSpinEdit;
    WidthSpinEdit: TSpinEdit;
    Ozdoba: TImage;

    MainWarningLabel: TLabel;
    LastLabel: TLabel;
    Prob0Label: TLabel;
    NameLabel: TLabel;
    HeightLabel: TLabel;
    WidthLabel: TLabel;
    StepsSpinEdit: TSpinEdit;
    StepsLabel: TLabel;
    procedure StepsSpinEditChange(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FileNameEditChange(Sender: TObject);
    procedure HeightSpinEditChange(Sender: TObject);
    procedure WidthSpinEditChange(Sender: TObject);
    
    procedure FormCreate(Sender: TObject);
    procedure LastSpinEditChange(Sender: TObject);
    procedure Prob0EditChange(Sender: TObject);
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
  StepsSpinEdit.MaxValue:=ScreenRealH;
  LastSpinEdit.MaxValue:=MaxLast;

  LastSpinEdit.Value:=Last;
  StepsSpinEdit.Value:=Steps;
  Prob0Edit.Text:=floattostr(Prob0);
  FileNameEdit.Text:=OutFileName;

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
  SWIDTH:=Last+60;
  if SWIDTH<400 then
       SWIDTH:=400;
  SHEIGHT:=Steps+3*stat_offset;

  if ScreenRealW>SetupFormUnit.SWIDTH then
        WidthSpinEdit.Value:=SWIDTH
        else
        WidthSpinEdit.Value:=WidthSpinEdit.MaxValue;

  if ScreenRealH>SetupFormUnit.SHEIGHT then
        HeightSpinEdit.Value:=SHEIGHT
        else
        HeightSpinEdit.Value:=HeightSpinEdit.MaxValue;
end;

procedure TSetupForm.Prob0EditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U�YWA KROPKI JAKO SEPARATORA!
 code:=0;
 try
 pom:=strtofloat( Prob0Edit.Text );
 except
 on EConvertError do code:=1
 end;

 if code<>0 then Prob0Edit.color:=clRed
    else
    begin
    Prob0:=pom;
    Prob0Edit.color:=clWhite;
    if Prob0<MinProb0 then
        begin
        Prob0:=MinProb0;
        Prob0Edit.color:=clTeal;
        end;
    if Prob0>MaxProb0 then
        begin
        Prob0:=MaxProb0;
        Prob0Edit.color:=clYellow;
        end;
    end;
end;

procedure TSetupForm.StepsSpinEditChange(Sender: TObject);
begin
 Steps:=StepsSpinEdit.Value;
end;

procedure TSetupForm.LastSpinEditChange(Sender: TObject);
begin
 Last:=LastSpinEdit.Value;
end;

procedure TSetupForm.FileNameEditChange(Sender: TObject);
begin
 OutFileName:=FileNameEdit.Text;
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
