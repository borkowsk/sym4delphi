unit SetupFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, Algo, ExtCtrls;


Const
   MaxLast=2000;  //OK

{Maksymalne i minimalne warto�ci wybranych zmiennych}

   MinERatio=0;  //OK
   MaxERatio=1;  //OK
   MinIntensity=0.001;
   MaxIntensity=1000;

var
   Topology:integer=1;  {Typ sieci: 0-losowa,1-pierscie�,2-ma�e �wiay,3-lepsze ma�e �wiaty,4-hierarchia}
const {R�ne topologie sieci}
    RandomTopology=0;{Sie� losowa}
    LinearTopology=1;{Sie� liniowa}
    ClSWTopology=2;{Klasyczne "Ma�e �wiaty"}
    ImSWTopology=3;{Ulepszone "Ma�e �wiaty"}
    FreeScaleTopology=4;{Sie� bezskalowa}
    HierarchTopology=5;{Sie� hierarchiczna}
var
   Last:integer=20;    {Ile wezl�w}    //OK
   NetParam:integer=0;  {Ile przekierowa� albo poziom�w hierarchi}
   ERatio:double=1;  {Ile po�acze� istnieje realnie}   //OK
   Weighted:boolean=false;{Czy po��czenia wa�one?}        //OK

   Intensity:double=5; {Last*Intensity - Ile mo�liwo�ci interakcji ka�dego dnia}
   Duration:integer=7;   {Czas trwania infekcji}
   Immunity:integer=31;  {Czas istnienia odporno�ci}

{Nazwa pliku wyj�ciowego}
   OutFileName:string='epidhistory'; {Nazwa pliku wyj�ciowego}  //OK

{Parametry wizualizacji. Przedrostek S od SCREEN} //Wszystkie ju� s�!!!
   SWIDTH:integer=590;    {Szeroko�� obszaru roboczego g��wnego okna}
   SHEIGHT:integer=590;   {Wysoko�� obszaru roboczego g��wnego okna}
   Radius:integer=6;    {Rozmiar wezla w wizualizacji}
   VisJumps:boolean=false; {Czy wizualizowa� przeskoki infekcji?}
   DelayTime:integer=100; {Czas dla oka}
   PrintNumbers:boolean=false; {Czy wypisywa� numeracje w�z��w}
   Arrangement:byte=3;   {U�o�enie sieci}
const {Rodzaje u�o�e� sieci}
    RandArrangement=0;{U�o�enie losowe  }
    CircleArrangement=1;{U�o�enie koliste  }
    LatticeArrangement=2;{U�o�enie macierzowe       }
    ByConnectArrangement=3;{U�o�enie wg. liczby po��cze�    }
    FreeModelArrangement=4;{U�o�enie pozostawione modelowi    }

