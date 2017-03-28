unit untLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, Buttons, ExtCtrls, StdCtrls, DB, adscnnct, adsdata,
  adsfunc, adstable, jpeg, StrUtils;

type
  TfrmLogin = class(TForm)
    adb_dbase: TAdsConnection;
    pnlLoginFormMain: TPanel;
    imgLogin: TImage;
    ClientSocket1: TClientSocket;
    pnlLoginInformation: TPanel;
    letPassword: TLabeledEdit;
    sbnLogin: TSpeedButton;
    letUserName: TLabeledEdit;
    pnlConnecting: TPanel;
    lbl_version: TLabel;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure letUserNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbnLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

  public
    procedure InitializeForm;
    procedure InitializeSocketConnection;
    procedure LogoffUser(AID: Integer);
  end;

var
  frmLogin: TfrmLogin;

implementation

uses md5, untMain;

{$R *.dfm}

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
 { Initializing Form }
  InitializeForm;
end;

procedure TfrmLogin.InitializeForm;
begin
  { Clear text fields }
  letUserName.Text := '';
  letPassword.Text := '';

  { Initializing Client Socket }
  pnlConnecting.Visible := False;
  pnlLoginInformation.Visible := True;
  //InitializeSocketConnection;

  { Connecting to database }
  
  while not adb_dbase.IsConnected do
    adb_dbase.IsConnected := True;
end;

procedure TfrmLogin.InitializeSocketConnection;
begin
  { This procedure initialized the socket connection. }
  { Whenever there's no connection established, this will }
  { just loop until a connection is established. }
  ClientSocket1.Port := 23;
  ClientSocket1.Host := '10.92.29.176'; { Our server address }
  ClientSocket1.Active := True;
end;

procedure TfrmLogin.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  ErrorCode := 0;
  ClientSocket1.Active := True;
end;

procedure TfrmLogin.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  { If connected from server, then two options can be chosen }
  { If User has logged in, then applications resume }
  { If User is still in the login page, then the login screen returns to the "get login info" mode }

  if frmMain.GetAccountID > 0 then
  begin

  end
  else
  begin
    pnlConnecting.Visible := False;
    pnlLoginInformation.Visible := True;
  end;
end;

procedure TfrmLogin.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  { If disconnected from server, then two options can be chosen }
  { If User has logged in, then a "connecting" panel appears disabling the applications }
  { If User is still in the login page, then the login screen returns to the "connecting" mode }

  if frmMain.GetAccountID > 0 then
  begin

  end
  else
  begin
    pnlConnecting.Visible := True;
    pnlLoginInformation.Visible := False;
  end;
  
  InitializeSocketConnection;
end;

procedure TfrmLogin.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
var
  ReceivedText, Token: String;
  Param1, Param2: String;
  MessageCode: Integer;
  X: Integer;
begin
  MessageCode := 0;
  ReceivedText := Socket.ReceiveText;
  if ReceivedText <> '' then
  begin
    Token := '';
    for X := 1 to Length(ReceivedText) do
    begin
      if copy(ReceivedText,X,1) <> ' ' then
        Token := Token + copy(ReceivedText,X,1)
      else
        Break;
    end;

    { Converting Token strings into Integer Message Codes }
    if Token = 'REFRESHDATABASE' then MessageCode := 1;
    if Token = 'MESSAGE' then MessageCode := 2;

    { Perform actions }
    case MessageCode of
      1: { Module that refreshes the database for all applications run } ;
      2: { Receives a message from server and/or from any client }
        begin
          Param1 := '';
          for X := ((Length(Token) + 1) + 1) to Length(ReceivedText) do
          begin
            if copy(ReceivedText,X,1) <> ' ' then
              Param1 := Param1 + copy(ReceivedText,X,1)
            else
              Break;
          end;
          if Param1 = 'ALL' then
          begin
            MessageDlg(copy(ReceivedText,(Length(Token) + 1) + (Length(Param1) + 1) + 1,Length(ReceivedText) - ((Length(Token) + 1) + (Length(Param1) + 1) + 1)),mtInformation,[mbOk],0);
          end
          else
          begin
            if StrToInt(Param1) = frmMain.GetAccountID then
            begin
              Param2 := RightStr(ReceivedText,Length(ReceivedText) - ((Length(Token) + 1) + (Length(Param1) + 1)));
              MessageDlg(Param2,mtInformation,[mbOk],0);              
            end;
          end;
        end;
    end;
  end;
end;

procedure TfrmLogin.letUserNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    if ((length(letUserName.Text) = 0) or (length(letPassword.Text) = 0)) then
      MessageDlg('Usernames and passwords should not be empty.',mtError,[mbOk],0)
    else
      sbnLoginClick(Self);
  end;
end;

procedure TfrmLogin.sbnLoginClick(Sender: TObject);
var
  AccountID: Integer;

  function PermitUser: Boolean;
  var
    qryLogin: TAdsQuery;
  begin
    qryLogin := TAdsQuery.Create(Self);
    qryLogin.AdsConnection := adb_dbase;
    with qryLogin do
    begin
      SQL.Text := 'SELECT * FROM ACCOUNTS WHERE UserID=''' + letUserName.Text + ''' AND UserPassword=''' + MD5DigestToStr(MD5String(letPassword.Text)) + ''' AND Active=True';
      Active := True;
      if RecordCount > 0 then
        Result := True
      else
        Result := False;
    end;
    qryLogin.Free;
  end;

  procedure UpdateLoginEntry;
  var
    tblLogin: TAdsTable;
  begin
    tblLogin := TAdsTable.Create(Self);
    tblLogin.AdsConnection := adb_dbase;
    with tblLogin do
    begin
      TableName := 'ACCOUNTS';
      Open;
      Locate('UserID;Active',VarArrayOf([letUserName.Text,'True']),[]);
      AccountID := FieldByName('AccountID').AsInteger;
      Edit;
      FieldByName('LoggedIn').AsBoolean := True;
      FieldByName('LastLogin').AsDateTime := Now;
      Post;
    end;
    tblLogin.Free;
  end;

begin
  if ((length(letUserName.Text) = 0) or (length(letPassword.Text) = 0)) then
      MessageDlg('Username and password should not be empty.',mtError,[mbOk],0)
  else
  begin
    if PermitUser then
    begin
      UpdateLoginEntry;
      frmLogin.Hide;
      with frmMain do
      begin
        InitializeForm(AccountID);
        sbr_main.Panels[1].Text := letUserName.Text;
        Show;
      end;
    end
    else
    begin
      MessageDlg('Invalid access. Please try again.',mtError,[mbOk],0);
      InitializeForm;
      letUserName.SetFocus;
    end;
  end;
end;

procedure TfrmLogin.LogoffUser(AID: Integer);
var
  qryLogout: TAdsQuery;
begin
  qryLogout := TAdsQuery.Create(Self);
  qryLogout.AdsConnection := adb_dbase;
  with qryLogout do
  begin
    SQL.Text := 'UPDATE ACCOUNTS SET LoggedIn=False WHERE AccountID='+IntToStr(AID)+' AND Active=True';
    ExecSQL;
  end;
  qryLogout.Free;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  lbl_version.Caption := CURR_RELEASE;
  letUserName.SetFocus;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmmain.Close;
end;

end.
