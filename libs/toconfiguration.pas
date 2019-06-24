unit TOConfiguration;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type TConfiguration = class

  Class Constructor create;
  Class Destructor destroy;

  procedure initDataDirectory(dataDir: String);

  var nodeSleepTime: Integer;
end;

implementation

procedure TConfiguration.initDataDirectory(dataDir: String);
begin
   self.nodeSleepTime := 10;

   if not DirectoryExists(dataDir) then
     begin
       writeln ('Creating data directory...');
       if not CreateDir(dataDir) then begin
         writeln('Can''t create the Data directory: ' + dataDir +'.');
         exit;
       end;
     end;
end;

Class Constructor  TConfiguration.Create;
begin

end;

Class Destructor TConfiguration.Destroy;
begin

end;

end.

