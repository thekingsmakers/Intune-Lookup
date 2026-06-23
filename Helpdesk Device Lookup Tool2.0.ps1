# =====================================================
# MOEHE — Intune Device Lookup Tool  v4.1
# =====================================================
# SETUP INSTRUCTIONS
# ------------------
# 1. In Entra Portal → App Registrations → your app:
#      Authentication → Add platform → Mobile and desktop applications
#      Add EXACTLY this redirect URI:  http://localhost:8765/
#
# 2. Required DELEGATED permissions (for Entra login):
#      openid, profile, email, User.Read
#
# 3. Required APPLICATION permission (for Intune queries):
#      DeviceManagementManagedDevices.Read.All  (admin consent required)
#      Create a client secret under Certificates & secrets.
#
# 4. Fill in ALL six values in the CONFIGURATION block below.
#    Nothing will be prompted at runtime — all credentials are hardcoded.
# =====================================================

# ── ASSEMBLIES  (must be before everything) ──────────
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@
$type   = Add-Type -MemberDefinition $memberDefinition `
            -Name "Win32ShowWindow" -Namespace "Win32Fn" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# CONFIGURATION — fill these in
# =====================================================

$AUTH_TenantId      = ""          # e.g. "2d-xxxx-xxxx-xxxxxxxxxxxx"
$AUTH_ClientId      = ""          # App Registration client ID
$AUTH_GroupObjectId = ""   # Helpdesk security group Object ID

# Fixed callback port — must match the redirect URI registered in Entra EXACTLY:
#   http://localhost:8765/
$AUTH_CallbackPort  = 8765
$AUTH_RedirectUri   = "http://localhost:$AUTH_CallbackPort/"
$AUTH_Scopes        = "openid profile email User.Read offline_access"

# ── App-registration credentials for Intune/Graph queries ──
# Fill in all three — no prompts will appear at runtime.
$APP_TenantId     = ""   # usually same as $AUTH_TenantId
$APP_ClientId     = ""   # App Registration client ID (can be same or separate)
$APP_ClientSecret = ""   # Entra → App Registration → Certificates & secrets

# Geofence — allowed IPs / CIDRs
$AllowedIPs = @(
    ""
    ""
    ""
)

# =====================================================
# DESIGN TOKENS
# =====================================================
$C_NavyDark = [System.Drawing.Color]::FromArgb(10,  25,  60)
$C_Navy     = [System.Drawing.Color]::FromArgb(15,  40,  90)
$C_Teal     = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_White    = [System.Drawing.Color]::White
$C_Surface  = [System.Drawing.Color]::FromArgb(245, 247, 251)
$C_Border   = [System.Drawing.Color]::FromArgb(220, 226, 235)
$C_TextPri  = [System.Drawing.Color]::FromArgb(18,  30,  55)
$C_TextSec  = [System.Drawing.Color]::FromArgb(100, 116, 139)
$C_RowAlt   = [System.Drawing.Color]::FromArgb(248, 250, 253)
$C_SelBg    = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_Green    = [System.Drawing.Color]::FromArgb(22,  163, 74)
$C_Red      = [System.Drawing.Color]::FromArgb(220, 38,  38)
$C_Orange   = [System.Drawing.Color]::FromArgb(234, 88,  12)

$F_UI     = New-Object System.Drawing.Font("Segoe UI", 9)
$F_UISm   = New-Object System.Drawing.Font("Segoe UI", 8)
$F_UIBold = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$F_Sub    = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)
$F_Tiny   = New-Object System.Drawing.Font("Segoe UI", 7.5)
$F_Hero   = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$F_HeroSm = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

# =====================================================
# PKCE HELPERS
# =====================================================

function New-PKCEPair {
    $bytes   = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $verifier = [Convert]::ToBase64String($bytes) -replace '\+','-' -replace '/','_' -replace '='
    $sha      = [System.Security.Cryptography.SHA256]::Create()
    $hash     = $sha.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($verifier))
    $challenge = [Convert]::ToBase64String($hash) -replace '\+','-' -replace '/','_' -replace '='
    return @{ Verifier = $verifier; Challenge = $challenge }
}

function New-StateToken {
    $bytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ([Convert]::ToBase64String($bytes) -replace '[^a-zA-Z0-9]','')
}

# =====================================================
# ENTRA AUTH — PKCE / AUTH-CODE FLOW
# Fixed port listener — no dynamic port issues
# =====================================================

function Invoke-EntraLogin {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$RedirectUri,
        [int]   $CallbackPort,
        [string]$Scopes,
        [string]$GroupObjectId
    )

    # Validate config
    if ([string]::IsNullOrWhiteSpace($TenantId) -or
        [string]::IsNullOrWhiteSpace($ClientId) -or
        [string]::IsNullOrWhiteSpace($GroupObjectId)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Entra login is not configured.`n`nPlease fill in:`n  `$AUTH_TenantId`n  `$AUTH_ClientId`n  `$AUTH_GroupObjectId`n`nat the top of the script.",
            "MOEHE — Configuration Required",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        return $null
    }

    $pkce  = New-PKCEPair
    $state = New-StateToken

    $enc   = { param($s) [Uri]::EscapeDataString($s) }
    $authUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/authorize" +
               "?client_id=$ClientId" +
               "&response_type=code" +
               "&redirect_uri=$($enc.Invoke($RedirectUri))" +
               "&response_mode=query" +
               "&scope=$($enc.Invoke($Scopes))" +
               "&state=$state" +
               "&code_challenge=$($pkce.Challenge)" +
               "&code_challenge_method=S256" +
               "&prompt=select_account"

    # ── Start HttpListener on fixed port ─────────────
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($RedirectUri)   # e.g. "http://localhost:8765/"

    try {
        $listener.Start()
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Could not start local listener on port $CallbackPort.`n`n" +
            "Another process may be using that port.`n`n$($_.Exception.Message)",
            "MOEHE — Auth Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }

    # Open the browser AFTER the listener is ready
    Start-Process $authUrl

    # ── Wait for callback using a background job ──────
    # We cannot block the thread (WinForms needs DoEvents),
    # so we poll GetContextAsync via a thread-safe task.
    $contextTask = $listener.GetContextAsync()
	$deadline    = [datetime]::UtcNow.AddMinutes(3)

	while (-not $contextTask.IsCompleted -and [datetime]::UtcNow -lt $deadline) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

	if (-not $contextTask.IsCompleted) {
    $listener.Stop()
    return $null
}

$context = $contextTask.Result

# ✅ Send response FIRST
$context.Response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
$context.Response.OutputStream.Close()

# ✅ THEN stop listener
$listener.Stop()

    if (-not $contextTask.IsCompleted -or $contextTask.IsFaulted) {
        [System.Windows.Forms.MessageBox]::Show(
            "Authentication timed out or failed.`nPlease try again.",
            "MOEHE — Auth Timeout",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        return $null
    }

    $context = $contextTask.Result

    # Send a friendly close page to the browser
    $html = @"
