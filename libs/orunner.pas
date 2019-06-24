unit ORunner;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, onetcode, toconfiguration, crt
  ;

Type TNode = record
     address: String;
     connected: Boolean;
     speedBench: Integer;
end;




Type TOInstance = class
   var
      InstanceID: String;
      dataDir: String;
      config: TConfiguration;
      Terminating: Boolean;
      ch: char;

   procedure run;
   procedure loop;
   procedure readConfiguration;

end;

implementation

procedure TOInstance.run;
begin
   writeln('Node '''+self.InstanceID+''' initiated.');
   self.Terminating:= False;
   self.readConfiguration;
   self.loop;
end;

procedure TOInstance.readConfiguration;
begin

  // set the data directory
  if (self.InstanceID = 'default') then begin
     self.dataDir := 'Data';
   end else begin
     self.dataDir := self.InstanceID;
   end;

   self.config := TConfiguration.Create;
   self.config.initDataDirectory(self.dataDir);

end;

procedure TOInstance.loop;
begin
  write('Press q to quit.' + chr(13)+chr(10));

  repeat

    sleep(self.config.nodeSleepTime);

    if KeyPressed then begin
       ch := readKey();
       if (ch = 'q') then self.Terminating:=True;
    end;

  until self.Terminating = True;
end;

end.

