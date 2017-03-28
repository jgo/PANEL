unit untChangePass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, adsdata, adsfunc, adstable;

type
  TfrmChangePass = class(TForm)
    letOldPassword: TLabeledEdit;
    letNewPassword: TLabeledEdit;
    letVerifyPassword: TLabeledEdit;
    btnChange: TBitBtn;
    btnCancel: TBitBtn;
    procedure btnCancelClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure letOldPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure letNewPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure letVerifyPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitializeForm;
  end;

var
  frmChangePass: TfrmChangePass;

implementation

uses untLogin, untMain, md5;

{$R *.dfm}

procedure TfrmChangePass.InitializeForm;
begin
  letOldPassword.Text := '';
  letNewPassword.Text := '';
  letVerifyPassword.Text := '';
end;

procedure TfrmChangePass.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmChangePass.btnChangeClick(Sender: TObject);
var
  qryAccount: TAdsQuery;
begin
  qryAccount := TAdsQuery.Create(Self);
  qryAccount.AdsConnection := frmLogin.adb_dbase;
  with qryAccount do
  begin
    SQL.Text := 'SELECT * FROM ACCOUNTS WHERE AccountID='+IntToStr(frmMain.GetAccountID)+' AND Active=True';
    Active := True;
    { Verifies Old Password }
    if MD5DigestToStr(MD5String(letOldPassword.Text)) <> FieldByName('UserPassword').AsString then
      MessageDlg('Change failed. Unable to verify password.',mtError,[mbOk],0)
    else
      if letNewPassword.Text <> letVerifyPassword.Text then
        MessageDlg('Change failed. Make sure that the new provided passwords are identical.',mtError,[mbOk],0)
      else if length(letNewPassword.Text) <= 6 then
      begin
        MessageDlg('Change failed. Passwords are must be above 6 characters.',mtError,[mbOk],0)
      end
      else
      begin
        SQL.Text := 'UPDATE ACCOUNTS SET UserPassword='''+MD5DigestToStr(MD5String(letNewPassword.Text))+''' WHERE AccountID='+IntToStr(frmMain.GetAccountID)+' AND Active=True';
        ExecSQL;
        MessageDlg('Password change success!',mtInformation,[mbOk],0);
        frmChangePass.Close;
      end;
  end;
  qryAccount.Free;
end;

procedure TfrmChangePass.letOldPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnChangeClick(Self);
end;

procedure TfrmChangePass.letNewPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnChangeClick(Self);
end;

procedure TfrmChangePass.letVerifyPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnChangeClick(Self);
end;

end.