<!DOCTYPE html>
<html>
<head>
<title>Login Successful</title>
<style>
  body {
    font-family: 'Segoe UI', sans-serif;
    background: #0a193c;
    display:flex;
    align-items:center;
    justify-content:center;
    height:100vh;
    margin:0;
  }
  .card {
    background:#0f2856;
    border-radius:12px;
    padding:40px 50px;
    text-align:center;
    box-shadow:0 8px 30px rgba(0,0,0,.4);
    max-width:420px;
  }
  h2 { color:#00a2ad; }
  p  { color:#a0b4d6; }
  .hint {
    margin-top:20px;
    padding:10px;
    border-radius:6px;
    background:#00a2ad22;
    color:#00c8d4;
    font-size:13px;
  }
</style>
</head>
<body>
  <div class="card">
    <h2>✅ Login Successful</h2>
    <p>You are now signed in successfully.</p>
    <div class="hint">
      You can now close this page and open the application.
    </div>
  </div>
</body>
</html>
"@

    $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($html)
    $context.Response.ContentType     = "text/html; charset=utf-8"
    $context.Response.ContentLength64 = $responseBytes.Length
    try {
        $context.Response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
        $context.Response.OutputStream.Close()
    } catch { }

    # ── Parse query-string ───────────────────────────
    $query  = $context.Request.Url.Query.TrimStart('?')
    $params = @{}
    foreach ($pair in ($query -split '&')) {
        $kv = $pair -split '=', 2
        if ($kv.Count -eq 2) {
            $params[$kv[0]] = [Uri]::UnescapeDataString($kv[1])
        }
    }

    if ($params['error']) {
        [System.Windows.Forms.MessageBox]::Show(
            "Authentication error: $($params['error'])`n`n$($params['error_description'])",
            "MOEHE — Auth Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }

    if ($params['state'] -ne $state) {
        [System.Windows.Forms.MessageBox]::Show(
            "State mismatch — possible CSRF. Authentication rejected.",
            "MOEHE — Security Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }

    $code = $params['code']
    if ([string]::IsNullOrWhiteSpace($code)) {
        [System.Windows.Forms.MessageBox]::Show(
            "No authorisation code received from Microsoft.",
            "MOEHE — Auth Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }

    # ── Exchange code → tokens ───────────────────────
    $tokenBody = @{
        client_id     = $ClientId
        grant_type    = "authorization_code"
        code          = $code
        redirect_uri  = $RedirectUri
        code_verifier = $pkce.Verifier
        scope         = $Scopes
    }
    try {
        $tokenResp = Invoke-RestMethod `
            -Method POST `
            -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
            -Body $tokenBody `
            -ContentType "application/x-www-form-urlencoded" `
            -ErrorAction Stop
    } catch {
        $errBody = $_.ErrorDetails.Message
        [System.Windows.Forms.MessageBox]::Show(
            "Token exchange failed.`n`n$($_.Exception.Message)`n`n$errBody",
            "MOEHE — Auth Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }

    return $tokenResp
}

# =====================================================
# GROUP MEMBERSHIP CHECK
# =====================================================

function Test-GroupMembership {
    param([string]$AccessToken, [string]$GroupObjectId)
    try {
        $headers = @{ Authorization = "Bearer $AccessToken" }
        $uri = "https://graph.microsoft.com/v1.0/me/transitiveMemberOf/microsoft.graph.group" +
               "?`$select=id&`$top=100"
        do {
            $resp = Invoke-RestMethod -Method GET -Uri $uri -Headers $headers -ErrorAction Stop
            if ($resp.value | Where-Object { $_.id -eq $GroupObjectId }) { return $true }
            $uri  = $resp.'@odata.nextLink'
        } while ($uri)
        return $false
    } catch {
        return $false
    }
}

# =====================================================
# LOGIN SPLASH FORM
# =====================================================

function Show-LoginForm {

    $dlg                 = New-Object System.Windows.Forms.Form
    $dlg.Text            = "MOEHE — Secure Login"
    $dlg.Size            = New-Object System.Drawing.Size(860, 520)
    $dlg.MinimumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.MaximumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.StartPosition   = "CenterScreen"
    $dlg.FormBorderStyle = "FixedSingle"
    $dlg.MaximizeBox     = $false
    $dlg.BackColor       = $C_White
    $dlg.Font            = $F_UI

    # ── LEFT PANEL ────────────────────────────────────
    $pnlLeft           = New-Object System.Windows.Forms.Panel
    $pnlLeft.Size      = New-Object System.Drawing.Size(340, 520)
    $pnlLeft.Location  = New-Object System.Drawing.Point(0, 0)
    $pnlLeft.BackColor = $C_NavyDark
    $dlg.Controls.Add($pnlLeft)

    $pnlAccentBar          = New-Object System.Windows.Forms.Panel
    $pnlAccentBar.Size     = New-Object System.Drawing.Size(4, 520)
    $pnlAccentBar.Location = New-Object System.Drawing.Point(336, 0)
    $pnlAccentBar.BackColor = $C_Teal
    $dlg.Controls.Add($pnlAccentBar)

    # Crest
    $pnlCrest          = New-Object System.Windows.Forms.Panel
    $pnlCrest.Size     = New-Object System.Drawing.Size(72, 72)
    $pnlCrest.Location = New-Object System.Drawing.Point(34, 44)
    $pnlCrest.BackColor = $C_NavyDark
    $pnlLeft.Controls.Add($pnlCrest)
    $pnlCrest.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($C_Teal)), 0, 0, 70, 70)
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($C_NavyDark)), 6, 6, 58, 58)
        $mFont = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $sf    = New-Object System.Drawing.StringFormat
        $sf.Alignment     = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString("M", $mFont, (New-Object System.Drawing.SolidBrush($C_Teal)),
            [System.Drawing.RectangleF]::new(0, 0, 70, 70), $sf)
    })

    foreach ($pair in @(
        @(128, "Ministry of Education"),
        @(150, "and Higher Education")
    )) {
        $l = New-Object System.Windows.Forms.Label
        $l.Text = $pair[1]; $l.Font = $F_HeroSm; $l.ForeColor = $C_White
        $l.Location = New-Object System.Drawing.Point(34, $pair[0])
        $l.Size     = New-Object System.Drawing.Size(280, 22)
        $pnlLeft.Controls.Add($l)
    }

    $lblAbbr           = New-Object System.Windows.Forms.Label
    $lblAbbr.Text      = "MOEHE"; $lblAbbr.Font = $F_Sub
    $lblAbbr.ForeColor = $C_Teal
    $lblAbbr.Location  = New-Object System.Drawing.Point(34, 178)
    $lblAbbr.Size      = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblAbbr)

    $pnlDiv            = New-Object System.Windows.Forms.Panel
    $pnlDiv.Size       = New-Object System.Drawing.Size(260, 1)
    $pnlDiv.Location   = New-Object System.Drawing.Point(34, 208)
    $pnlDiv.BackColor  = [System.Drawing.Color]::FromArgb(35, 60, 100)
    $pnlLeft.Controls.Add($pnlDiv)

    $y = 226
    foreach ($item in @(
        [char]0x25CF + "  Intune Device Lookup Tool"
        [char]0x25CF + "  Read-only helpdesk access"
        [char]0x25CF + "  Geofenced — MOEHE networks only"
        [char]0x25CF + "  Microsoft Entra ID authentication"
        [char]0x25CF + "  Helpdesk group access control"
    )) {
        $l = New-Object System.Windows.Forms.Label
        $l.Text = $item; $l.Font = $F_Tiny
        $l.ForeColor = [System.Drawing.Color]::FromArgb(160, 195, 225)
        $l.Location  = New-Object System.Drawing.Point(34, $y)
        $l.Size      = New-Object System.Drawing.Size(280, 18)
        $pnlLeft.Controls.Add($l); $y += 22
    }

    # Warning box
    $pnlWarn           = New-Object System.Windows.Forms.Panel
    $pnlWarn.Size      = New-Object System.Drawing.Size(272, 72)
    $pnlWarn.Location  = New-Object System.Drawing.Point(34, 360)
    $pnlWarn.BackColor = [System.Drawing.Color]::FromArgb(20, 50, 90)
    $pnlLeft.Controls.Add($pnlWarn)

    $wa = New-Object System.Windows.Forms.Panel
    $wa.Size = New-Object System.Drawing.Size(3, 72)
    $wa.Location = New-Object System.Drawing.Point(0, 0)
    $wa.BackColor = $C_Orange; $pnlWarn.Controls.Add($wa)

    $wh = New-Object System.Windows.Forms.Label
    $wh.Text = "AUTHORISED ACCESS ONLY"
    $wh.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
    $wh.ForeColor = $C_Orange; $wh.Location = New-Object System.Drawing.Point(12, 10)
    $wh.Size = New-Object System.Drawing.Size(250, 14); $pnlWarn.Controls.Add($wh)

    $wb = New-Object System.Windows.Forms.Label
    $wb.Text = "Unauthorised access attempts are logged and may result in disciplinary or legal action."
    $wb.Font = $F_Tiny; $wb.ForeColor = [System.Drawing.Color]::FromArgb(140, 175, 210)
    $wb.Location = New-Object System.Drawing.Point(12, 28)
    $wb.Size = New-Object System.Drawing.Size(252, 36); $pnlWarn.Controls.Add($wb)

    $lblVer = New-Object System.Windows.Forms.Label
    $lblVer.Text = "v4.0  ·  Internal Use Only"; $lblVer.Font = $F_Tiny
    $lblVer.ForeColor = [System.Drawing.Color]::FromArgb(60, 90, 130)
    $lblVer.Location  = New-Object System.Drawing.Point(34, 488)
    $lblVer.Size      = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblVer)

    # ── RIGHT PANEL ───────────────────────────────────
    $pnlRight          = New-Object System.Windows.Forms.Panel
    $pnlRight.Size     = New-Object System.Drawing.Size(516, 520)
    $pnlRight.Location = New-Object System.Drawing.Point(344, 0)
    $pnlRight.BackColor = $C_White
    $dlg.Controls.Add($pnlRight)

    $lblSignIn           = New-Object System.Windows.Forms.Label
    $lblSignIn.Text      = "Sign In"
    $lblSignIn.Font      = $F_Hero
    $lblSignIn.ForeColor = $C_TextPri
    $lblSignIn.Location  = New-Object System.Drawing.Point(52, 68)
    $lblSignIn.Size      = New-Object System.Drawing.Size(300, 42)
    $pnlRight.Controls.Add($lblSignIn)

    $lblSub2 = New-Object System.Windows.Forms.Label
    $lblSub2.Text = "Use your MOEHE Microsoft account to access the Intune Device Lookup Portal."
    $lblSub2.Font = $F_Sub; $lblSub2.ForeColor = $C_TextSec
    $lblSub2.Location = New-Object System.Drawing.Point(52, 116)
    $lblSub2.Size     = New-Object System.Drawing.Size(400, 34)
    $pnlRight.Controls.Add($lblSub2)

    # Divider top
    $div1 = New-Object System.Windows.Forms.Panel
    $div1.Size = New-Object System.Drawing.Size(400, 1)
    $div1.Location  = New-Object System.Drawing.Point(52, 162)
    $div1.BackColor = $C_Border
    $pnlRight.Controls.Add($div1)

    # MS logo strip
    $pnlMsLogo          = New-Object System.Windows.Forms.Panel
    $pnlMsLogo.Size     = New-Object System.Drawing.Size(400, 40)
    $pnlMsLogo.Location = New-Object System.Drawing.Point(52, 172)
    $pnlMsLogo.BackColor = $C_White
    $pnlRight.Controls.Add($pnlMsLogo)
    $pnlMsLogo.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $sq = 9
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 80, 34))),   0,      0,      $sq, $sq)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(127, 186, 0))),   $sq+2,  0,      $sq, $sq)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0,   164, 239))), 0,      $sq+2,  $sq, $sq)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 185, 0))),   $sq+2,  $sq+2,  $sq, $sq)
        $msfont = New-Object System.Drawing.Font("Segoe UI", 9)
        $g.DrawString("Microsoft", $msfont,
            (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 50, 50))),
            [System.Drawing.PointF]::new(26, 5))
    })

    # Divider bottom
    $div2 = New-Object System.Windows.Forms.Panel
    $div2.Size = New-Object System.Drawing.Size(400, 1)
    $div2.Location  = New-Object System.Drawing.Point(52, 216)
    $div2.BackColor = $C_Border
    $pnlRight.Controls.Add($div2)

    # Status label — shows progress feedback
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text      = ""
    $lblStatus.Font      = $F_UISm
    $lblStatus.ForeColor = $C_TextSec
    $lblStatus.Location  = New-Object System.Drawing.Point(52, 228)
    $lblStatus.Size      = New-Object System.Drawing.Size(400, 44)
    $pnlRight.Controls.Add($lblStatus)

    # Sign in button
    $btnMS = New-Object System.Windows.Forms.Button
    $btnMS.Text      = "    Sign in with Microsoft"
    $btnMS.Size      = New-Object System.Drawing.Size(400, 48)
    $btnMS.Location  = New-Object System.Drawing.Point(52, 282)
    $btnMS.BackColor = [System.Drawing.Color]::FromArgb(0, 114, 206)
    $btnMS.ForeColor = $C_White
    $btnMS.FlatStyle = "Flat"
    $btnMS.FlatAppearance.BorderSize = 0
    $btnMS.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 95, 184)
    $btnMS.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(0, 78, 160)
    $btnMS.Font      = $F_UIBold
    $btnMS.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $btnMS.TextAlign = "MiddleCenter"
    $pnlRight.Controls.Add($btnMS)

    # Draw small 4-square MS logo on button
    $btnMS.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $sq = 7; $x0 = 14; $y0 = 17
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 80, 34))),  $x0,      $y0,      $sq, $sq)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(127, 186, 0))), $x0+$sq+1,$y0,      $sq, $sq)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 164, 239))), $x0,      $y0+$sq+1,$sq, $sq)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 185, 0))), $x0+$sq+1,$y0+$sq+1,$sq, $sq)
    })

    $lblNote = New-Object System.Windows.Forms.Label
    $lblNote.Text = "A browser window will open for Microsoft authentication.`nOnly authorised MOEHE Helpdesk group members will be granted access."
    $lblNote.Font = $F_Tiny; $lblNote.ForeColor = $C_TextSec
    $lblNote.Location = New-Object System.Drawing.Point(52, 342)
    $lblNote.Size     = New-Object System.Drawing.Size(400, 34)
    $pnlRight.Controls.Add($lblNote)

    $lblFooter = New-Object System.Windows.Forms.Label
    $lblFooter.Text      = "This system is for authorised MOEHE personnel only.  ·  Helpdesk Division"
    $lblFooter.Font      = $F_Tiny; $lblFooter.ForeColor = $C_TextSec
    $lblFooter.TextAlign = "MiddleCenter"
    $lblFooter.Location  = New-Object System.Drawing.Point(0, 492)
    $lblFooter.Size      = New-Object System.Drawing.Size(516, 18)
    $pnlRight.Controls.Add($lblFooter)

    # ── Login state ────────────────────────────────────
    $script:LoginSuccess = $false

    $btnMS.Add_Click({
        $btnMS.Enabled = $false
        $lblStatus.ForeColor = $C_TextSec
        $lblStatus.Text = "Opening Microsoft login in your browser...`nReturn here after signing in."
        $dlg.Refresh()

        # Run the PKCE auth flow — listener is on fixed port 8765
        $tokenResp = Invoke-EntraLogin `
            -TenantId      $AUTH_TenantId `
            -ClientId      $AUTH_ClientId `
            -RedirectUri   $AUTH_RedirectUri `
            -CallbackPort  $AUTH_CallbackPort `
            -Scopes        $AUTH_Scopes `
            -GroupObjectId $AUTH_GroupObjectId

        if (-not $tokenResp) {
            $lblStatus.ForeColor = $C_Red
            $lblStatus.Text = "Authentication failed or was cancelled."
            $btnMS.Enabled  = $true
            return
        }

        $lblStatus.ForeColor = $C_TextSec
        $lblStatus.Text = "Verifying group membership..."
        $dlg.Refresh()

        $inGroup = Test-GroupMembership `
            -AccessToken   $tokenResp.access_token `
            -GroupObjectId $AUTH_GroupObjectId

        if (-not $inGroup) {
            $lblStatus.ForeColor = $C_Red
            $lblStatus.Text = "Access denied — your account is not in the authorised Helpdesk group."
            [System.Windows.Forms.MessageBox]::Show(
                "Access Denied`n`nYour Microsoft account was authenticated successfully, but you are not a member of the required MOEHE Helpdesk security group.`n`nContact your administrator if you believe this is an error.",
                "MOEHE — Access Denied",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Stop)
            $btnMS.Enabled = $true
            return
        }

        # Store the delegated token for this session
        $script:DelegatedToken       = $tokenResp.access_token
        $script:DelegatedTokenExpiry = [datetime]::UtcNow.AddSeconds($tokenResp.expires_in)
        $script:LoginSuccess         = $true

        $lblStatus.ForeColor = $C_Green
        $lblStatus.Text = "Access granted. Loading portal..."
        $dlg.Refresh()
        Start-Sleep -Milliseconds 600
        $dlg.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $dlg.Close()
    })

    $dlg.Add_FormClosing({
        param($s, $e)
        if ($script:LoginSuccess -ne $true) { $script:LoginSuccess = $false }
    })

    [void]$dlg.ShowDialog()
    $dlg.Dispose()

    return ($script:LoginSuccess -eq $true)
}

