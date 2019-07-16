unit utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, XMLConf, OKey,
  UPCDataTypes, UCrypto, UBaseTypes, UConst, UOpenSSL , UPCCryptoLib4Pascal, UPCEncryption ,
  otransactions, orunner
  ;

//procedure initMiner();
//
//procedure initServer();


var Runner: TOInstance;

procedure RunModel();

implementation


procedure RunModel();
begin
    Runner := TOInstance.Create;

    //try to get the instance ID from InstanceID environment variable

    Runner.InstanceID := GetEnvironmentVariable('InstanceID');
    if (Trim(Runner.InstanceID) = '') then begin
       writeln('Run the tech demo like: export InstanceID=''nodeA'' && ./ominer');
       writeln('Continuing in default mode...');
       Runner.InstanceID:= 'nodeA';
    end;

    Runner.run;
end;



//
//procedure initServer();
//begin
//    WriteLn('PATH = ' + GetEnvironmentVariable('SEEDNODE'));
//    testNetServer('16384');
//end;
//
//procedure initMiner();
//var config: TXMLConfig;
//
//
//  privateKey: TECPrivateKey;
//  pk: TECPrivateKey;
//  privateRaw, pr: TRawBytes;
//
//  pubko, pubkd : TRawBytes;
//  ss: String;
//
//  pubk : TECDSA_Public;
//  pubor, pubdr : TECDSA_Public_Raw;
//
//  loadedssl, e: Boolean;
//
//  O, Q : TOKey;
//
//  emsg, dmsg, msg: TRawBytes;
//  sign: TECDSA_SIG;
//
//  eqsign, r: Boolean;
//
//begin
//
//    testNetClient('16384');
//    //testTransactions;
//
//    exit;
//
//     writeln('test');
//
//
//
//     loadedssl := InitSSLFunctions();
//
//     privateKey := TECPrivateKey.Create;
//     privateKey.GenerateRandomPrivateKey(CT_Default_EC_OpenSSL_NID);
//     privateRaw := privateKey.ExportToRaw;
//     //pubko := privateKey.PublicKey.ToRaw(CT_Default_EC_OpenSSL_NID);
//     ss := privateRaw.ToHexaString;
//     writeln('Private original:   ' + ss);
//
//     privateKey.PublicKey.ToRaw(pubor);
//     writeln('Public original:    ' + pubor.ToHexaString);
//
//
//     //pk := TECPrivateKey.Create;
//     //pk.SetPrivateKeyFromHexa(CT_Default_EC_OpenSSL_NID, ss);
//
//     pk := TECPrivateKey.ImportFromRaw(privateRaw);
//     e := pk.Equals(privateKey);
//     pr := pk.ExportToRaw;
//     writeln('Private duplicated: ' + pr.ToHexaString);
//
//     pk.PublicKey.ToRaw(pubdr);
//     writeln('Public duplicated:  ' + pubor.ToHexaString);
//
//     privateKey.Free;
//     pk.Free;
//
//     O := TOKey.Create;
//     O.GenerateNewRandomPair();
//     O.output;
//
//     O.ImportPrivateKeyFromRaw(privateRaw);
//     O.output;
//
//     O.ImportPrivateKeyFromHex(privateRaw.ToHexaString);
//     //O.ImportPrivateKeyFromHex('CA022000D0B36127CC566319DA9E2013A2BC95113D8F512893328E850B6D343FCA9C19E9');
//     O.output;
//
//     Q := TOKey.Create;
//     Q.ImportPrivateKeyFromRaw(privateRaw);
//
//     if (Q.Equals(O)) then
//        writeln('Eq')
//     else
//         writeln('Not eq.');
//     Q.output;
//
//
//
//     //semnare de mesaj
//     msg := TRawBytes.create;
//     msg.FromString('This is my message!');
//     writeln('Original msg: ' + msg.ToString);
//
//     sign := TCrypto.ECDSASign(O.GetPrivateKey, msg);
//     writeln ('Signature: ' + sign.r.ToHexaString + ' : ' + sign.s.ToHexaString);  // 64 + 64 chars length
//     writeln('Sign: ' + TCrypto.EncodeSignature(sign).ToHexaString);  // 136 chars length
//
//     eqsign:= TCrypto.ECDSAVerify(O.GetPublicKey, msg, sign);
//
//     if (eqsign) then
//        writeln ('Matching signatures!')
//        else
//        writeln('NOT matching signatures!!!');
//    // end semnare de mesaj
//
//    //cryptare mesaj
//    TPCEncryption.DoPascalCoinECIESEncrypt(O.GetPublicKey,msg, emsg); //encode using public
//    writeln ('Encoded message: ' + emsg.ToHexaString);
//    r := TPCEncryption.DoPascalCoinECIESDecrypt(O.GetPrivateKey, emsg, dmsg); //decode using private
//    if (not r) then
//        writeln('Decoding failed...');
//
//    writeln('Decoded message: ' + dmsg.ToString);
//
//
//   config := TXMLConfig.Create(nil);
//   config.Filename:= 'config.xml';
//   config.SetValue('algo','ttee');
//   config.SaveToFile('config.xml');
//
//     writeln('');
//     writeln('Heheeee all good man!!!!');
//end;

end.

