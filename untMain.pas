unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, ComCtrls, ExtCtrls, StdCtrls, adsdata,
  adsfunc, adstable, Jpeg, DB, ShellApi, Buttons;

const
  CURR_RELEASE = 'v4.01';

type
  TfrmMain = class(TForm)
    mmuMainPanel: TMainMenu;
    WesternWats1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    About1: TMenuItem;
    ChangePassword1: TMenuItem;
    N1: TMenuItem;
    ViewLogs1: TMenuItem;
    N2: TMenuItem;
    Logout1: TMenuItem;
    Exit1: TMenuItem;
    imgMainHeader: TImage;
    lvwApps: TListView;
    qryApps: TAdsQuery;
    qryAppsApplicationID: TAutoIncField;
    qryAppsApplicationName: TAdsStringField;
    qryAppsApplicationPath: TAdsStringField;
    qryAppsRemoved: TBooleanField;
    qryAppsApplicationIcon: TBlobField;
    iltApps: TImageList;
    Timer1: TTimer;
    sbr_main: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangePassword1Click(Sender: TObject);
    procedure Logout1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvwAppsDblClick(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    AccountID: Integer;
    cbxApplicationPath: TCombobox;
    cbxSelectedApp: TCombobox;
    AppList: array of String;
    AppStatus: array of Boolean;
    ExitFlag: Integer; {1 = Logout, 2 = Exit, 0 = Normal Window Close}
    procedure LoadImage;
  public
    { Public declarations }
    procedure InitializeForm(AID: Integer);
    function GetAccountID: Integer;
    procedure CloseAllApps;
  end;

var
  frmMain: TfrmMain;

implementation

uses untLogin, untChangePass;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  AccountID := -1;
  cbxApplicationPath := TCombobox.Create(Self);
  with cbxApplicationPath do
  begin
    Parent := frmMain;
    Visible := False;
  end;
  cbxSelectedApp := TCombobox.Create(Self);
  with cbxSelectedApp do
  begin
    Parent := frmMain;
    Visible := False;
  end;
  SetLength(AppList,0);
  SetLength(AppStatus,0);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  cbxApplicationPath.Free;
  cbxSelectedApp.Free;
end;

procedure TfrmMain.InitializeForm(AID: Integer);
var
  X: Integer;
begin
  { Refreshing Exit Flag }
  ExitFlag := 0;

  { Fetching AccountID }
  AccountID := AID;

  { Refreshing components }
  iltApps.Clear;
  lvwApps.Clear;
  cbxApplicationPath.Items.Clear;
  cbxSelectedApp.Items.Clear;

  { Populate allowable applications for the said user }
  with qryApps do
  begin
    SQL.Text := 'SELECT * FROM APPLICATIONS WHERE ApplicationID IN (SELECT ApplicationID FROM ACCESS WHERE AccountID='+IntToStr(AccountID)+' AND Removed=False) AND Removed=False ORDER BY ApplicationName';
    Active := True;
    SetLength(AppList,RecordCount);
    SetLength(AppStatus,RecordCount);
    for X := 0 to (RecordCount - 1) do
    begin
      cbxApplicationPath.Items.Add(FieldByName('ApplicationPath').AsString);
      cbxSelectedApp.Items.Add(FieldByName('ApplicationID').AsString);
      lvwApps.Items.Add.Caption := FieldByName('ApplicationName').AsString;
      LoadImage;
      lvwApps.Items.Item[X].ImageIndex := X;
      AppList[X] := FieldByName('ApplicationName').AsString;
      AppStatus[X] := False;
      Next;
    end;
  end;

  { Positioning the application pointer to the first application if there are any }
  if lvwApps.Items.Count > 0 then
    lvwApps.ItemIndex := 0
end;

function TfrmMain.GetAccountID: Integer;
begin
  Result := AccountID;
end;

procedure TfrmMain.CloseAllApps;
var
  X: Integer;
begin
  for X := Low(AppList) to High(AppList) do
    if AppStatus[X] then
      SendMessage(FindWindow(nil,PAnsiChar(AppList[X])),WM_CLOSE,1,1);
end;

procedure TfrmMain.LoadImage;
var
  MyBStream: TADSBlobStream;
  Pic: TJpegImage;
  PicToBMP: TImage;

  function JpegStartsInBlob(PicField:TBlobField): Integer;
  var
    BStream: TADSBlobStream;
    Buffer: Word;
    HX: string;
  begin
    Result := -1;
    BStream := TADSBlobStream.Create(PicField, bmRead);
    try
      while (Result = -1) and (BStream.Position + 1 < BStream.Size) do
      begin
        BStream.ReadBuffer(Buffer, 1);
        HX := IntToHex(Buffer, 2);
        if HX = 'FF' then
        begin
          BStream.ReadBuffer(Buffer, 1);
          HX := IntToHex(Buffer, 2);
          if HX = 'D8' then Result := BStream.Position - 2 else if HX = 'FF' then BStream.Position := BStream.Position-1;
        end;
      end;
    finally
      BStream.Free;
    end;
  end;

begin
  MyBStream := TADSBlobStream.Create(qryAppsApplicationIcon, bmRead);
  try
    MyBStream.Seek(JpegStartsInBlob(qryAppsApplicationIcon), soFromBeginning);
    Pic := TJpegImage.Create;
    try
      Pic.LoadFromStream(MyBStream);
      PicToBMP := TImage.Create(Self);
      PicToBMP.Picture.Bitmap.Assign(Pic);
      iltApps.Add(PicToBMP.Picture.Bitmap,nil);
    finally
      Pic.Free;
    end;
  finally
    MyBStream.Free
  end;
end;

procedure TfrmMain.ChangePassword1Click(Sender: TObject);
begin
  with frmChangePass do
  begin
    InitializeForm;
    ShowModal;
  end;
  InitializeForm(AccountID);
end;

procedure TfrmMain.Logout1Click(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to log off the system and close all active applications?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ExitFlag := 1;
    Close;
  end;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to exit the application and close all active applications?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ExitFlag := 2;
    Close;
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  case ExitFlag of
    1: CanClose := True;
    2: CanClose := True;
    0: if MessageDlg('Are you sure you want to exit the application and close all active applications?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then CanClose := True;
  end;
  if CanClose then
  begin
    CloseAllApps;
    frmLogin.LogoffUser(AccountID);
    AccountID := -1;
    if ((ExitFlag = 0) or (ExitFlag = 2)) then
      Application.Terminate
    else
    begin
      with frmLogin do
      begin
        InitializeForm;
        Show;
        frmLogin.letUserName.SetFocus;
      end;
    end;
  end;
end;

procedure TfrmMain.lvwAppsDblClick(Sender: TObject);
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
  ExecuteFile, ParamString, ConnectionPath: String;
  qryAccessUpdate, qryAccountInfo: TAdsQuery;
  AccessID: Integer;
begin
//  ConnectionPath := '\\cebutimecard-db\ads_database\Master\db\WWPI.add';
//  ConnectionPath := '\\dvotimecard1-db:26000\ads_database\Master\Davao\WWDavao.add';
  ConnectionPath := '\\ph-timecarddb01:26000\ads_database\Master\db\WWPI.add';
  lvwApps.SetFocus;
  if lvwApps.SelCount > 0 then
  begin
    qryAccessUpdate := TAdsQuery.Create(Self);
    qryAccessUpdate.AdsConnection := frmLogin.adb_dbase;
    with qryAccessUpdate do
    begin
      SQL.Text := 'SELECT * FROM ACCESS WHERE AccountID='+IntToStr(GetAccountID)+' AND ApplicationID='+cbxSelectedApp.Items.Strings[lvwApps.ItemIndex]+' AND Removed=False';
      Active := True;
      AccessID := FieldByName('AccessID').AsInteger;
    end;
    if not qryAccessUpdate.FieldByName('LoggedIn').AsBoolean then
    begin
      ExecuteFile := cbxApplicationPath.Items.Strings[lvwApps.ItemIndex];
      qryAccountInfo := TAdsQuery.Create(Self);
      qryAccountInfo.AdsConnection := frmLogin.adb_dbase;
      with qryAccountInfo do
      begin
        SQL.Text := 'SELECT * FROM ACCOUNTS WHERE AccountID='+IntToStr(GetAccountID);
        Active := True;
      end;
//      pnl_loading.Visible :=  true;
      lvwApps.Enabled := false;
      ParamString := IntToStr(AccountID) + ' ' + qryAccountInfo.FieldByName('UserID').AsString + ' ' + qryAccountInfo.FieldByName('UserPassword').AsString + ' ' + ConnectionPath;
      qryAccountInfo.Free;
      FillChar(SEInfo, SizeOf(SEInfo), 0);
      SEInfo.cbSize := SizeOf(TShellExecuteInfo);
      with SEInfo do
      begin
        fMask := SEE_MASK_NOCLOSEPROCESS;
        Wnd := Application.Handle;
        lpFile := PChar(ExecuteFile);
        lpParameters := PChar(ParamString);
        nShow := SW_SHOWNORMAL;
      end;
      if ShellExecuteEx(@SEInfo) then
      begin
        with qryAccessUpdate do
        begin
          SQL.Text := 'UPDATE ACCESS SET LoggedIn=False WHERE AccessID='+IntToStr(AccessID);
          ExecSQL;
        end;
        AppStatus[lvwApps.ItemIndex] := True;
//        pnl_loading.Visible :=  false;
        lvwApps.Enabled := true;
        if frmLogin.ClientSocket1.Active then
          frmLogin.ClientSocket1.Socket.SendText('REFRESHCONNECTEDUSERS');
        repeat
          Application.ProcessMessages;
          GetExitCodeProcess(SEInfo.hProcess, ExitCode);
        until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
        begin
          with qryAccessUpdate do
          begin
            SQL.Text := 'UPDATE ACCESS SET LoggedIn=False WHERE AccessID='+IntToStr(AccessID);
            ExecSQL;
          end;
          AppStatus[lvwApps.ItemIndex] := False;
          if frmLogin.ClientSocket1.Active then
            frmLogin.ClientSocket1.Socket.SendText('REFRESHCONNECTEDUSERS');
          { Need to send code to application to end session }
        end;
      end
      else
        MessageDlg('Error starting application.',mtError,[mbOk],0);
    end
    else
    begin
      { Need to send code to set focus on the selected application }
    end;
    qryAccessUpdate.Free;
  end;
end;

procedure TfrmMain.Contents1Click(Sender: TObject);
begin
  MessageDlg('Under Development!',mtInformation,[mbOk],0);
end;

procedure TfrmMain.About1Click(Sender: TObject);
begin
  MessageDlg('Under Development!',mtInformation,[mbOk],0);
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  sbr_main.Panels[2].Text := FormatDateTime('mmmm dd, yyyy',Now);
  sbr_main.Panels[3].Text := FormatDateTime('hh:nn:ss AM/PM',Now);
end;

end.
