unit OTransactions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type TOtransactions = record
     operationType: Integer;
     pop: ^integer;

end;


procedure testTransactions;

implementation

procedure testTransactions;
begin


  writeln('Transactions testing finished.');
end;

end.

