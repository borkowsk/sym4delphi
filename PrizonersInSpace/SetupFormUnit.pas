unit SetupFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, Algo, ExtCtrls;                                            

const
{Maksymalne i minimalne wartoœci wybranych zmiennych}
   MaxBok=500;  //Maksymalny rozmiar tablicy œwiata
   MaxIlePostaw=21;//Ile maksymalnie postaw rozwa¿amy - taka tablica liczników
   LastHist=100; //Maksymalny rozmiar tablicy histogramu stresu
   HistSize=9;   //Faktyczny rozmiar histogramu stresu

   MinPoziomSzumu=0;
   MaxPoziomSzumu=0.15;
   MinZaludnienie=0;
   MaxZaludnienie=1;

var
   {Ogólne parametry modelu - gdy zyski ze wspolpracy male, wplyw ma decydujace znaczenie!}
   Bok:integer=50;   {Dlugoœæ boku œwiata}
   IlePostaw:integer=2; {Liczba mo¿liwych pogladów 2-->}
   Zaludnienie:double=0.5; {Zaludnienie 0..1}
   MaxSila:integer=10000;{Najwieksza sila }
   Rozklad:integer=7;   {Stopien rozk³adu "Pareto" >=0 - zero daje brak rozkladu, same MaxSila. Max: 12}

   {Specyficzne parametry modelu}
   KosztKroku:integer=5;
   OptimumZapasu:integer=50;
   TabelaWyp:array[0..1,0..1] of integer=((6,12),(-12,-6));
   UzyjWplywuDlaPostaw:boolean=false;
   StresZageszczenia:boolean=false;


   PoziomSzumu:double=0; {Szum czyli losowe "mutacje" pogl¹dów - 0..1 bo to prawdopodobieñstwo, ale ¿ó³te ju¿ pow 0.05}
   FileNameCore:string='priz';{np. rdzeñ nazwy pliku }

   {Wizualizacyjne}
   Rozmiar:integer=15;  {D³ugoœæ boku najsiliejszego agenta}
   NajmRoz:integer=2; {Jaki rozmiar wizualizacyjny maj¹ najslabsi agenci w populacji}
   Brzeg:integer=0;  {Obwodka wokó³ agenta}

   CzestoscWizualizacji:integer=1; //Co ile kroków Monte Carlo odrysowawywaæ
   Chwila:integer=10; {Ile milisekund dla oka po wizualizacji}
   MaxKrok:integer=10000;   //Ile maksymalnie kroków w eksperymencie

{Obowi¹zkowe parametry wizualizacji. Przedrostek S od SCREEN}
   SWIDTH:integer=780;    {Szerokoœæ obszaru roboczego g³ównego okna}
   SHEIGHT:integer=800;   {Wysokoœæ obszaru roboczego g³ównego okna}

