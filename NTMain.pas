unit NTMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus, ScktComp, StdCtrls, RXShell, ComCtrls;

type
  TNetTrafForm = class(TForm)
    Bevel1: TBevel;
    sbNT: TStatusBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Configuration1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    Showhelp1: TMenuItem;
    N2: TMenuItem;
    About1: TMenuItem;
    csNT: TClientSocket;
    tiNT: TRxTrayIcon;
    Timer1: TTimer;
    pagemain: TPageControl;
    tabGeneral: TTabSheet;
    TabSheet1: TTabSheet;
    pnlOnly: TPanel;
    pbSend: TPaintBox;
    pbReceive: TPaintBox;
    lblSent: TLabel;
    lblReceived: TLabel;
    pbIcon: TPaintBox;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    received: TLabel;
    sent: TLabel;
    grpcon: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ipaddress: TLabel;
    lxinterface: TLabel;
    Label5: TLabel;
    status: TLabel;
    procedure Exit1Click(Sender: TObject);
    procedure Configuration1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure csNTConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure csNTRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormDestroy(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure csNTDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csNTError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure tiNTClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Showhelp1Click(Sender: TObject);
    procedure pbIconPaint(Sender: TObject);
    procedure pnlOnlyClick(Sender: TObject);
    procedure pbIconDblClick(Sender: TObject);
    procedure pbSendDblClick(Sender: TObject);
    procedure pbReceiveDblClick(Sender: TObject);
    procedure pnlOnlyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbSendMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbIconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbReceiveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tabGeneralMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grpconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GroupBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grpconDblClick(Sender: TObject);
    procedure GroupBox1DblClick(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FLastReceiveData : Int64;
    FInterface: string;
    FPassword : string;
    FSendData, FReceiveData: TList;
    FCurrentSend, FLastSend, FCurrentReceive, FLastReceive: LongWord;
    FSendAvg, FReceiveAvg: Double;
    FUpdates: Int64;
    FError: Boolean;
    FErrorMsg: string;
    FOriginalCaption: string;
    FPanelOnlyMode : boolean;
    FMaxData: Int64;
    FMaxSend, FMaxReceive: Int64;
    FNewInterface, FNewColors, FLogData, Fshowtrafficintitle: Boolean;
    FTotalSent, FTotalReceived: Int64;
    FTotalStart: TDateTime;
    FCurUP,FCurDown : string;

    procedure BreakAndProcessData(AData: string;Socket: TCustomWinSocket);
    procedure ProcessData(AData: string;Socket: TCustomWinSocket);
    procedure SetData(AData: string);
    procedure AppMinimize(Sender: TObject);

    procedure DataChanged;
    procedure LoadConfig;
    procedure CheckMaxData;
    function FormatBPS(AValue: Int64): string;
    function ConvBytes(B: Int64): string;
    procedure SetDisconnected;
    procedure DrawIconBox(B: TBitmap; R: TRect; C: TColor; AValue, AMax: Int64);
    procedure DrawIconGauge(B: TBitmap; R: TRect; AValue, AMax: Int64);
    function GetIconColor(Value, Max: Int64): TColor;
    procedure MakeIcon(ASend, AReceive: Int64);
    procedure DragForm(Button: TMouseButton);
    procedure DoSetIcon(ASend, AReceive: Int64);
    procedure HideTitlebar(hide:boolean);
  public
    { Public declarations }
  end;

const
  CRLF = #13#10;
  BreakDataInvalidChars = [#13, #10];

const
  NTICON_ERROR = 0;
  NTICON_LOW = 1;
  NTICON_HIGH = 2;
  NTICON_SENDHIGH = 3;
  NTICON_RECVHIGH = 4;

var
  NetTrafForm: TNetTrafForm;

implementation

uses NFConfig, Registry, About;

{$R *.DFM}
{$R NTIcons.res}

procedure BreakData(Data: string; DataList: TStringList);
var
  CurData: string;
  I: Integer;
begin
     CurData := '';
     for I := 1 to Length(Data) do
     begin
          if Data[I] in BreakDataInvalidChars then
          begin
               if CurData <> '' then
                  DataList.Add(CurData);
               CurData := '';
          end
          else
              CurData := CurData + Data[I];
     end;
     if CurData <> '' then DataList.Add(CurData);
end;

procedure TNetTrafForm.Exit1Click(Sender: TObject);
begin
     Close;
end;

procedure TNetTrafForm.Configuration1Click(Sender: TObject);
var
  NeedReload: Boolean;
begin
     Timer1.Enabled := False;
     try
        NetTrafConfigForm := TNetTrafConfigForm.Create(Self);
        try
           NeedReload := NetTrafConfigForm.ShowModal = mrOk;
        finally
           NetTrafConfigForm.Free;
        end;

        if NeedReload then
           LoadConfig;
     finally
        Timer1.Enabled := True;
     end;
end;

procedure TNetTrafForm.FormCreate(Sender: TObject);
var
  Icon: TIcon;
begin
     FSendData := TList.Create;
     FReceiveData := TList.Create;

     Application.OnMinimize := AppMinimize; 

     Icon := TIcon.Create;
     try
        Icon.Handle := LoadIcon(hInstance, 'NT_ERROR');
        tiNT.Icons.Add(Icon);

        Icon.Handle := LoadIcon(hInstance, 'NT_LOW');
        tiNT.Icons.Add(Icon);

        Icon.Handle := LoadIcon(hInstance, 'NT_HIGH');
        tiNT.Icons.Add(Icon);

        Icon.Handle := LoadIcon(hInstance, 'NT_SENDHIGH');
        tiNT.Icons.Add(Icon);

        Icon.Handle := LoadIcon(hInstance, 'NT_RECVHIGH');
        tiNT.Icons.Add(Icon);
     finally
        Icon.Free;
     end;

     FOriginalCaption := Caption;
     FNewInterface := False;
     FNewColors := False;
     FLogData := False;

     FError := True;
     DoSetIcon(-1, -1);
     FError := False;
     
     tiNT.Active := True;

     Timer1.Interval := 10000;
     Timer1.Enabled := True;

     LoadConfig;

     Width := 400;
     Height := 280;
     pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.HideTitlebar(hide:boolean);
Var
 Save : LongInt;
Begin
 If BorderStyle=bsNone then Exit;
 Save:=GetWindowLong(Handle,gwl_Style);
 if (hide) then
 begin
 If (Save and ws_Caption)=ws_Caption then Begin
   Case BorderStyle of
     bsSingle,
     bsSizeable : SetWindowLong(Handle,gwl_Style,Save and
       (Not(ws_Caption)) or ws_border);
     bsDialog : SetWindowLong(Handle,gwl_Style,Save and
       (Not(ws_Caption)) or ds_modalframe or ws_dlgframe);
   End;
   Height:=Height-getSystemMetrics(sm_cyCaption);
   Refresh;
 End;
 
 end
 else
 begin
 if (Save and WS_CAPTION) <> WS_CAPTION then
 begin
   case BorderStyle of
     bsSingle,
     bsSizeable: SetWindowLong(Handle, GWL_STYLE, Save or WS_CAPTION or
         WS_BORDER);
     bsDialog: SetWindowLong(Handle, GWL_STYLE,
         Save or WS_CAPTION or DS_MODALFRAME or WS_DLGFRAME);
   end;
   Height := Height + GetSystemMetrics(SM_CYCAPTION);
   Refresh;
 end;
 end;
end;

procedure TNetTrafForm.LoadConfig;
var
  R: TRegistry;
begin
     if csNT.Active then csNT.Close;

     FSendAvg := 0;
     FReceiveAvg := 0;
     FLastSend := LongWord(-1);
     FLastReceive := LongWord(-1);
     FCurrentSend := LongWord(-1);
     FCurrentReceive := LongWord(-1);
     FCurrentSend := 1;
     FCurrentReceive := 1;
     FSendData.Clear;
     FReceiveData.Clear;
     FError := False;
     FMaxData := 1;
     FMaxSend := 1;
     FMaxReceive := 1;
     FUpdates := 0;
     FTotalSent := 0;
     FTotalReceived := 0;
     FTotalStart := Now;

     sbNT.Panels[0].Text := '';
     sbNT.Panels[1].Text := '';
     sbNT.Panels[2].Text := '';

     R := TRegistry.Create;
     try
        R.OpenKey(RegNetTrafKey, True);
        if R.ValueExists('Host') then
           csNT.Host := R.ReadString('Host');
        if R.ValueExists('Port') then
           csNT.Port := R.ReadInteger('Port');
        if R.ValueExists('Interface') then
           FInterface := R.ReadString('Interface');
        if R.ValueExists('Password') then
           FPassword := R.ReadString('Password');
        if R.ValueExists('NewItf') then
           FNewInterface := R.ReadBool('NewItf');
        if R.ValueExists('NewColor') then
           FNewColors := R.ReadBool('NewColor');
        if R.ValueExists('LogData') then
           FLogData := R.ReadBool('LogData');
        if R.ValueExists('ShowTrafficInTitle') then
           Fshowtrafficintitle := R.ReadBool('ShowTrafficInTitle');


        R.CloseKey;
     finally
        R.Free;
     end;

     tiNT.Hint := Format('NetTraf [%s] %s', [csNT.Host, FInterface]);

     if csNT.Host <> '' then
     begin
          try
             csNT.Open;
          except
             SetDisconnected;
             Exit;
          end;
     end;
end;

procedure TNetTrafForm.csNTConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
     FErrorMsg := '';
     status.Caption := 'Connected!';
     Socket.SendText('PASS '+FPassword+CRLF);
     ipaddress.Caption := '0.0.0.0';
     lxinterface.Caption := '?';
     FLastReceiveData := 0;
end;

procedure TNetTrafForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     Timer1.Enabled := False;
     if csNT.Active then
        csNT.Close;
end;

procedure TNetTrafForm.ProcessData(AData: string;Socket: TCustomWinSocket);
var PassErrors : String;
begin
     FError := False;

     if Copy(AData, 1, 4) = 'DATA' then
     begin
          SetData(Copy(AData, 6, Length(AData)));
     end;

     if Copy(AData, 1, 5) = 'NDATA' then
     begin
          SetData(Copy(AData, 7, Length(AData)));
          status.Caption := 'Connected!';
     end;

     if Copy(AData, 1, 6) = 'IPADDR' then
     begin
       ipaddress.caption := trim(copy(AData,7,length(AData)));
       lxinterface.Caption := FInterface;
     end;

     if Copy(AData, 1, 5) = 'ERROR' then
     begin
          FErrorMsg := 'Invalid interface';
          ipaddress.Caption := '0.0.0.0';
          FError := True;
     end;

     if Copy(AData, 1, 4) = 'PASS' then
     begin
          PassErrors := copy(AData,6,length(AData));
          if (PassErrors <> 'OK') then
          begin
           FErrorMsg := 'Invalid Password!';
           FError := True;
          end
          else
          begin
            if FNewInterface then
             Socket.SendText('NITF '+FInterface+CRLF)
            else
             Socket.SendText('ITF '+FInterface+CRLF);


          end;
     end;

     DataChanged;
end;

procedure TNetTrafForm.csNTRead(Sender: TObject; Socket: TCustomWinSocket);
begin
     FLastReceiveData := 0;
     BreakAndProcessData(Socket.ReceiveText,Socket);
end;

procedure TNetTrafForm.FormDestroy(Sender: TObject);
begin
     tiNT.Active := False;
     FSendData.Free;
     FReceiveData.Free;
end;

procedure TNetTrafForm.DataChanged;
begin
     if (FErrorMsg = '') then
      FErrorMsg := 'Unknown Error';

     if FError then
        Caption := FOriginalCaption + ' - ERROR: '+FErrorMsg
     else
        Caption := FOriginalCaption;

     if (FError) then
      status.Caption := FErrorMsg;
     Caption := Caption + ' - ' + FInterface;

     sent.Caption := '?';
     received.Caption := '?';     

(*
     if FNewInterface then
     begin
          if (FStartSend = LongWord(-1)) then
             FStartSend := 0;
          if (FStartReceive = LongWord(-1)) then
             FStartReceive := 0;
     end
     else
     begin
          if (FStartSend = LongWord(-1)) or (FCurrentSend < FStartSend) then
             FStartSend := FCurrentSend;
          if (FStartReceive = LongWord(-1)) or (FCurrentReceive < FStartReceive) then
             FStartReceive := FCurrentReceive;
     end;
*)
     if not FError then
     begin
          Inc(FUpdates);
          if FLogData then
          begin
               FTotalSent := FTotalSent + FCurrentSend;
               FTotalReceived := FTotalReceived + FCurrentReceive;
          end;

          FSendAvg := ((FSendAvg * (FUpdates-1)) + FCurrentSend) / FUpdates;
          FReceiveAvg := ((FReceiveAvg * (FUpdates-1)) + FCurrentReceive) / FUpdates;
     end;

     if FLogData then
     begin
          sbNT.Panels[0].Text := 'Sent: '+ConvBytes(FTotalSent);
          sbNT.Panels[1].Text := 'Recv: '+ConvBytes(FTotalReceived);
          sbNT.Panels[2].Text := 'Log started at '+DateTimeToStr(FTotalStart);
     end;

     DoSetIcon(FCurrentSend, FCurrentReceive);

     pbPaint(pbSend);
     pbPaint(pbReceive);
     pbIconPaint(pbIcon);
end;

procedure TNetTrafForm.SetData(AData: string);
var
  I: Integer;
  SpaceFound: Boolean;
  V1, V2: string;
  V1I, V2I: LongWord;
begin
     SpaceFound := False;

     // Remove non-number chars
     V1 := ''; V2 := '';
     for I := 1 to Length(AData) do
     begin
          if (AData[I] in ['0'..'9']) then
          begin
               if SpaceFound then
                  V2 := V2 + AData[I]
               else
                   V1 := V1 + AData[I]
          end;

          if AData[I] = ' ' then
             SpaceFound := True;
     end;
     if (V1 = '') or (V2 = '') then Exit;

     try
     V1I := StrToInt(V1);
     V2I := StrToInt(V2);
     except
      exit;
     end;
     FCurrentSend := V2I;
     FCurrentReceive := V1I;
     if not FNewInterface then
     begin
          if FLastSend <> LongWord(-1) then
             FCurrentSend := FCurrentSend - FLastSend
          else
              FCurrentSend := 0;
          if FLastReceive <> LongWord(-1) then
             FCurrentReceive := FCurrentReceive - FLastReceive
          else
              FCurrentReceive := 0;
     end;

     FReceiveData.Add(Pointer(FCurrentReceive));
     FSendData.Add(Pointer(FCurrentSend));

     FLastSend := V2I;
     FLastReceive := V1I;

     if FSendData.Count > 1 then
        while FSendData.Count > pbSend.Width do
           FSendData.Delete(0);
     if FReceiveData.Count > 1 then
        while FReceiveData.Count > pbReceive.Width do
           FReceiveData.Delete(0);

     CheckMaxData;
end;

// Draws on an offscreen bitmap
procedure TNetTrafForm.pbPaint(Sender: TObject);
var
  CurList: TList;
  CurPB: TPaintBox;
  L, LL, AV: Int64;
  I : integer;
  LastData: Int64;
  S,S2: string;
  R: TRect;
  B: TBitmap;
  L1,L2 : Int64;
begin
     //imgfortray.Canvas.Brush.Color := clred;
     //imgfortray.Canvas.Pen.Color := clred;

 //    imgfortray.Canvas.Font.Size := 4;
  //   imgfortray.Canvas.Font.name := 'Lucida Console';

     AV := 0;
     if Sender = pbSend then
     begin
          //imgfortray.Canvas.FillRect(bounds(0,0,16,16));
          CurList := FSendData;
          if FUpdates > 0 then
             AV := Trunc(FSendAvg);
          if (CurList.Count > 0) then
          begin
           L := Int64(CurList.Items[CurList.Count-1]);
           S := FormatBPS(L);
           S2 := FormatBPS(AV);
           sent.Caption := s + ' (~' + S2 + ')';
           FCurUP := s;
        //   imgfortray.Canvas.Font.Color := clred;
         //  imgfortray.Canvas.TextOut(1,1,s);
          end;
     end
     else
     begin
          CurList := FReceiveData;
          if FUpdates > 0 then
             AV := Trunc(FReceiveAvg);

          if (CurList.Count > 0) then
          begin
           L := Int64(CurList.Items[CurList.Count-1]);
           S := FormatBPS(L);
           S2 := FormatBPS(AV);
           received.Caption := s + ' (~' + S2 + ')';
           FCurDown := s;
     //      imgfortray.Canvas.Font.Color := clGreen;
     //      imgfortray.Canvas.TextOut(1,8,s);
          end;

     end;

     if (Fshowtrafficintitle) then
      Application.Title := '[S: ' + FCurUP + ' - R: ' + FCurDown+ '] - ' + FOriginalCaption
     else
      Application.Title := FOriginalCaption;

     //if CurList.Count = 0 then Exit;

     CurPB := Sender as TPaintBox;

     B := TBitmap.Create;
     try
        B.Width := CurPB.Width;
        B.Height := CurPB.Height;

        with B.Canvas do
        begin
             Brush.Color := clBlack;
             FillRect(CurPB.ClientRect);

             for I := 0 to CurList.Count-1 do
             begin
                  L := Int64(CurList.Items[I]);
                  LL := CurPB.Height - Trunc(CurPB.Height * (L / FMaxData));
                  if Sender = pbSend then
                   Pen.Color := RGB(100+Trunc((155/CurList.Count) * I), 0, 0)
                  else
                   Pen.Color := RGB(0, 0, 100+Trunc((155/CurList.Count) * I));

                  MoveTo(I-1, LL);
                  LineTo(I-1, CurPB.Height);
             end;

             // Draws a line showing the current position
             if CurList.Count < CurPB.Width then
             begin
                  Pen.Color := clGray;
                  MoveTo(CurList.Count, 0);
                  LineTo(CurList.Count, CurPB.Height);
             end;

             // Draws a line showing the current average position
             if AV < FMaxData then
             begin
                  Pen.Style := psDot;
                  Pen.Color := clGray;
                  L := CurPB.Height - Trunc(CurPB.Height * (AV / FMaxData));
                  MoveTo(0, L);
                  LineTo(CurPB.Width, L);
                  Pen.Style := psSolid;

                  if Showhelp1.Checked then
                  begin
                       SetBkMode(Handle, TRANSPARENT);
                       Font.Name := 'Arial';
                       Font.Size := 7;
                       Font.Color := clGray;
                       TextOut(0, L-TextHeight('M'), 'Average');
                  end;
             end;

             if CurList.Count > 0 then
             begin
                  Font.Name := 'Arial';
                  Font.Size := 10;
                  Font.Color := clWhite;

                  // Draws the current rate
                  SetBkMode(Handle, TRANSPARENT);
                  
                  L := Int64(CurList.Items[CurList.Count-1]);
                  S := FormatBPS(L);
                  if Showhelp1.Checked then
                     S := 'Current: '+S;

                  R := CurPB.ClientRect;
                  DrawText(Handle, PChar(S), -1, R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

                  // Draws the average rate
                  Font.Color := clWhite;
                  Font.Size := 7;
                  S := FormatBPS(AV);
                  if Showhelp1.Checked then
                     S := 'Average: '+S;
                  DrawText(Handle, PChar(S), -1, R, DT_CENTER or DT_BOTTOM or DT_SINGLELINE);

                  // Draws the maximum value
                  Font.Size := 7;
                  Font.Color := clOlive;

                  R := CurPB.ClientRect;
                  S := FormatBPS(FMaxData);
                  if ShowHelp1.Checked then
                     S := 'Max: '+S;
                  DrawText(Handle, PChar(S), -1, R, DT_TOP or DT_RIGHT or DT_SINGLELINE);

                  // Draws the minimum value
                  R := CurPB.ClientRect;
                  S := FormatBPS(0);
                  DrawText(Handle, PChar(S), -1, R, DT_BOTTOM or DT_RIGHT or DT_SINGLELINE);
             end;
        end;

        CurPB.Canvas.Draw(0, 0, B);
       L1 := 0;
       L2 := 0;
       if (FSendData.Count > 0) then
       begin
       L1 := Int64(FSendData.Items[FSendData.Count-1]);;
       L2 := Int64(FReceiveData.Items[FReceiveData.Count-1]);;
       end;
       tiNT.Hint := Format('NetTraf [%s] %s'#13'Sent: %s'#13'Recv: %s', [csNT.Host, FInterface,FormatBPS(L1),FormatBPS(L2)]);
       
     finally
        B.Free;
     end;
end;

procedure TNetTrafForm.BreakAndProcessData(AData: string;Socket: TCustomWinSocket);
var
  DL: TStringList;
  I: Integer;
begin
     DL := TStringList.Create;
     try
        BreakData(AData, DL);
        for I := 0 to DL.Count-1 do
        begin
             ProcessData(DL[I],Socket);
        end;
     finally
        DL.Free;
     end;
end;

procedure TNetTrafForm.DoSetIcon(ASend, AReceive: Int64);
var
  SendHigh, RecvHigh: Boolean;
  Index: Integer;
begin
     MakeIcon(ASend, AReceive);
     Exit;

     if FError then
     begin
          Index := NTICON_ERROR;
     end
     else
     begin
          SendHigh := ASend > 0;
          RecvHigh := AReceive > 0;

          if (SendHigh) and (RecvHigh) then
             Index := NTICON_HIGH
          else
              if (SendHigh) then
                 Index := NTICON_SENDHIGH
              else
                  if (RecvHigh) then
                     Index := NTICON_RECVHIGH
                  else
                      Index := NTICON_LOW;
     end;
     tiNT.Icon.Assign(tiNT.Icons.Icons[Index]);
end;

procedure TNetTrafForm.CheckMaxData;
var
  I, C: Integer;
  CurList: TList;
  LastData: Integer;
begin
     FMaxData := 0;
     FMaxSend := 0;
     FMaxReceive := 0;
     for C := 0 to 1 do
     begin
          if C = 0 then CurList := FSendData else CurList := FReceiveData;

          for I := 0 to CurList.Count-1 do
          begin
               if Integer(CurList[I]) > FMaxData then
                  FMaxData := Int64(CurList[I]);

               if C = 0 then
               begin
                    if Integer(CurList[I]) > FMaxSend then
                       FMaxSend := Int64(CurList[I]);
               end
               else
               begin
                    if Integer(CurList[I]) > FMaxReceive then
                       FMaxReceive := Int64(CurList[I]);
               end;
          end;
     end;

     if FMaxData <= 0 then
        FMaxData := 1;
     if FMaxSend <= 0 then
        FMaxSend := 1;
     if FMaxReceive <= 0 then
        FMaxReceive := 1;
end;

// Converts bytes to KB, GB, MB, etc
function TNetTrafForm.ConvBytes(B: Int64): string;
const
  BitStr: array[0..4] of string = (' bytes', 'KB', 'MB', 'GB', 'TB');
var
  N: Double;
  CT: Int64;
begin
     CT := 0;
     N := B;

     while N > 1024 do
     begin
          if CT < 4 then Inc(CT);
          N := N / 1024;
     end;

     Result := FormatFloat('###,##,##0.00', N) + BitStr[CT];
end;

function TNetTrafForm.FormatBPS(AValue: Int64): string;
begin
     if AValue < 1024 then
        Result := IntToStr(AValue) + ' bps'
     else
         Result := FormatFloat('0.0 kb/s', AValue / 1024);
end;

procedure TNetTrafForm.SetDisconnected;
begin
     FError := True;
     DataChanged;
     DoSetIcon(-1, -1);
     ipaddress.Caption := '0.0.0.0';
     lxinterface.Caption := '?';
end;

procedure TNetTrafForm.csNTDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
     SetDisconnected;
end;

procedure TNetTrafForm.csNTError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
     //FErrorMsg := GetSocketError(ErrorCode);
     FErrorMsg := 'TCP Error: ' + inttostr(ErrorCode);
     ErrorCode := 0;
     SetDisconnected;
end;

procedure TNetTrafForm.Timer1Timer(Sender: TObject);
begin
 if not csNT.Active then
   LoadConfig
 else
 begin
  FLastReceiveData := FLastReceiveData + 1;
  if (FLastReceiveData > 5) then
  begin
   FLastReceiveData := 0;
   LoadConfig();
  end;
 end;
end;

procedure TNetTrafForm.tiNTClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ShowWindow(Application.Handle, SW_RESTORE);
 show();
 Application.BringToFront;
end;

procedure TNetTrafForm.AppMinimize(Sender: TObject);
begin
    Hide;
    ShowWindow(Application.Handle, SW_HIDE);

end;

procedure TNetTrafForm.FormResize(Sender: TObject);
var
  IconSizeX : integer;
  IconSizeY : integer;
const
  BORDER_SKIP = 20;
begin
     {Get the icon size}
     IconSizeX := GetSystemMetrics(SM_CXICON);
     IconSizeY := GetSystemMetrics(SM_CYICON);

     lblReceived.Left := (Width div 2) + (IconSizeX div 2);
     pbReceive.Left := (Width div 2) + (IconSizeX div 2);
     pbSend.Width := (Width div 2) - (IconSizeX div 2) - BORDER_SKIP;
     pbReceive.Width := pbSend.Width;

     pbSend.Height := Height - pbSend.Top - 50;
     pbReceive.Height := Height - pbReceive.Top - 50;

     if (FPanelOnlyMode) then
     begin
      pbSend.Height := pbSend.Height - sbNT.Height - 30;
      pbReceive.Height := pbReceive.Height - sbNT.Height - 30;
     end;
     pbIcon.Left := pbSend.Left + pbSend.Width + (BORDER_SKIP div 2) - 2;
     pbIcon.Width := IconSizeX;
     pbIcon.Height := pbSend.Height;
end;

procedure TNetTrafForm.About1Click(Sender: TObject);
begin
     AboutForm := TAboutForm.Create(Self);
     AboutForm.ShowModal;
     AboutForm.Free;
end;

procedure TNetTrafForm.Showhelp1Click(Sender: TObject);
begin
     Showhelp1.Checked := not Showhelp1.Checked;
end;

procedure TNetTrafForm.MakeIcon(ASend, AReceive: Int64);
var
  IconSizeX : integer;
  IconSizeY : integer;
  AndMask : TBitmap;
  XOrMask : TBitmap;
  IconInfo : TIconInfo;
  Icon : TIcon;
  RS, RR: TRect;
begin
    {Get the icon size}
     IconSizeX := GetSystemMetrics(SM_CXICON);
     IconSizeY := GetSystemMetrics(SM_CYICON);

    {Create the "And" mask}
     AndMask := TBitmap.Create;
     AndMask.Monochrome := true;
     AndMask.Width := IconSizeX;
     AndMask.Height := IconSizeY;

    {Draw on the "And" mask}
     RS := Rect(0, 0, Trunc((IconSizeX / 5)*3), Trunc((IconSizeY / 5)*3));
     RR := Rect(Trunc((IconSizeX / 5)*2), Trunc((IconSizeY / 5)*2), IconSizeX-1, IconSizeY-1);

     AndMask.Canvas.Brush.Color := clWhite;
     AndMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
     AndMask.Canvas.Brush.Color := clBlack;
     AndMask.Canvas.FillRect(RS);
     AndMask.Canvas.FillRect(RR);

    {Create the "XOr" mask}
     XOrMask := TBitmap.Create;
     XOrMask.PixelFormat := pf24bit;
     XOrMask.Width := IconSizeX;
     XOrMask.Height := IconSizeY;

    {Draw on the "XOr" mask}
     XOrMask.Canvas.Brush.Color := ClBlack;
     XOrMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
     DrawIconBox(XOrMask, RS, GetIconColor(ASend, FMaxData), ASend, FMaxData);
     DrawIconBox(XOrMask, RR, GetIconColor(AReceive, FMaxData), AReceive, FMaxData);

    {Create a icon}
     Icon := TIcon.Create;
     IconInfo.fIcon := true;
     IconInfo.xHotspot := 0;
     IconInfo.yHotspot := 0;
     IconInfo.hbmMask := AndMask.Handle;
     IconInfo.hbmColor := XOrMask.Handle;
     Icon.Handle := CreateIconIndirect(IconInfo);

    {Destroy the temporary bitmaps}
     AndMask.Free;
     XOrMask.Free;

    {Assign the application icon}
     tiNT.Icon.Assign(Icon);

     //Application.Icon := Icon;
     //InvalidateRect(Application.Handle, nil, true);

    {Free the icon}
     Icon.Free;
end;

function TNetTrafForm.GetIconColor(Value, Max: Int64): TColor;
begin
     if FError then
     begin
          Result := RGB(240, 0, 0)
     end
     else
     begin
          if FNewColors then
          begin
               if Value > 0 then
                  //Result := RGB(0, 10 + Trunc(240 * (Value / Max)), 0)
                  Result := RGB(0, 240, 0)
               else
                   //Result := RGB(0, 100, 0);
                   Result := clBtnFace;
          end
          else
          begin
               if Value > 0 then
                  Result := RGB(0, 240, 0)
               else
                   Result := RGB(0, 100, 0);
          end;
     end;
end;

procedure TNetTrafForm.DrawIconBox(B: TBitmap; R: TRect; C: TColor; AValue, AMax: Int64);
const
  BORDER = 1;
  SHADE = 1;
var
  SaveR: TRect;
begin
     B.Canvas.Brush.Color := clSilver;
     B.Canvas.FillRect(Rect(R.Left+SHADE, R.Top+SHADE, R.Left+SHADE+BORDER, R.Bottom));
     B.Canvas.FillRect(Rect(R.Right-BORDER, R.Top+SHADE, R.Right, R.Bottom));
     B.Canvas.FillRect(Rect(R.Left+SHADE, R.Top+SHADE, R.Right, R.Top+BORDER+SHADE));
     B.Canvas.FillRect(Rect(R.Left+SHADE, R.Bottom-BORDER, R.Right, R.Bottom));

     B.Canvas.Brush.Color := clBlack;
     B.Canvas.FillRect(Rect(R.Left, R.Top, R.Left+SHADE, R.Bottom));
     B.Canvas.FillRect(Rect(R.Left+SHADE, R.Top, R.Right, R.Top+SHADE));

     R := Rect(R.Left+BORDER+SHADE, R.Top+BORDER+SHADE, R.Right-BORDER, R.Bottom-BORDER);
     SaveR := R;
     if (AValue > 0) and (not FError) and FNewColors then
     begin
          B.Canvas.Pen.Color := clBlack;
          B.Canvas.Brush.Color := clBlack;
          B.Canvas.FillRect(R);
          R.Top := R.Top + Trunc((R.Bottom-R.Top) * Abs((AValue / AMax)-1));
     end;

     B.Canvas.Pen.Color := C;
     B.Canvas.Brush.Color := C;
     B.Canvas.FillRect(R);

     //DrawIconGauge(B, SaveR, AValue, AMax);     
end;

procedure TNetTrafForm.pbIconPaint(Sender: TObject);
begin
     pbIcon.Canvas.Draw(0, (pbIcon.Height div 2) - (tiNT.Icon.Height div 2), tiNT.Icon);
end;

procedure TNetTrafForm.DrawIconGauge(B: TBitmap; R: TRect; AValue,
  AMax: Int64);
begin
     if AMax = 0 then Exit;

     B.Canvas.Pen.Color := clWhite;
     B.Canvas.Pen.Width := 1;
     B.Canvas.MoveTo(R.Left + ((R.Right-R.Left) div 2), R.Bottom);
     B.Canvas.LineTo(R.Left + Trunc((R.Right-R.Left) * (AValue/AMax)),  R.Top);
end;

procedure TNetTrafForm.pnlOnlyClick(Sender: TObject);
begin
 if (FPanelOnlyMode) then
 begin
  NetTrafForm.formstyle := fsStayOnTop;
  File1.Visible := false;
  Help1.Visible := false;
  FPanelOnlyMode := false;
  HideTitlebar(true);
  sbNT.Visible := false;
 end
 else
 begin
  NetTrafForm.formstyle := fsNormal;
  File1.Visible := true;
  Help1.Visible := true;
  FPanelOnlyMode := true;
  HideTitlebar(false);
  sbNT.Visible := true;
  NetTrafForm.Height := NetTrafForm.Height + 19;
 end;
 FormResize(sender);
end;

procedure TNetTrafForm.pbIconDblClick(Sender: TObject);
begin
pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.pbSendDblClick(Sender: TObject);
begin
pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.pbReceiveDblClick(Sender: TObject);
begin
pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.DragForm(Button: TMouseButton);
const
  SC_DRAGMOVE = $F012;
begin
  if Button = mbleft then
  begin
    ReleaseCapture;
    NetTrafForm.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TNetTrafForm.pnlOnlyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.pbSendMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.pbIconMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.pbReceiveMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.tabGeneralMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.grpconMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.GroupBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

procedure TNetTrafForm.grpconDblClick(Sender: TObject);
begin
pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.GroupBox1DblClick(Sender: TObject);
begin
pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.Panel1DblClick(Sender: TObject);
begin
pnlOnlyClick(Sender);
end;

procedure TNetTrafForm.Panel1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
DragForm(Button);
end;

end.
