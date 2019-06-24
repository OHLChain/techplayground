unit OKey;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UPCDataTypes, UCrypto, UBaseTypes, UConst, UOpenSSL, UPCEncryption;


Type TOKey = class
    private
           privateKeyRaw : TRawBytes;
           publicKeyRaw: TECDSA_Public_Raw;
           privateKey: TECPrivateKey;
           procedure ExtractRaws();

    public
            procedure GenerateNewRandomPair();
            procedure ImportPrivateKeyFromRaw(data: TRawBytes);
            procedure ImportPrivateKeyFromHex(data: String);

            function GetPrivateKey: TECPrivateKeyInfo;
            function PrivateKeyAsRaw() : TRawBytes;

            function GetPublicKey: TECDSA_Public;
            function PublicKeyAsRaw() : TECDSA_Public_Raw;
            function PrivateKeyAsHex(): String;
            function PublicKeyAsHex(): String;

            function Equals(key: TOKey): boolean; overload;
            procedure output;

            function SignTRawBytes(msg: TRawBytes): TECDSA_SIG; overload;
            function SignTRawBytes(privKey: TECPrivateKeyInfo ;msg: TRawBytes): TECDSA_SIG; overload;
            function SignAsHex(sign: TECDSA_SIG): String;

            function SignVerify(msg: TRawBytes; sign: TECDSA_SIG): boolean; overload;
            function SignVerify(pubKey: TECDSA_Public; msg: TRawBytes; sign: TECDSA_SIG): boolean; overload;

            function EncryptMessage(msg: TRawBytes): TRawBytes; overload;
            function EncryptMessage(pubKey: TECDSA_Public; msg: TRawBytes): TRawBytes; overload;

            function DecryptMessage(emsg: TRawBytes): TRawBytes; overload;
            function DecryptMessage(privKey: TECPrivateKeyInfo; emsg: TRawBytes): TRawBytes; overload;
end;

implementation

  function TOKey.DecryptMessage(privKey: TECPrivateKeyInfo; emsg: TRawBytes): TRawBytes; overload;
  var dmsg: TRawBytes;
  begin
      TPCEncryption.DoPascalCoinECIESDecrypt(privKey, emsg, dmsg);
      Result := dmsg;
  end;

  function TOKey.DecryptMessage(emsg: TRawBytes): TRawBytes; overload;
  var dmsg: TRawBytes;
  begin
      TPCEncryption.DoPascalCoinECIESDecrypt(GetPrivateKey, emsg, dmsg);
      Result := dmsg;
  end;

  function TOKey.EncryptMessage(pubKey: TECDSA_Public; msg: TRawBytes): TRawBytes; overload;
  var emsg: TRawBytes;
  begin
      TPCEncryption.DoPascalCoinECIESEncrypt(pubKey,msg, emsg);
      Result := emsg;
  end;

  function TOKey.EncryptMessage(msg: TRawBytes): TRawBytes; overload;
  var emsg: TRawBytes;
  begin
      TPCEncryption.DoPascalCoinECIESEncrypt(GetPublicKey,msg, emsg);
      Result := emsg;
  end;

  function TOKey.SignVerify(msg: TRawBytes; sign: TECDSA_SIG): boolean;
  begin
    Result := TCrypto.ECDSAVerify(GetPublicKey, msg, sign);
  end;

  function TOKey.SignVerify(pubKey: TECDSA_Public; msg: TRawBytes; sign: TECDSA_SIG): boolean; overload;
  begin
     Result := TCrypto.ECDSAVerify(pubKey, msg, sign);
  end;

  function TOKey.SignAsHex(sign: TECDSA_SIG): String;
  begin
     Result := TCrypto.EncodeSignature(sign).ToHexaString;
  end;

  function TOKey.SignTRawBytes(msg: TRawBytes): TECDSA_SIG;
  begin
      Result := TCrypto.ECDSASign(GetPrivateKey, msg);
  end;

  function TOKey.SignTRawBytes(privKey: TECPrivateKeyInfo ;msg: TRawBytes): TECDSA_SIG; overload;
  begin
     Result := TCrypto.ECDSASign(privKey, msg);
  end;

  function TOKey.GetPrivateKey: TECPrivateKeyInfo;
  begin
       Result := privateKey.PrivateKey;
  end;

  function TOkey.GetPublicKey: TECDSA_Public;
  begin
       Result := privateKey.PublicKey;
  end;

  function TOKey.Equals(key: TOKey): boolean;
  begin
       Result := True;

       if ( (key.PublicKeyAsHex() <> PublicKeyAsHex()) OR (key.PrivateKeyAsHex() <> PrivateKeyAsHex()) ) then begin
          Result := False;
       end;
  end;

  procedure TOKey.output;
  begin
       writeln('Public : ' +PublicKeyAsHex());
       writeln('Private : ' +PrivateKeyAsHex());
  end;

  procedure TOKey.GenerateNewRandomPair();
  begin
     privateKey := TECPrivateKey.Create;
     privateKey.GenerateRandomPrivateKey(CT_Default_EC_OpenSSL_NID);
     ExtractRaws();
  end;

  procedure TOKey.ImportPrivateKeyFromRaw(data: TRawBytes);
  begin
     privateKey := TECPrivateKey.ImportFromRaw(data);
     ExtractRaws();
  end;

  procedure TOKey.ImportPrivateKeyFromHex(data: String);
  begin
     ImportPrivateKeyFromRaw(TCrypto.HexaToRaw(data));
  end;

  function TOKey.PrivateKeyAsHex(): String;
  begin
     Result := privateKeyRaw.ToHexaString;
  end;

  function TOKey.PublicKeyAsHex(): String;
  begin
     Result := publicKeyRaw.ToHexaString;
  end;

  procedure TOKey.ExtractRaws();
  begin
     privateKeyRaw := privateKey.ExportToRaw;
     privateKey.PublicKey.ToRaw(publicKeyRaw);
  end;

  function TOKey.PrivateKeyAsRaw(): TRawBytes;
  begin
       Result := privateKeyRaw;
  end;

  function TOKey.PublicKeyAsRaw() : TECDSA_Public_Raw;
  begin
       Result := publicKeyRaw;
  end;

end.

