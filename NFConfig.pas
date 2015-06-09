unit NFConfig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TNetTrafConfigForm = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    edtHost: TEdit;
    Label2: TLabel;
    edtPort: TEdit;
    Label3: TLabel;
    edtInterface: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    chkNew: TCheckBox;
    chkNewColor: TCheckBox;
    chkLog: TCheckBox;
    Label4: TLabel;
    edtPassword: TEdit;
    chkshowtrafficintitle: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  RegNetTrafKey = 'Software\Rangel\NetTraf';

var
  NetTrafConfigForm: TNetTrafConfigForm;

implementation

{$R *.DFM}

uses
  Registry;

procedure TNetTrafConfigForm.btnCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TNetTrafConfigForm.btnOKClick(Sender: TObject);
var
  R: TRegistry;
begin
     R := TRegistry.Create;
     try
        R.OpenKey(RegNetTrafKey, True);
        R.WriteString('Host', edtHost.Text);
        R.WriteInteger('Port', StrToInt(edtPort.Text));
        R.WriteString('Interface', edtInterface.Text);
        R.WriteString('Password', edtPassword.Text);
        R.WriteBool('NewItf', chkNew.Checked);
        R.WriteBool('NewColor', chkNewColor.Checked);
        R.WriteBool('LogData', chkLog.Checked);
        R.WriteBool('ShowTrafficInTitle', chkshowtrafficintitle.Checked);
        R.CloseKey;
     finally
        R.Free;
     end;

     ModalResult := mrOk;
end;

procedure TNetTrafConfigForm.FormCreate(Sender: TObject);
var
  R: TRegistry;
begin
     R := TRegistry.Create;
     try
        R.OpenKey(RegNetTrafKey, True);
        if R.ValueExists('Host') then
           edtHost.Text := R.ReadString('Host');
        if R.ValueExists('Port') then
           edtPort.Text := IntToStr(R.ReadInteger('Port'));
        if R.ValueExists('Interface') then
           edtInterface.Text := R.ReadString('Interface');
        if R.ValueExists('Password') then
           edtPassword.Text := R.ReadString('Password');
        if R.ValueExists('NewItf') then
           chkNew.Checked := R.ReadBool('NewItf');
        if R.ValueExists('NewColor') then
           chkNewColor.Checked := R.ReadBool('NewColor');
        if R.ValueExists('LogData') then
           chkLog.Checked := R.ReadBool('LogData');
        if R.ValueExists('ShowTrafficInTitle') then
           chkshowtrafficintitle.Checked := R.ReadBool('ShowTrafficInTitle');
        R.CloseKey;
     finally
        R.Free;
     end;
end;

end.