# ── Run login before anything else ───────────────────
$authenticated = Show-LoginForm
if (-not $authenticated) { exit }

# =====================================================
# GEOFENCE
# =====================================================

function Test-IPInCIDR {
    param([string]$IP, [string]$CIDR)
    try {
        $parts     = $CIDR -split '/'
        $baseIP    = [System.Net.IPAddress]::Parse($parts[0])
        $prefix    = [int]$parts[1]
        $testIP    = [System.Net.IPAddress]::Parse($IP)
        $baseBytes = $baseIP.GetAddressBytes(); [Array]::Reverse($baseBytes)
        $testBytes = $testIP.GetAddressBytes(); [Array]::Reverse($testBytes)
        if ($baseBytes.Length -ne $testBytes.Length) { return $false }
        $baseInt = [System.BitConverter]::ToUInt32($baseBytes, 0)
        $testInt = [System.BitConverter]::ToUInt32($testBytes, 0)
        $mask    = [uint32](0xFFFFFFFF -shl (32 - $prefix))
        return (($baseInt -band $mask) -eq ($testInt -band $mask))
    } catch { return $false }
}

function Assert-Geofence {
    try {
        $publicIP = $null
        foreach ($svc in @("https://api.ipify.org", "https://checkip.amazonaws.com", "https://icanhazip.com")) {
            try {
                $raw = (Invoke-RestMethod -Uri $svc -TimeoutSec 5 -ErrorAction Stop)
                $publicIP = "$raw".Trim()
                if ($publicIP -match '^\d+\.\d+\.\d+\.\d+$') { break }
            } catch { continue }
        }

        if (-not $publicIP) {
            [System.Windows.Forms.MessageBox]::Show(
                "Could not determine your public IP address.`nAccess denied.",
                "MOEHE — Access Denied",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Stop)
            exit
        }

        $allowed = $false
        foreach ($entry in $AllowedIPs) {
            if ($entry -match '/') {
                if (Test-IPInCIDR -IP $publicIP -CIDR $entry) { $allowed = $true; break }
            } elseif ($publicIP -eq $entry) {
                $allowed = $true; break
            }
        }

        if (-not $allowed) {
            [System.Windows.Forms.MessageBox]::Show(
                "Access Denied`n`nThis tool may only be used from authorised MOEHE networks.`n`nDetected IP:  $publicIP",
                "MOEHE — Network Restriction",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Stop)
            exit
        }
        return $publicIP
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Geofence check failed.`n`n$($_.Exception.Message)`n`nAccess denied.",
            "MOEHE — Geofence Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Stop)
        exit
    }
}

