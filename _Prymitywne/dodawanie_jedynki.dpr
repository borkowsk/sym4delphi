Program Dodawanie_jedynki;
{$REALCOMPATIBILITY ON}
//TEN PROGRAM W DELPHI BEDZIE SI� WYKONYWA�:
var R,Poprzednia:single; {KR�TKO bo 4 bajtowe}
//var R,Poprzednia:real; {BARDZO D�UGO bo 6 bajt�w dzia�a programowo}
//var R,Poprzednia:double; {BARDZO D�UGO bo 8 bajt�w}
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
