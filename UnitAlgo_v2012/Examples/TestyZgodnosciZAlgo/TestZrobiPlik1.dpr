Program UtworzPlikDemo;
Uses   Algo in '..\..\Algo.pas';  {$APPTYPE CONSOLE}
Const
   Nazwa='plik.txt';
Var
   Dok: text;

procedure Main;
Begin
  Writeln('Ustalam nazwê pliku: ',Nazwa);
  Assign(Dok,Nazwa);

  Writeln('Otwieram plik...');
  Rewrite(Dok);

  Writeln('Zapisuje...');
  Writeln(Dok,'To tylko testowa zawartoœæ pliku');

  Writeln('Zamykam plik.');
  Close(Dok);

  Writeln('Skoñczy³em. Czekam na ENTER na konsoli');
  AlgoSync;
  readln;
end;

begin
RunAsALGO(Main,'Writing to file test',200,100);
end.