$script:PublicIP = Assert-Geofence

# =====================================================
# GRAPH TOKEN — client credentials (hardcoded, no prompts)
# Uses $APP_TenantId / $APP_ClientId / $APP_ClientSecret
# defined in the CONFIGURATION block at the top.
# Token is cached and auto-refreshed 5 min before expiry.
# =====================================================

$script:CachedToken = $null
$script:TokenExpiry = [datetime]::MinValue

function Get-GraphToken {
    # Validate that all three values are filled in
    if ([string]::IsNullOrWhiteSpace($APP_TenantId) -or
        [string]::IsNullOrWhiteSpace($APP_ClientId) -or
        [string]::IsNullOrWhiteSpace($APP_ClientSecret)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Graph credentials are not configured.`n`nPlease fill in:`n  `$APP_TenantId`n  `$APP_ClientId`n  `$APP_ClientSecret`n`nat the top of the script.",
            "MOEHE — Configuration Required",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        return $null
    }

    # Return cached token if still valid
    if ($script:CachedToken -and ([datetime]::UtcNow -lt $script:TokenExpiry.AddMinutes(-5))) {
        return $script:CachedToken
    }

    $body = @{
        client_id     = $APP_ClientId
        client_secret = $APP_ClientSecret
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }
    try {
        $resp = Invoke-RestMethod -Method POST `
            -Uri "https://login.microsoftonline.com/$APP_TenantId/oauth2/v2.0/token" `
            -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
        $script:CachedToken = $resp.access_token
        $script:TokenExpiry = [datetime]::UtcNow.AddSeconds($resp.expires_in)
        return $script:CachedToken
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Graph authentication failed.`n`n$($_.Exception.Message)",
            "MOEHE — Auth Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
}

# =====================================================
# GRAPH PAGING HELPER
# =====================================================

function Invoke-GraphPage {
    param(
        [string]$StartUri,
        [hashtable]$Headers,
        [System.Collections.Generic.List[object]]$Accumulator,
        [System.Collections.Generic.HashSet[string]]$Seen
    )
    $uri = $StartUri
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $uri -Headers $Headers -ErrorAction Stop
        foreach ($item in $resp.value) {
            if ($Seen.Add($item.id)) { $Accumulator.Add($item) }
        }
        $uri = $resp.'@odata.nextLink'
        [System.Windows.Forms.Application]::DoEvents()
    } while ($uri)
}

