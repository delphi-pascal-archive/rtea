// RTEA-256, вариант алгоритма XTEA, усиленный и ускоренный Ruptor'ом
// Реализация на языке C - А.В.Мясников, г.Кольчигино Владимирской обл., Россия

unit cu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var key: array [0..7] of longint = (0,0,0,0,0,0,0,0);

function __crypt (var a: longint; var b: longint) : longint; export;
var r: longint;
begin

r:=-1;
repeat
 inc(r);
{$Q-}
 inc(b,a +((a shl 6) xor (a shr 8))+ (key[r mod 8]+r));
 inc (r);
{$Q-}
 inc (a,b+((b shl 6) xor (b shr 8))+ (key[r mod 8]+r));

until r=63;

result:=0;
end;

function __decrypt (var a: longint; var b: longint) : longint; export;
var r: longint;
begin

r:=64;

repeat
dec (r);
{$Q-}
dec (a,b+((b shl 6) xor (b shr 8))+ (key[r mod 8]+r));
dec(r) ;
{$Q-}
dec (b,a+((a shl 6) xor (a shr 8))+ (key[r mod 8]+r));
until r=0;

result:=0
end;

type longintarray = array [0..3] of longint;
type plongintarray = ^longintarray;

function rtea_crypt (ap: plongintarray; bp: plongintarray) : longint; export; stdcall;
var a, b: longint;
begin
a:=ap[0];
b:=ap[1];

__crypt (a, b);

bp[0]:=a;
bp[1]:=b;

a:=ap[2];
b:=ap[3];

__crypt (a, b);

bp[2]:=a;
bp[3]:=b;

result:=0;
end;

function rtea_decrypt (ap: plongintarray; bp: plongintarray) : longint; export; stdcall;
var a, b: longint;
begin
a:=ap[0];
b:=ap[1];

__decrypt (a, b);

bp[0]:=a;
bp[1]:=b;

a:=ap[2];
b:=ap[3];

__decrypt (a, b);

bp[2]:=a;
bp[3]:=b;

result:=0;
end;

function setup (ap: pointer) : longint; export; stdcall;
begin
move (ap^, key, 32);
result:=0;
end;

var pwd: array [0..7] of longint;
var din:array [0..3] of longint;
var dout:array [0..3] of longint;
var dc:array [0..3] of longint;

procedure TForm1.Button1Click(Sender: TObject);
var i: integer;  error: boolean;
begin

randomize();

for i:=0 to 3 do din[i]:=random(maxlongint);
for i:=0 to 7 do pwd[i]:=random(maxlongint);

setup(@pwd);
fillchar (dout,16,0);
fillchar (dc,16,0);
rtea_crypt(@din,@dout);
rtea_decrypt(@dout,@dc);
memo1.Lines.Clear;

memo1.Lines.Add('Key:');
for i:=0 to 7 do begin
memo1.Text:=memo1.Text+(format('%d ',[key[i]]));
end;

memo1.Lines.Add(#13#10+'Orignal data:'+#13#10);
for i:=0 to 3 do begin
memo1.Text:=memo1.Text+(format('%d ',[din[i]]));
end;

memo1.Lines.Add(#13#10+'Decoded data:'+#13#10);
for i:=0 to 3 do begin
memo1.Text:=memo1.Text+(format('%d ',[dc[i]]));
end;

error:=false;
for i:=0 to 3 do begin
error:=true;
if din[i]<>dc[i] then memo1.Lines.Add(format('Incorrect value %d',[i]));
end;

memo1.Lines.Add(#13#10);

if error then begin
memo1.Lines.Add(format('Cipher test passed OK!',[]));
end else begin
memo1.Lines.Add(format('Cipher test failed!',[]));
end;
end;

end.