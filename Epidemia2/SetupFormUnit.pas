unit SetupFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, Algo, ExtCtrls;


Const
   MaxLast=2000;  //OK

{Maksymalne i minimalne wartoœci wybranych zmiennych}

   MinERatio=0;  //OK
   MaxERatio=1;  //OK
   MinIntensity=0.001;
   MaxIntensity=1000;

var
   Topology:integer=1;  {Typ sieci: 0-losowa,1-pierscieñ,2-ma³e œwiay,3-lepsze ma³e œwiaty,4-hierarchia}
const {Ró¿ne topologie sieci}
    RandomTopology=0;{Sieæ losowa}
    LinearTopology=1;{Sieæ liniowa}
    ClSWTopology=2;{Klasyczne "Ma³e Œwiaty"}
    ImSWTopology=3;{Ulepszone "Ma³e Œwiaty"}
    FreeScaleTopology=4;{Sieæ bezskalowa}
    HierarchTopology=5;{Sieæ hierarchiczna}
var
   Last:integer=20;    {Ile wezlów}    //OK
   NetParam:integer=0;  {Ile przekierowañ albo poziomów hierarchi}
   ERatio:double=1;  {Ile po³aczeñ istnieje realnie}   //OK
   Weighted:boolean=false;{Czy po³¹czenia wa¿one?}        //OK

   Intensity:double=5; {Last*Intensity - Ile mo¿liwoœci interakcji ka¿dego dnia}
   Duration:integer=7;   {Czas trwania infekcji}
   Immunity:integer=31;  {Czas istnienia odpornoœci}

{Nazwa pliku wyjœciowego}
   OutFileName:string='epidhistory'; {Nazwa pliku wyjœciowego}  //OK

{Parametry wizualizacji. Przedrostek S od SCREEN} //Wszystkie ju¿ s¹!!!
   SWIDTH:integer=590;    {Szerokoœæ obszaru roboczego g³ównego okna}
   SHEIGHT:integer=590;   {Wysokoœæ obszaru roboczego g³ównego okna}
   Radius:integer=6;    {Rozmiar wezla w wizualizacji}
   VisJumps:boolean=false; {Czy wizualizowaæ przeskoki infekcji?}
   DelayTime:integer=100; {Czas dla oka}
   PrintNumbers:boolean=false; {Czy wypisywaæ numeracje wêz³ów}
   Arrangement:byte=3;   {U³o¿enie sieci}
const {Rodzaje u³o¿eñ sieci}
    RandArrangement=0;{U³o¿enie losowe  }
    CircleArrangement=1;{U³o¿enie koliste  }
    LatticeArrangement=2;{U³o¿enie macierzowe       }
    ByConnectArrangement=3;{U³o¿enie wg. liczby po³¹czeñ    }
    FreeModelArrangement=4;{U³o¿enie pozostawione modelowi    }

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
{Jawne zamkniêcie formularza konfiguracyjnego}
begin
self.Close;
end;

procedure TSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
{Akcje które musz¹ byæ podjête przy ka¿dym zamkniêciu formy w dowolny sposób}
begin
Arrangement:=ArrangeComboBox.ItemIndex;
Topology:=TopologyComboBox.ItemIndex;
NetParam:=NetParameterSpinEdit.Value;
VisJumps:=VisJumpsBox.Checked;
Weighted:=WeightedCheckBox.Checked;
PrintNumbers:=NapisyCheckBox.Checked;
{Uktoalizacja rozmiarów ekranu}
Algo.ChangeSize(SWIDTH,SHEIGHT);
end;

procedure TSetupForm.FormActivate(Sender: TObject);
begin
 {Odczytanie wartoœci prametrów, które mog³y zostaæ zmienione w kodzie programu}
  {TU WSTAW SWÓJ KOD}
  LastSpinEdit.MinValue:=2; //Mniej ni¿ dwa nie ma sensu
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

  {Na wypadek zmiany rozmiarów ekranu dokonanej w kodzie}
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


procedure TSetupForm.EdgeProgEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U¯YWA KROPKI JAKO SEPARATORA!

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
 // Val(ProbEdit.Text,pom,code); ZAWSZE U¯YWA KROPKI JAKO SEPARATORA!

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
LinearTopology:{Pierœcieniowa}
  begin
  TopologyComboBox.Hint:='Dla sieci pierœcieniowej dodatkowy parametr jest ignorowany';
  TopologyLabel.Caption:='--ignorowane--';
  //EdgeProgEdit.Text:='1';
  end;
ClSWTopology:{Klasyczne ma³e œwiaty}
  begin
  TopologyComboBox.Hint:='Parametr oznacza liczbê przekierowanych po³¹czeñ';
  TopologyLabel.Caption:='liczba zmienionych po³¹czeñ';
  if NetParameterSpinEdit.Value=0 then
    NetParameterSpinEdit.Value:=1;
  //EdgeProgEdit.Text:='1';
  end;
ImSWTopology:{Ulepszone ma³e œwiaty}
  begin
  TopologyComboBox.Hint:='Parametr oznacza liczbê dodatkowych po³¹czeñ';
  TopologyLabel.Caption:='liczba dodatkowych po³¹czeñ';
  if NetParameterSpinEdit.Value=0 then
    NetParameterSpinEdit.Value:=1;
  //EdgeProgEdit.Text:='1';
  end;
FreeScaleTopology:{Sieæ bezscalowa}
  begin
  TopologyComboBox.Hint:='Parametr oznacza pocz¹tkow¹ liczbê po³¹czonych wêz³ów';
  TopologyLabel.Caption:='Inicjalna liczba wêz³ów';
  if NetParameterSpinEdit.Value<2 then
    NetParameterSpinEdit.Value:=2;
  //EdgeProgEdit.Text:='1';
  end;
HierarchTopology:{Hierarchiczna}
  begin
  TopologyComboBox.Hint:='Parametr oznacza liczbê poziomów hierarchi';
  TopologyLabel.Caption:='liczba poziomów hierarchi';
  if NetParameterSpinEdit.Value<2 then
    NetParameterSpinEdit.Value:=3;
  //EdgeProgEdit.Text:='1';
  end;
else
  begin
    Application.MessageBox('Przywracam 0 - sieæ losow¹.','Nieodpowiedni indeks topologii sieci. ');
    TopologyComboBox.Hint:='Dla sieci losowej dodatkowy parametr jest ignorowany';
    TopologyLabel.Caption:='--ignorowane--';
    TopologyComboBox.ItemIndex:=0;
    EdgeProgEdit.Text:=floattostr(0.25);
  end;
end;
Topology:= TopologyComboBox.ItemIndex;
end;

end.