# =====================================================
# SEARCH
# =====================================================

function Search-IntuneDevices {
    param([string]$SearchText)

    $token = Get-GraphToken
    if (-not $token) { return @() }

    $hdrSearch = @{ Authorization = "Bearer $token"; ConsistencyLevel = "eventual" }
    $hdrPlain  = @{ Authorization = "Bearer $token" }

    $select = "deviceName,userDisplayName,emailAddress,lastSyncDateTime," +
              "operatingSystem,osVersion,complianceState,serialNumber,enrolledDateTime"

    $all  = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $safe = $SearchText.Replace("'", "''")
    $s    = $SearchText.ToLower()

    # 1. Graph search (fuzzy, server-side)
    $encoded = [Uri]::EscapeDataString($SearchText)
    $uriSearch = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$search=`"$encoded`"&`$count=true&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriSearch -Headers $hdrSearch -Accumulator $all -Seen $seen
    } catch { }

    # 2. OData $filter (startsWith)
    $uriFilter = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$filter=startsWith(deviceName,'$safe') or startsWith(emailAddress,'$safe') or startsWith(serialNumber,'$safe')" +
                 "&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriFilter -Headers $hdrPlain -Accumulator $all -Seen $seen
    } catch { }

    # 3. Full-page client-side wildcard fallback
    $pageUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$select=$select,id&`$top=999"
    try {
        do {
            $resp = Invoke-RestMethod -Method GET -Uri $pageUri -Headers $hdrPlain -ErrorAction Stop
            foreach ($item in $resp.value) {
                if ($seen.Contains($item.id)) { continue }
                if (($item.deviceName      -and $item.deviceName.ToLower()      -like "*$s*") -or
                    ($item.userDisplayName -and $item.userDisplayName.ToLower() -like "*$s*") -or
                    ($item.emailAddress    -and $item.emailAddress.ToLower()    -like "*$s*") -or
                    ($item.serialNumber    -and $item.serialNumber.ToLower()    -like "*$s*")) {
                    if ($seen.Add($item.id)) { $all.Add($item) }
                }
            }
            $pageUri = $resp.'@odata.nextLink'
            [System.Windows.Forms.Application]::DoEvents()
        } while ($pageUri)
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Graph API error.`n`n$($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
    }

    return $all
}

# =====================================================
# HELPERS
# =====================================================

function Format-Date {
    param($val, [string]$fmt = "yyyy-MM-dd HH:mm")
    if ([string]::IsNullOrWhiteSpace($val)) { return "" }
    try { return ([datetime]$val).ToString($fmt) } catch { return "" }
}

function Set-Status {
    param([string]$msg, [string]$type = "info")
    $script:lblStatus.Text = "  $msg"
    $script:lblStatus.ForeColor = switch ($type) {
        "ok"    { $C_Green  }
        "warn"  { $C_Orange }
        "err"   { $C_Red    }
        default { [System.Drawing.Color]::FromArgb(160, 185, 215) }
    }
}

# =====================================================
# ABOUT DIALOG
# =====================================================

function Show-About {
    $dlg                 = New-Object System.Windows.Forms.Form
    $dlg.Text            = "About"
    $dlg.Size            = New-Object System.Drawing.Size(480, 360)
    $dlg.StartPosition   = "CenterParent"
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.MaximizeBox     = $false; $dlg.MinimizeBox = $false
    $dlg.BackColor       = $C_White; $dlg.Font = $F_UI

    $banner = New-Object System.Windows.Forms.Panel
    $banner.Dock = "Top"; $banner.Height = 80; $banner.BackColor = $C_NavyDark
    $dlg.Controls.Add($banner)

    $lo = New-Object System.Windows.Forms.Label
    $lo.Text = "Ministry of Education and Higher Education"
    $lo.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lo.ForeColor = $C_White; $lo.Location = New-Object System.Drawing.Point(20, 14)
    $lo.Size = New-Object System.Drawing.Size(430, 22); $banner.Controls.Add($lo)

    $ls = New-Object System.Windows.Forms.Label
    $ls.Text = "MOEHE"; $ls.Font = $F_Sub
    $ls.ForeColor = [System.Drawing.Color]::FromArgb(160, 200, 230)
    $ls.Location = New-Object System.Drawing.Point(20, 40)
    $ls.Size = New-Object System.Drawing.Size(430, 18); $banner.Controls.Add($ls)

    $ac = New-Object System.Windows.Forms.Panel
    $ac.Dock = "Top"; $ac.Height = 3; $ac.BackColor = $C_Teal
    $dlg.Controls.Add($ac)

    $body = New-Object System.Windows.Forms.Label
    $body.Text = @"
Intune Device Lookup Tool
Version 4.1  |  Internal Use Only

Provides helpdesk staff with fast, read-only access to
managed device records via the Microsoft Graph API.

Features:
  - PKCE / Auth-Code Entra ID login (fixed port 8765)
  - Hardcoded client credentials — no prompts at runtime
  - Helpdesk group membership enforced at login
  - Server-side search: OData + Graph search
  - Token caching — minimal auth overhead
  - Geofenced access — MOEHE networks only
  - Compliance, OS, serial, and enrolment data
  - Right-click copy: hostname, email, full row
  - Export results to CSV

Redirect URI to register in Entra:
  http://localhost:8765/

Created by MOEHE System Team
"@
    $body.Location = New-Object System.Drawing.Point(24, 100)
    $body.Size     = New-Object System.Drawing.Size(420, 220)
    $body.ForeColor = $C_TextPri; $body.Font = $F_UI
    $dlg.Controls.Add($body)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Close"; $btnOK.Size = New-Object System.Drawing.Size(90, 30)
    $btnOK.Location = New-Object System.Drawing.Point(370, 292)
    $btnOK.BackColor = $C_Teal; $btnOK.ForeColor = $C_White
    $btnOK.FlatStyle = "Flat"; $btnOK.FlatAppearance.BorderSize = 0
    $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $dlg.Controls.Add($btnOK); $dlg.AcceptButton = $btnOK

    [void]$dlg.ShowDialog()
    $dlg.Dispose()
}

# =====================================================
# BUTTON HELPER
# =====================================================

function New-ModernButton {
    param(
        [string]$Text,
        [System.Drawing.Point]$Location,
        [System.Drawing.Size]$Size,
        [System.Drawing.Color]$BG,
        [System.Drawing.Color]$FG,
        [string]$Anchor = "Top,Left"
    )
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text     = $Text; $btn.Location = $Location; $btn.Size = $Size
    $btn.Anchor   = $Anchor; $btn.BackColor = $BG; $btn.ForeColor = $FG
    $btn.FlatStyle = "Flat"; $btn.FlatAppearance.BorderSize = 0
    $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 20), [Math]::Max(0, $BG.G - 20), [Math]::Max(0, $BG.B - 20))
    $btn.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 40), [Math]::Max(0, $BG.G - 40), [Math]::Max(0, $BG.B - 40))
    $btn.Font   = $F_UIBold
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $btn
}

# =====================================================
# MAIN FORM
# =====================================================

$form                = New-Object System.Windows.Forms.Form
$form.Text           = "MOEHE — Intune Device Lookup"
$form.Size           = New-Object System.Drawing.Size(1100, 660)
$form.MinimumSize    = New-Object System.Drawing.Size(800, 500)
$form.StartPosition  = "CenterScreen"
$form.BackColor      = $C_Surface
$form.Font           = $F_UI

# ── HEADER ───────────────────────────────────────────
$pnlHeader           = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock      = "Top"; $pnlHeader.Height = 68
$pnlHeader.BackColor = $C_NavyDark

$lblMOE = New-Object System.Windows.Forms.Label
$lblMOE.Text = "Ministry of Education and Higher Education"
$lblMOE.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$lblMOE.ForeColor = $C_White
$lblMOE.Location  = New-Object System.Drawing.Point(20, 10)
$lblMOE.Size      = New-Object System.Drawing.Size(700, 26)
$pnlHeader.Controls.Add($lblMOE)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Intune Device Lookup  ·  Helpdesk Portal"
$lblSub.Font = $F_Sub; $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(140, 180, 220)
$lblSub.Location = New-Object System.Drawing.Point(22, 38)
$lblSub.Size     = New-Object System.Drawing.Size(500, 18)
$pnlHeader.Controls.Add($lblSub)

$btnAbout = New-ModernButton -Text "About" `
    -Location (New-Object System.Drawing.Point(990, 19)) `
    -Size     (New-Object System.Drawing.Size(72, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$btnAbout.Font = $F_UISm
$pnlHeader.Controls.Add($btnAbout)

$lblIP = New-Object System.Windows.Forms.Label
$lblIP.Text = "IP: $($script:PublicIP)"
$lblIP.Font = $F_UISm; $lblIP.ForeColor = [System.Drawing.Color]::FromArgb(100, 180, 210)
$lblIP.TextAlign = "MiddleRight"
$lblIP.Location  = New-Object System.Drawing.Point(800, 24)
$lblIP.Size      = New-Object System.Drawing.Size(180, 20)
$lblIP.Anchor    = "Top,Right"
$pnlHeader.Controls.Add($lblIP)

# ── TEAL ACCENT ──────────────────────────────────────
$pnlAccent           = New-Object System.Windows.Forms.Panel
$pnlAccent.Dock      = "Top"; $pnlAccent.Height = 3
$pnlAccent.BackColor = $C_Teal

# ── SEARCH BAR ───────────────────────────────────────
$pnlSearch           = New-Object System.Windows.Forms.Panel
$pnlSearch.Dock      = "Top"; $pnlSearch.Height = 72
$pnlSearch.BackColor = $C_White
$pnlSearch.Padding   = New-Object System.Windows.Forms.Padding(16, 0, 16, 0)
$pnlSearch.Add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($C_Border, 1)
    $e.Graphics.DrawLine($pen, 0, $pnlSearch.Height - 1, $pnlSearch.Width, $pnlSearch.Height - 1)
    $pen.Dispose()
})

$lblSearchLbl = New-Object System.Windows.Forms.Label
$lblSearchLbl.Text = "SEARCH BY DEVICE NAME / USERNAME / EMAIL / SERIAL"
$lblSearchLbl.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblSearchLbl.ForeColor = $C_Teal
$lblSearchLbl.Location  = New-Object System.Drawing.Point(18, 10)
$lblSearchLbl.Size      = New-Object System.Drawing.Size(400, 14)
$pnlSearch.Controls.Add($lblSearchLbl)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location    = New-Object System.Drawing.Point(18, 30)
$txtSearch.Size        = New-Object System.Drawing.Size(620, 26)
$txtSearch.Anchor      = "Top,Left,Right"
$txtSearch.Font        = $F_UI
$txtSearch.ForeColor   = $C_TextPri
$txtSearch.BackColor   = $C_Surface
$txtSearch.BorderStyle = "FixedSingle"
$pnlSearch.Controls.Add($txtSearch)

$btnSearch   = New-ModernButton -Text "Search" `
    -Location (New-Object System.Drawing.Point(650, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG $C_Teal -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnSearch)

$btnClear = New-ModernButton -Text "Clear" `
    -Location (New-Object System.Drawing.Point(760, 28)) `
    -Size (New-Object System.Drawing.Size(76, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(226, 232, 240)) -FG $C_TextPri -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnClear)

$btnCopyHost = New-ModernButton -Text "Copy Hostname" `
    -Location (New-Object System.Drawing.Point(846, 28)) `
    -Size (New-Object System.Drawing.Size(115, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 80, 60)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnCopyHost)

$btnExport = New-ModernButton -Text "Export CSV" `
    -Location (New-Object System.Drawing.Point(971, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnExport)

# ── STATUS BAR ───────────────────────────────────────
$pnlFooter           = New-Object System.Windows.Forms.Panel
$pnlFooter.Dock      = "Bottom"; $pnlFooter.Height = 30
$pnlFooter.BackColor = $C_NavyDark

$script:lblStatus = New-Object System.Windows.Forms.Label
$script:lblStatus.Text = "  Ready — enter a search term above"
$script:lblStatus.Font = $F_UISm
$script:lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(160, 185, 215)
$script:lblStatus.Location  = New-Object System.Drawing.Point(0, 7)
$script:lblStatus.Size      = New-Object System.Drawing.Size(700, 18)
$script:lblStatus.Anchor    = "Top,Left,Right"
$pnlFooter.Controls.Add($script:lblStatus)

$lblClock = New-Object System.Windows.Forms.Label
$lblClock.Font = $F_UISm; $lblClock.ForeColor = [System.Drawing.Color]::FromArgb(120, 155, 190)
$lblClock.TextAlign = "MiddleRight"
$lblClock.Size      = New-Object System.Drawing.Size(280, 18)
$lblClock.Location  = New-Object System.Drawing.Point(790, 7)
$lblClock.Anchor    = "Top,Right"
$pnlFooter.Controls.Add($lblClock)

$timer          = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({ $lblClock.Text = (Get-Date -Format "ddd dd MMM yyyy  HH:mm:ss  ") })
$timer.Start()

# ── GRID ─────────────────────────────────────────────
$pnlGrid = New-Object System.Windows.Forms.Panel
$pnlGrid.Dock       = "Fill"
$pnlGrid.BackColor  = $C_Surface
$pnlGrid.Padding    = New-Object System.Windows.Forms.Padding(14, 10, 14, 8)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock                                      = "Fill"
$grid.ReadOnly                                  = $true
$grid.AllowUserToAddRows                        = $false
$grid.AllowUserToDeleteRows                     = $false
$grid.MultiSelect                               = $false
$grid.SelectionMode                             = "FullRowSelect"
$grid.AutoSizeColumnsMode                       = "Fill"
$grid.RowHeadersVisible                         = $false
$grid.BorderStyle                               = "FixedSingle"
$grid.BackgroundColor                           = $C_White
$grid.GridColor                                 = $C_Border
$grid.CellBorderStyle                           = "SingleHorizontal"
$grid.EnableHeadersVisualStyles                 = $false
$grid.ColumnHeadersDefaultCellStyle.BackColor   = $C_Navy
$grid.ColumnHeadersDefaultCellStyle.ForeColor   = $C_White
$grid.ColumnHeadersDefaultCellStyle.Font        = $F_UIBold
$grid.ColumnHeadersDefaultCellStyle.Padding     = New-Object System.Windows.Forms.Padding(6, 0, 0, 0)
$grid.ColumnHeadersDefaultCellStyle.SelectionBackColor = $C_Navy
$grid.ColumnHeadersHeight                       = 34
$grid.ColumnHeadersHeightSizeMode               = "DisableResizing"
$grid.DefaultCellStyle.SelectionBackColor       = $C_SelBg
$grid.DefaultCellStyle.SelectionForeColor       = $C_White
$grid.DefaultCellStyle.Padding                  = New-Object System.Windows.Forms.Padding(6, 0, 0, 0)
$grid.DefaultCellStyle.ForeColor                = $C_TextPri
$grid.AlternatingRowsDefaultCellStyle.BackColor = $C_RowAlt
$grid.RowTemplate.Height                        = 28
$pnlGrid.Controls.Add($grid)

$colDefs = @(
    @{ Name="Hostname";   Header="HOSTNAME";   Fill=14 }
    @{ Name="User";       Header="USER";       Fill=16 }
    @{ Name="Email";      Header="EMAIL";      Fill=18 }
    @{ Name="OS";         Header="OS";         Fill=8  }
    @{ Name="OSVer";      Header="OS VERSION"; Fill=12 }
    @{ Name="Compliance"; Header="COMPLIANCE"; Fill=10 }
    @{ Name="Serial";     Header="SERIAL";     Fill=12 }
    @{ Name="LastSync";   Header="LAST SYNC";  Fill=13 }
    @{ Name="Enrolled";   Header="ENROLLED";   Fill=9  }
)
foreach ($c in $colDefs) {
    $col = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col.Name = $c.Name; $col.HeaderText = $c.Header
    $col.FillWeight = $c.Fill; $col.SortMode = "Automatic"
    [void]$grid.Columns.Add($col)
}

# ── Add controls to form (order matters for Dock) ────
$form.Controls.Add($pnlFooter)
$form.Controls.Add($pnlGrid)
$form.Controls.Add($pnlSearch)
$form.Controls.Add($pnlAccent)
$form.Controls.Add($pnlHeader)

# =====================================================
# GRID POPULATION + FORMATTING
# =====================================================

function Show-Results {
    param($Data)
    $grid.Rows.Clear()
    if (-not $Data) { return }
    foreach ($d in $Data) {
        [void]$grid.Rows.Add([string[]]@(
            $d.deviceName
            $d.userDisplayName
            $d.emailAddress
            $d.operatingSystem
            $d.osVersion
            $d.complianceState
            $d.serialNumber
            (Format-Date $d.lastSyncDateTime "yyyy-MM-dd HH:mm")
            (Format-Date $d.enrolledDateTime  "yyyy-MM-dd")
        ))
    }
}

$grid.Add_CellFormatting({
    param($s, $e)
    if ($e.RowIndex -lt 0) { return }
    if ($grid.Columns[$e.ColumnIndex].Name -ne "Compliance") { return }
    switch ("$($e.Value)".ToLower()) {
        "compliant"    { $e.CellStyle.ForeColor = $C_Green  }
        "noncompliant" { $e.CellStyle.ForeColor = $C_Red    }
        "unknown"      { $e.CellStyle.ForeColor = $C_Orange }
        default        { $e.CellStyle.ForeColor = $C_TextSec }
    }
    $e.CellStyle.Font    = $F_UIBold
    $e.FormattingApplied = $true
})

# =====================================================
# CONTEXT MENU
# =====================================================

$ctx      = New-Object System.Windows.Forms.ContextMenuStrip
$ctx.Font = $F_UI
$mnuHost  = $ctx.Items.Add("  Copy Hostname")
$mnuEmail = $ctx.Items.Add("  Copy Email")
$mnuRow   = $ctx.Items.Add("  Copy Full Row  (tab-separated)")
$ctx.Items.Add("-") | Out-Null
$mnuExp   = $ctx.Items.Add("  Export All Results to CSV")
$grid.ContextMenuStrip = $ctx

$mnuHost.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $v = $grid.SelectedRows[0].Cells["Hostname"].Value
        if ($v) { [System.Windows.Forms.Clipboard]::SetText([string]$v) }
    }
})
$mnuEmail.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $v = $grid.SelectedRows[0].Cells["Email"].Value
        if ($v) { [System.Windows.Forms.Clipboard]::SetText([string]$v) }
    }
})
$mnuRow.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $cells = $grid.SelectedRows[0].Cells
        $line  = (0..($cells.Count - 1) | ForEach-Object { "$($cells[$_].Value)" }) -join "`t"
        [System.Windows.Forms.Clipboard]::SetText($line)
    }
})

