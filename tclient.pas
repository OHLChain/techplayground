unit TClient;

{$mode objfpc}{$H+}

interface

uses
  Classes, blcksock, synsock, crt, sysutils, TConnectionManager;

Type Psocket =  ^TTCPBlockSocket;

Type TOClientThread = class(TThread)
   private
     Socket: TTCPBlockSocket;
     public
    Constructor Create (hsock:TTCPBlockSocket; id: integer);
    procedure Execute; override;
  end;

Type TOClient = class
     thread: TOClientThread;
      Sock:TTCPBlockSocket;
     constructor Create; overload;

end;


implementation

constructor TOClient.Create; overload;
var cmd: string;
begin
    writeln('created');
    Sock := TTCPBlockSocket.Create;
    sock.ConnectionTimeout:=1000;
    Sock.Connect('127.0.0.1','8008');

    self.thread := TOClientThread.Create(Sock, 1);

    self.thread.FreeOnTerminate:=TRUE;
    self.thread.Execute;
    Sock.SendString('something..');
    sleep(100);
    //repeat
    //   cmd := Sock.RecvBlock(10000);
    //   writeln('CLIENT: ' + cmd);
    //   sleep(100);
    //until cmd<>''#13#10;
    //
    //writeln('Client died.');
end;

Constructor TOClientThread.Create(hsock:TTCPBlockSocket; id: integer);
begin
    self.Socket := hsock;

end;

 procedure TOClientThread.execute();
 begin
     self.Socket.SendString('asasas');
     repeat
         sleep(1000);
         self.Socket.SendString('asasas dsodpsdo fdofpd');

     until not self.Socket.CanRead(1000);
     writeln('CLIENT THREAD FINISHED!');
 end;

end.

