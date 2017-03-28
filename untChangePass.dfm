object frmChangePass: TfrmChangePass
  Left = 248
  Top = 136
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Change Password ...'
  ClientHeight = 175
  ClientWidth = 170
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object letOldPassword: TLabeledEdit
    Left = 9
    Top = 22
    Width = 153
    Height = 21
    EditLabel.Width = 68
    EditLabel.Height = 13
    EditLabel.Caption = 'Old Password:'
    MaxLength = 30
    PasswordChar = '*'
    TabOrder = 0
    OnKeyDown = letOldPasswordKeyDown
  end
  object letNewPassword: TLabeledEdit
    Left = 9
    Top = 61
    Width = 153
    Height = 21
    EditLabel.Width = 74
    EditLabel.Height = 13
    EditLabel.Caption = 'New Password:'
    MaxLength = 30
    PasswordChar = '*'
    TabOrder = 1
    OnKeyDown = letNewPasswordKeyDown
  end
  object letVerifyPassword: TLabeledEdit
    Left = 9
    Top = 102
    Width = 153
    Height = 21
    EditLabel.Width = 103
    EditLabel.Height = 13
    EditLabel.Caption = 'Verify New Password:'
    MaxLength = 30
    PasswordChar = '*'
    TabOrder = 2
    OnKeyDown = letVerifyPasswordKeyDown
  end
  object btnChange: TBitBtn
    Left = 6
    Top = 132
    Width = 80
    Height = 42
    Caption = 'Ch&ange'
    TabOrder = 3
    OnClick = btnChangeClick
  end
  object btnCancel: TBitBtn
    Left = 85
    Top = 132
    Width = 80
    Height = 42
    Caption = '&Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