# =====================================================
# CSV EXPORT
# =====================================================

function Export-ResultsCSV {
    if ($grid.Rows.Count -eq 0) { Set-Status "No results to export." "warn"; return }
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Title    = "Export Results"
    $dlg.Filter   = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $dlg.FileName = "MOEHE-Intune-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
    if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return }

    $headers = ($colDefs | ForEach-Object { $_.Header }) -join ","
    $lines   = @($headers)
    foreach ($row in $grid.Rows) {
        $cells = 0..($grid.Columns.Count - 1) | ForEach-Object {
            $val = "$($row.Cells[$_].Value)".Replace('"', '""')
            "`"$val`""
        }
        $lines += $cells -join ","
    }
    $lines | Set-Content -Path $dlg.FileName -Encoding UTF8
    Set-Status "Exported $($grid.Rows.Count) row(s) to $($dlg.FileName)" "ok"
}

$mnuExp.Add_Click({    Export-ResultsCSV })
$btnExport.Add_Click({ Export-ResultsCSV })

# =====================================================
# BUTTON EVENTS
# =====================================================

$btnCopyHost.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $v = $grid.SelectedRows[0].Cells["Hostname"].Value
        if ($v -and "$v".Trim() -ne "") {
            [System.Windows.Forms.Clipboard]::SetText([string]$v)
            Set-Status "Hostname '$v' copied to clipboard." "ok"
        } else { Set-Status "No hostname on selected row." "warn" }
    } else { Set-Status "Select a row first." "warn" }
})

$btnSearch.Add_Click({
    $q = $txtSearch.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($q)) { Set-Status "Please enter a search term." "warn"; return }

    Set-Status "Searching for '$q'…" "info"
    $btnSearch.Enabled   = $false
    $btnClear.Enabled    = $false
    $btnExport.Enabled   = $false
    $btnCopyHost.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $form.Refresh()

    try {
        $results = @(Search-IntuneDevices -SearchText $q)
        Show-Results $results
        if ($results.Count -eq 0) {
            Set-Status "No devices found for '$q'." "warn"
        } else {
            Set-Status "$($results.Count) device(s) found for '$q'." "ok"
        }
    } finally {
        $btnSearch.Enabled   = $true
        $btnClear.Enabled    = $true
        $btnExport.Enabled   = $true
        $btnCopyHost.Enabled = $true
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
})

$btnClear.Add_Click({
    $txtSearch.Clear(); $grid.Rows.Clear()
    Set-Status "Ready — enter a search term above" "info"
    $txtSearch.Focus()
})

$txtSearch.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $btnSearch.PerformClick() }
})

$btnAbout.Add_Click({ Show-About })

$form.Add_Resize({
    $btnAbout.Left   = $form.ClientSize.Width - $btnAbout.Width - 20
    $lblIP.Left      = $form.ClientSize.Width - $lblIP.Width - $btnAbout.Width - 28
    $txtSearch.Width = $pnlSearch.Width - 460
    $btnSearch.Left  = $txtSearch.Right + 10
    $btnClear.Left   = $btnSearch.Right + 8
    $btnCopyHost.Left = $btnClear.Right + 8
    $btnExport.Left  = $btnCopyHost.Right + 8
})

# =====================================================
# LAUNCH
# =====================================================

[void]$form.ShowDialog()
$timer.Stop()
$form.Dispose()