type
  TSetupForm = class(TForm)
    OKButton: TButton;
    SetupPagesControl: TPageControl;
    MainTabSheet: TTabSheet;
    VisualTabSheet: TTabSheet;
    RdzenStringEdit: TEdit;

    HeightSpinEdit: TSpinEdit;
    WidthSpinEdit: TSpinEdit;
    Ozdoba: TImage;

    MainWarningLabel: TLabel;
    RdzenStringLabel: TLabel;
    HeightLabel: TLabel;
    WidthLabel: TLabel;
    GroupBox1: TGroupBox;
    DlBokuSpinEdit: TSpinEdit;
    DlBokuIntLabel: TLabel;
    ZaludnienieFloatEdit: TEdit;
    ProbaFloatLabel: TLabel;
    IlePostawSpinEdit1: TSpinEdit;
    Label1: TLabel;
    MaxSilaSpinEdit1: TSpinEdit;
    Label2: TLabel;
    SideSpinEdit1: TSpinEdit;
    VisfreqSpinEdit2: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    RozkladSpinEdit: TSpinEdit;
    Label5: TLabel;
    PoziomSzumuEdit: TEdit;
    Label6: TLabel;
    SlabyAgentSpinEdit1: TSpinEdit;
    Label7: TLabel;
    BrzegSpinEdit1: TSpinEdit;
    Label8: TLabel;
    ChwilaSpinEdit2: TSpinEdit;
    MaxKrokSpinEdit3: TSpinEdit;
    Label9: TLabel;
    Label10: TLabel;
    KosztKrokuSpinEdit: TSpinEdit;
    Label11: TLabel;
    OptimumZapasuSpinEdit: TSpinEdit;
    Label12: TLabel;
    TabelaWyplatBox: TGroupBox;
    WyplataSpinEdit00: TSpinEdit;
    WyplataSpinEdit10: TSpinEdit;
    WyplataSpinEdit01: TSpinEdit;
    WyplataSpinEdit11: TSpinEdit;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    UzyjWplywuDlaPostawCheckBox: TCheckBox;
    StresZageszczeniaCheckBox: TCheckBox;
    procedure MaxKrokSpinEdit3Change(Sender: TObject);
    procedure ChwilaSpinEdit2Change(Sender: TObject);
    procedure BrzegSpinEdit1Change(Sender: TObject);
    procedure SlabyAgentSpinEdit1Change(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RdzenStringEditChange(Sender: TObject);
    procedure HeightSpinEditChange(Sender: TObject);
    procedure WidthSpinEditChange(Sender: TObject);
    procedure IlePostawSpinEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DlBokuSpinEditChange(Sender: TObject);
    procedure ZaludnienieFloatEditChange(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);

    procedure MaxSilaSpinEdit1Change(Sender: TObject);
    procedure SideSpinEdit1Change(Sender: TObject);
    procedure VisfreqSpinEdit2Change(Sender: TObject);
    procedure RozkladSpinEditChange(Sender: TObject);
    procedure PoziomSzumuEditChange(Sender: TObject);
    procedure KosztKrokuSpinEditChange(Sender: TObject);
    procedure OptimumZapasuSpinEditChange(Sender: TObject);
    procedure WyplataSpinEdit00Change(Sender: TObject);
    procedure WyplataSpinEdit11Change(Sender: TObject);
    procedure WyplataSpinEdit01Change(Sender: TObject);
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

procedure TSetupForm.FormActivate(Sender: TObject);
begin
 {Odczytanie wartoœci prametrów, które mog³y zostaæ zmienione w kodzie programu}
  {TU WSTAW SWÓJ KOD ODCZYTUJ¥CY}
  //............

  {KOD DLA PÓL PRZYK£ADOWYCH}
  DlBokuSpinEdit.MaxValue:=MaxBok;//Dla wartosci MAXymalnej!!!

  DlBokuSpinEdit.Value:=Bok;
  IlePostawSpinEdit1.Value:=IlePostaw;
  ZaludnienieFloatEdit.Text:=floattostr(Zaludnienie); //wartoœæ aktualna
  MaxSilaSpinEdit1.Value:=MaxSila; //i wartoœæ aktualna
  RozkladSpinEdit.Value :=Rozklad;
  PoziomSzumuEdit.Text:= floattostr(PoziomSzumu);
  RdzenStringEdit.Text:=FileNameCore;

  SideSpinEdit1.Value:=Rozmiar;  //D³ugoœæ boku agenta    min 3
  SlabyAgentSpinEdit1.Value:=NajmRoz;
  BrzegSpinEdit1.Value:=Brzeg;

  VisfreqSpinEdit2.Value:=CzestoscWizualizacji; //Co ile kroków Monte Carlo odrysowawywaæ
  ChwilaSpinEdit2.Value:=Chwila;
  MaxKrokSpinEdit3.Value:=MaxKrok;

  KosztKrokuSpinEdit.Value:=KosztKroku;
  OptimumZapasuSpinEdit.Value:=OptimumZapasu;
  WyplataSpinEdit00.Value:=TabelaWyp[0,0];
  WyplataSpinEdit01.Value:=TabelaWyp[0,1];
  WyplataSpinEdit10.Value:=TabelaWyp[1,0];
  WyplataSpinEdit11.Value:=TabelaWyp[1,1];
  UzyjWplywuDlaPostawCheckBox.Checked:=UzyjWplywuDlaPostaw;
  StresZageszczeniaCheckBox.Checked:=StresZageszczenia;

  {Na wypadek zmiany rozmiarów dokonanej w kodzie}
  if ScreenRealW>SetupFormUnit.SWIDTH then
        WidthSpinEdit.Value:=SWIDTH
        else
        WidthSpinEdit.Value:=WidthSpinEdit.MaxValue;

  if ScreenRealH>SetupFormUnit.SHEIGHT then
        HeightSpinEdit.Value:=SHEIGHT
        else
        HeightSpinEdit.Value:=HeightSpinEdit.MaxValue;
end;

procedure TSetupForm.OKButtonClick(Sender: TObject);
{Jawne zamkniêcie formularza konfiguracyjnego}
begin
self.Close;
end;

procedure TSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
{Akcje które musz¹ byæ podjête przy ka¿dym zamkniêciu formy w dowolny sposób}
begin
Algo.ChangeSize(SWIDTH,SHEIGHT);
UzyjWplywuDlaPostaw:=UzyjWplywuDlaPostawCheckBox.Checked;
StresZageszczenia:=StresZageszczeniaCheckBox.Checked;
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

procedure TSetupForm.ZaludnienieFloatEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U¯YWA KROPKI JAKO SEPARATORA!
 code:=0;
 try
 pom:=strtofloat( ZaludnienieFloatEdit.Text );
 except
 on EConvertError do begin code:=1;pom:=0 end;
 end;

 if code<>0 then ZaludnienieFloatEdit.color:=clRed
    else
    begin
    Zaludnienie:=pom;
    ZaludnienieFloatEdit.color:=clWhite;
    if Zaludnienie<MinZaludnienie then
        begin
        Zaludnienie:=MinZaludnienie;
        ZaludnienieFloatEdit.color:=clTeal;
        end;
    if Zaludnienie>MaxZaludnienie then
        begin
        Zaludnienie:=MaxZaludnienie;
        ZaludnienieFloatEdit.color:=clYellow;
        end;
    end;
end;

procedure TSetupForm.BrzegSpinEdit1Change(Sender: TObject);
begin
 Brzeg:=BrzegSpinEdit1.Value;
end;

procedure TSetupForm.ChwilaSpinEdit2Change(Sender: TObject);
begin
 Chwila:=ChwilaSpinEdit2.Value;
end;

procedure TSetupForm.DlBokuSpinEditChange(Sender: TObject);
begin
  Bok:=DlBokuSpinEdit.Value;
end;

procedure TSetupForm.RdzenStringEditChange(Sender: TObject);
begin
 FileNameCore:=RdzenStringEdit.Text;
end;

procedure TSetupForm.WidthSpinEditChange(Sender: TObject);
begin
  SWIDTH:=WidthSpinEdit.Value;
end;

procedure TSetupForm.HeightSpinEditChange(Sender: TObject);
begin
 SHEIGHT:=HeightSpinEdit.Value;
end;

procedure TSetupForm.IlePostawSpinEdit1Change(Sender: TObject);
begin
 IlePostaw:=IlePostawSpinEdit1.Value
end;

procedure TSetupForm.MaxKrokSpinEdit3Change(Sender: TObject);
begin
 MaxKrok:=MaxKrokSpinEdit3.Value;
end;

procedure TSetupForm.MaxSilaSpinEdit1Change(Sender: TObject);
begin
 MaxSila:=MaxSilaSpinEdit1.Value
end;


procedure TSetupForm.SideSpinEdit1Change(Sender: TObject);
begin
 Rozmiar:=SideSpinEdit1.Value
end;

procedure TSetupForm.SlabyAgentSpinEdit1Change(Sender: TObject);
begin
 NajmRoz:=SlabyAgentSpinEdit1.Value;
end;

procedure TSetupForm.VisfreqSpinEdit2Change(Sender: TObject);
begin
 CzestoscWizualizacji:=VisfreqSpinEdit2.Value
end;


procedure TSetupForm.RozkladSpinEditChange(Sender: TObject);
begin
Rozklad:=RozkladSpinEdit.Value
end;

procedure TSetupForm.PoziomSzumuEditChange(Sender: TObject);
var pom:double;
    code:integer;
begin
 // Val(ProbEdit.Text,pom,code); ZAWSZE U¯YWA KROPKI JAKO SEPARATORA!
 code:=0;
 try
 pom:=strtofloat( PoziomSzumuEdit.Text );
 except
 on EConvertError do begin code:=1;pom:=0 end;
 end;

 if code<>0 then PoziomSzumuEdit.color:=clRed
    else
    begin
    PoziomSzumu:=pom;
    PoziomSzumuEdit.color:=clWhite;
    if PoziomSzumu<MinPoziomSzumu then
        begin
        PoziomSzumu:=MinPoziomSzumu;
        PoziomSzumuEdit.color:=clTeal;
        end;
    if PoziomSzumu>MaxPoziomSzumu then
        begin
        PoziomSzumu:=MaxPoziomSzumu;
        PoziomSzumuEdit.color:=clYellow;
        end;
    end;

end;

procedure TSetupForm.WyplataSpinEdit00Change(Sender: TObject);
begin
 TabelaWyp[0,0]:=WyplataSpinEdit00.Value;
end;

procedure TSetupForm.WyplataSpinEdit11Change(Sender: TObject);
begin
 TabelaWyp[1,1]:=WyplataSpinEdit11.Value;
end;

procedure TSetupForm.WyplataSpinEdit01Change(Sender: TObject);
begin
 WyplataSpinEdit10.Value:=-WyplataSpinEdit01.Value;
 TabelaWyp[0,1]:=WyplataSpinEdit01.Value;
 TabelaWyp[1,0]:=WyplataSpinEdit10.Value;
end;

procedure TSetupForm.KosztKrokuSpinEditChange(Sender: TObject);
begin
  KosztKroku:=KosztKrokuSpinEdit.Value;
end;

procedure TSetupForm.OptimumZapasuSpinEditChange(Sender: TObject);
begin
  OptimumZapasu:=OptimumZapasuSpinEdit.Value;
end;

end.
