Program Dodawanie_jedynki;
{$REALCOMPATIBILITY ON}
//TEN PROGRAM W DELPHI BEDZIE SIÊ WYKONYWA£:
var R,Poprzednia:single; {KRÓTKO bo 4 bajtowe}
//var R,Poprzednia:real; {BARDZO D£UGO bo 6 bajtów dzia³a programowo}
//var R,Poprzednia:double; {BARDZO D£UGO bo 8 bajtów}
begin
Poprzednia:=0;
R:=1;
writeln('Zaczynamy R=1 "size of R"=',sizeof(R));
while R<>Poprzednia do
  begin
  Poprzednia:=R;
  R:=R+1;
  end;
writeln(R);  
writeln('Dalej sie nie da...')  
end.
