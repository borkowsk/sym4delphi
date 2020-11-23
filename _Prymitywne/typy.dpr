Program Typy;
{DLA DELPHI. NIE DZIA£A W ALGO BO BRAK sizeof ! }
begin
writeln('Podstawowe typy PASCALA');
writeln('Rozmiar typu char :',sizeof(char));
writeln('Rozmiar typu integer :',sizeof(integer));
writeln('Rozmiar typu real :',sizeof(real));
writeln;
writeln('Wybrane typy specyficzne dla Pascala Borlanda');
writeln('"integeropodobne":');
writeln('Rozmiar typu shortint :',sizeof(shortint));
writeln('Rozmiar typu longint :',sizeof(longint));
writeln('Rozmiar typu comp :',sizeof(comp));
writeln('zmiennoprzecinkowe:');
writeln('Rozmiar typu single :',sizeof(single));
writeln('Rozmiar typu double :',sizeof(double));
writeln('Rozmiar typu extended :',sizeof(extended));

readln;{czekanie na enter}
end.