type
  TSetupForm = class(TForm)
    OKButton: TButton;
    SetupPagesControl: TPageControl;
    MainTabSheet: TTabSheet;
    VisualTabSheet: TTabSheet;
    WlasciwosciEpidemiGroupBox: TGroupBox;
    WlasciwosciSieciGroupBox: TGroupBox;

    OutFileStringEdit: TEdit;

    HeightSpinEdit: TSpinEdit;
    WidthSpinEdit: TSpinEdit;
    NapisyCheckBox: TCheckBox;

    MainWarningLabel: TLabel;
    SampleStringLabel: TLabel;
    HeightLabel: TLabel;
    WidthLabel: TLabel;

    NodeRadius: TSpinEdit;
    Label1: TLabel;

    LastSpinEdit: TSpinEdit;
    EdgeProgEdit: TEdit;
    SampleIntLabel: TLabel;
    SampleFloatLabel: TLabel;
    WeightedCheckBox: TCheckBox;
    Ozdoba: TImage;
    TopologyComboBox: TComboBox;
    Label3: TLabel;
    VisJumpsBox: TCheckBox;
    IntensityEdit: TEdit;
    Label2: TLabel;
    DurationSpinEdit: TSpinEdit;
    ImmunitySpinEdit: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    NetParameterSpinEdit: TSpinEdit;
    TopologyLabel: TLabel;
    DelaySpinEdit: TSpinEdit;
    Label6: TLabel;
    ArrangeComboBox: TComboBox;
    procedure DelaySpinEditChange(Sender: TObject);
    procedure TopologyComboBoxChange(Sender: TObject);
    procedure NetParameterSpinEditChange(Sender: TObject);
    procedure ImmunitySpinEditChange(Sender: TObject);
    procedure DurationSpinEditChange(Sender: TObject);

    procedure IntensityEditChange(Sender: TObject);
    procedure WeightedCheckBoxClick(Sender: TObject);
    procedure NodeRadiusChange(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OutFIleStringEditChange(Sender: TObject);
    procedure HeightSpinEditChange(Sender: TObject);
    procedure WidthSpinEditChange(Sender: TObject);
    
    procedure FormCreate(Sender: TObject);
    procedure LastSpinEditChange(Sender: TObject);
    procedure EdgeProgEditChange(Sender: TObject);
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
Arrangement:=ArrangeComboBox.ItemIndex;
Topology:=TopologyComboBox.ItemIndex;
NetParam:=NetParameterSpinEdit.Value;
VisJumps:=VisJumpsBox.Checked;
Weighted:=WeightedCheckBox.Checked;
PrintNumbers:=NapisyCheckBox.Checked;
{Uktoalizacja rozmiar�w ekranu}
Algo.ChangeSize(SWIDTH,SHEIGHT);
end;

procedure TSetupForm.FormActivate(Sender: TObject);
begin
 {Odczytanie warto�ci prametr�w, kt�re mog�y zosta� zmienione w kodzie programu}
  {TU WSTAW SW�J KOD}
  LastSpinEdit.MinValue:=2; //Mniej ni� dwa nie ma sensu
  LastSpinEdit.MaxValue:=MaxLast;
  LastSpinEdit.Value:=Last;

  EdgeProgEdit.Text:=floattostr(ERatio);
  OutFileStringEdit.Text:=OutFileName;
  ArrangeComboBox.ItemIndex:=Arrangement;
  NodeRadius.Value:=Radius;
  WeightedCheckBox.Checked:=Weighted;
  VisJumpsBox.Checked:=VisJumps;
  NapisyCheckBox.Checked:=PrintNumbers;
  IntensityEdit.Text:=floattostr(Intensity);
  DurationSpinEdit.Value:=Duration;
  ImmunitySpinEdit.Value:=Immunity;
  NetParameterSpinEdit.Value:=NetParam;
  TopologyComboBox.ItemIndex:=Topology;
  TopologyComboBoxChange(Sender);

  {Na wypadek zmiany rozmiar�w ekranu dokonanej w kodzie}
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


procedure TSetupForm.EdgeProgEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U�YWA KROPKI JAKO SEPARATORA!

 code:=0;
 try
 pom:=strtofloat( EdgeProgEdit.Text );
 except
 on EConvertError do begin code:=1; pom:=0 end
 end;

 if code<>0 then EdgeProgEdit.color:=clRed
    else
    begin
    ERatio:=pom;
    EdgeProgEdit.color:=clWhite;
    if ERatio<MinERatio then
        begin
        ERatio:=MinERatio;
        EdgeProgEdit.color:=clTeal;
        end;
    if ERatio>MaxERatio then
        begin
        ERatio:=MaxERatio;
        EdgeProgEdit.color:=clYellow;
        end;
    end;
end;

procedure TSetupForm.IntensityEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U�YWA KROPKI JAKO SEPARATORA!

 code:=0;
 try
 pom:=strtofloat( IntensityEdit.Text );
 except
 on EConvertError do begin code:=1; pom:=0 end
 end;

 if code<>0 then IntensityEdit.color:=clRed
    else
    begin
    Intensity:=pom;
    IntensityEdit.color:=clWhite;
    if Intensity<MinIntensity then
        begin
        Intensity:=MinIntensity;
        IntensityEdit.color:=clTeal;
        end;
    if Intensity>MaxIntensity then
        begin
        Intensity:=MaxIntensity;
        IntensityEdit.color:=clYellow;
        end;
    end;
end;

procedure TSetupForm.LastSpinEditChange(Sender: TObject);
begin
  Last:=LastSpinEdit.Value;
end;

procedure TSetupForm.DelaySpinEditChange(Sender: TObject);
begin
  DelayTime:=DelaySpinEdit.value;
end;

procedure TSetupForm.DurationSpinEditChange(Sender: TObject);
begin
  Duration:=DurationSpinEdit.Value;
end;

procedure TSetupForm.ImmunitySpinEditChange(Sender: TObject);
begin
   Immunity:=ImmunitySpinEdit.Value;
end;

procedure TSetupForm.NetParameterSpinEditChange(Sender: TObject);
begin
  NetParam:=NetParameterSpinEdit.Value;
end;

procedure TSetupForm.NodeRadiusChange(Sender: TObject);
begin
  Radius:=NodeRadius.Value;
end;

procedure TSetupForm.OutFIleStringEditChange(Sender: TObject);
begin
 OutFileName:=OutFIleStringEdit.Text;
end;

procedure TSetupForm.WeightedCheckBoxClick(Sender: TObject);
begin
  Weighted:=WeightedCheckBox.Checked;
end;

procedure TSetupForm.WidthSpinEditChange(Sender: TObject);
begin
  SWIDTH:=WidthSpinEdit.Value;
end;

procedure TSetupForm.HeightSpinEditChange(Sender: TObject);
begin
  SHEIGHT:=HeightSpinEdit.Value;
end;

procedure TSetupForm.TopologyComboBoxChange(Sender: TObject);
begin
case TopologyComboBox.ItemIndex of
RandomTopology:{Losowa}
  begin
  TopologyComboBox.Hint:='Dla sieci losowej dodatkowy parametr jest ignorowany';
  TopologyLabel.Caption:='--ignorowane--';
  EdgeProgEdit.Text:=floattostr(0.25);
  end;
LinearTopology:{Pier�cieniowa}
  begin
  TopologyComboBox.Hint:='Dla sieci pier�cieniowej dodatkowy parametr jest ignorowany';
  TopologyLabel.Caption:='--ignorowane--';
  //EdgeProgEdit.Text:='1';
  end;
ClSWTopology:{Klasyczne ma�e �wiaty}
  begin
  TopologyComboBox.Hint:='Parametr oznacza liczb� przekierowanych po��cze�';
  TopologyLabel.Caption:='liczba zmienionych po��cze�';
  if NetParameterSpinEdit.Value=0 then
    NetParameterSpinEdit.Value:=1;
  //EdgeProgEdit.Text:='1';
  end;
ImSWTopology:{Ulepszone ma�e �wiaty}
  begin
  TopologyComboBox.Hint:='Parametr oznacza liczb� dodatkowych po��cze�';
  TopologyLabel.Caption:='liczba dodatkowych po��cze�';
  if NetParameterSpinEdit.Value=0 then
    NetParameterSpinEdit.Value:=1;
  //EdgeProgEdit.Text:='1';
  end;
FreeScaleTopology:{Sie� bezscalowa}
  begin
  TopologyComboBox.Hint:='Parametr oznacza pocz�tkow� liczb� po��czonych w�z��w';
  TopologyLabel.Caption:='Inicjalna liczba w�z��w';
  if NetParameterSpinEdit.Value<2 then
    NetParameterSpinEdit.Value:=2;
  //EdgeProgEdit.Text:='1';
  end;
HierarchTopology:{Hierarchiczna}
  begin
  TopologyComboBox.Hint:='Parametr oznacza liczb� poziom�w hierarchi';
  TopologyLabel.Caption:='liczba poziom�w hierarchi';
  if NetParameterSpinEdit.Value<2 then
    NetParameterSpinEdit.Value:=3;
  //EdgeProgEdit.Text:='1';
  end;
else
  begin
    Application.MessageBox('Przywracam 0 - sie� losow�.','Nieodpowiedni indeks topologii sieci. ');
    TopologyComboBox.Hint:='Dla sieci losowej dodatkowy parametr jest ignorowany';
    TopologyLabel.Caption:='--ignorowane--';
    TopologyComboBox.ItemIndex:=0;
    EdgeProgEdit.Text:=floattostr(0.25);
  end;
end;
Topology:= TopologyComboBox.ItemIndex;
end;

end.
