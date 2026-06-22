# =====================================================
# ASSEMBLIES + HIDE CONSOLE — must be first
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@
$type   = Add-Type -MemberDefinition $memberDefinition -Name "Win32ShowWindowAsync" -Namespace "Win32Functions" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# LOGIN FORM — shown before geofence / main UI
# =====================================================

function Show-LoginForm {
    # Design tokens (duplicated here so login runs before main token block)
    $LC_NavyDark = [System.Drawing.Color]::FromArgb(10,  25,  60)
    $LC_Navy     = [System.Drawing.Color]::FromArgb(15,  40,  90)
    $LC_Teal     = [System.Drawing.Color]::FromArgb(0,   162, 173)
    $LC_White    = [System.Drawing.Color]::White
    $LC_Surface  = [System.Drawing.Color]::FromArgb(245, 247, 251)
    $LC_Border   = [System.Drawing.Color]::FromArgb(200, 215, 230)
    $LC_TextPri  = [System.Drawing.Color]::FromArgb(18,  30,  55)
    $LC_TextSec  = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $LC_Red      = [System.Drawing.Color]::FromArgb(220, 38,  38)
    $LC_Green    = [System.Drawing.Color]::FromArgb(22,  163, 74)

    $LF_UI      = New-Object System.Drawing.Font("Segoe UI", 9)
    $LF_UISm    = New-Object System.Drawing.Font("Segoe UI", 8)
    $LF_Bold    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
    $LF_Title   = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $LF_Sub     = New-Object System.Drawing.Font("Segoe UI", 8)
    $LF_Tiny    = New-Object System.Drawing.Font("Segoe UI", 7.5)
    $LF_LabelSm = New-Object System.Drawing.Font("Segoe UI", 7,  [System.Drawing.FontStyle]::Bold)
    $LF_Hero    = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $LF_HeroSm  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    $dlg                 = New-Object System.Windows.Forms.Form
    $dlg.Text            = "MOEHE — Secure Login"
    $dlg.Size            = New-Object System.Drawing.Size(860, 520)
    $dlg.MinimumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.MaximumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.StartPosition   = "CenterScreen"
    $dlg.FormBorderStyle = "FixedSingle"
    $dlg.MaximizeBox     = $false
    $dlg.BackColor       = $LC_White
    $dlg.Font            = $LF_UI

    # -- LEFT PANEL (branding / info) ------------------
    $pnlLeft             = New-Object System.Windows.Forms.Panel
    $pnlLeft.Size        = New-Object System.Drawing.Size(340, 520)
    $pnlLeft.Location    = New-Object System.Drawing.Point(0, 0)
    $pnlLeft.BackColor   = $LC_NavyDark
    $dlg.Controls.Add($pnlLeft)

    # Teal accent bar on right edge of left panel
    $pnlLeftAccent           = New-Object System.Windows.Forms.Panel
    $pnlLeftAccent.Size      = New-Object System.Drawing.Size(4, 520)
    $pnlLeftAccent.Location  = New-Object System.Drawing.Point(336, 0)
    $pnlLeftAccent.BackColor = $LC_Teal
    $dlg.Controls.Add($pnlLeftAccent)

    # Logo / crest area (teal circle placeholder)
    $pnlCrest            = New-Object System.Windows.Forms.Panel
    $pnlCrest.Size       = New-Object System.Drawing.Size(72, 72)
    $pnlCrest.Location   = New-Object System.Drawing.Point(34, 44)
    $pnlCrest.BackColor  = $LC_NavyDark
    $pnlLeft.Controls.Add($pnlCrest)

    $pnlCrest.Add_Paint({
        param($s2, $e2)
        $g   = $e2.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        # Outer teal ring
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($LC_Teal)), 0, 0, 70, 70)
        # Inner navy circle
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($LC_NavyDark)), 6, 6, 58, 58)
        # Monogram "M"
        $font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $sf   = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString("M", $font, (New-Object System.Drawing.SolidBrush($LC_Teal)), [System.Drawing.RectangleF]::new(0,0,70,70), $sf)
    })

    $lblOrg1             = New-Object System.Windows.Forms.Label
    $lblOrg1.Text        = "Ministry of Education"
    $lblOrg1.Font        = $LF_HeroSm
    $lblOrg1.ForeColor   = $LC_White
    $lblOrg1.Location    = New-Object System.Drawing.Point(34, 128)
    $lblOrg1.Size        = New-Object System.Drawing.Size(280, 22)
    $pnlLeft.Controls.Add($lblOrg1)

    $lblOrg2             = New-Object System.Windows.Forms.Label
    $lblOrg2.Text        = "and Higher Education"
    $lblOrg2.Font        = $LF_HeroSm
    $lblOrg2.ForeColor   = $LC_White
    $lblOrg2.Location    = New-Object System.Drawing.Point(34, 150)
    $lblOrg2.Size        = New-Object System.Drawing.Size(280, 22)
    $pnlLeft.Controls.Add($lblOrg2)

    $lblAbbr             = New-Object System.Windows.Forms.Label
    $lblAbbr.Text        = "MOEHE"
    $lblAbbr.Font        = $LF_Sub
    $lblAbbr.ForeColor   = [System.Drawing.Color]::FromArgb(0, 162, 173)
    $lblAbbr.Location    = New-Object System.Drawing.Point(34, 178)
    $lblAbbr.Size        = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblAbbr)

    # Divider line
    $pnlDiv              = New-Object System.Windows.Forms.Panel
    $pnlDiv.Size         = New-Object System.Drawing.Size(260, 1)
    $pnlDiv.Location     = New-Object System.Drawing.Point(34, 208)
    $pnlDiv.BackColor    = [System.Drawing.Color]::FromArgb(35, 60, 100)
    $pnlLeft.Controls.Add($pnlDiv)

    # Info bullets
    $infoItems = @(
        [char]0x25CF + "  Intune Device Lookup Tool"
        [char]0x25CF + "  Read-only helpdesk access"
        [char]0x25CF + "  Geofenced — MOEHE networks only"
        [char]0x25CF + "  Microsoft Graph API integration"
        [char]0x25CF + "  Compliance & enrolment insights"
  [char]0x25CF + "  WOrks in only MOEHE NHQ, Wont work in school"
    )
    $y = 226
    foreach ($item in $infoItems) {
        $lbl           = New-Object System.Windows.Forms.Label
        $lbl.Text      = $item
        $lbl.Font      = $LF_Tiny
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(160, 195, 225)
        $lbl.Location  = New-Object System.Drawing.Point(34, $y)
        $lbl.Size      = New-Object System.Drawing.Size(280, 18)
        $pnlLeft.Controls.Add($lbl)
        $y += 22
    }

    # Warning box
    $pnlWarn             = New-Object System.Windows.Forms.Panel
    $pnlWarn.Size        = New-Object System.Drawing.Size(272, 72)
    $pnlWarn.Location    = New-Object System.Drawing.Point(34, 360)
    $pnlWarn.BackColor   = [System.Drawing.Color]::FromArgb(20, 50, 90)
    $pnlLeft.Controls.Add($pnlWarn)

    $pnlWarnAccent       = New-Object System.Windows.Forms.Panel
    $pnlWarnAccent.Size  = New-Object System.Drawing.Size(3, 72)
    $pnlWarnAccent.Location = New-Object System.Drawing.Point(0, 0)
    $pnlWarnAccent.BackColor = [System.Drawing.Color]::FromArgb(234, 88, 12)
    $pnlWarn.Controls.Add($pnlWarnAccent)

    $lblWarnH            = New-Object System.Windows.Forms.Label
    $lblWarnH.Text       = "AUTHORISED ACCESS ONLY"
    $lblWarnH.Font       = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
    $lblWarnH.ForeColor  = [System.Drawing.Color]::FromArgb(234, 88, 12)
    $lblWarnH.Location   = New-Object System.Drawing.Point(12, 10)
    $lblWarnH.Size       = New-Object System.Drawing.Size(250, 14)
    $pnlWarn.Controls.Add($lblWarnH)

    $lblWarnB            = New-Object System.Windows.Forms.Label
    $lblWarnB.Text       = "Unauthorised access attempts are logged and may result in disciplinary or legal action."
    $lblWarnB.Font       = $LF_Tiny
    $lblWarnB.ForeColor  = [System.Drawing.Color]::FromArgb(140, 175, 210)
    $lblWarnB.Location   = New-Object System.Drawing.Point(12, 28)
    $lblWarnB.Size       = New-Object System.Drawing.Size(252, 36)
    $pnlWarn.Controls.Add($lblWarnB)

    # Version tag bottom-left
    $lblVer              = New-Object System.Windows.Forms.Label
    $lblVer.Text         = "v3.1  ·  Internal Use Only"
    $lblVer.Font         = $LF_Tiny
    $lblVer.ForeColor    = [System.Drawing.Color]::FromArgb(60, 90, 130)
    $lblVer.Location     = New-Object System.Drawing.Point(34, 488)
    $lblVer.Size         = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblVer)

    # -- RIGHT PANEL (login fields) --------------------
    $pnlRight            = New-Object System.Windows.Forms.Panel
    $pnlRight.Size       = New-Object System.Drawing.Size(516, 520)
    $pnlRight.Location   = New-Object System.Drawing.Point(344, 0)
    $pnlRight.BackColor  = $LC_White
    $dlg.Controls.Add($pnlRight)

    # "Sign In" heading
    $lblSignIn           = New-Object System.Windows.Forms.Label
    $lblSignIn.Text      = "Sign In"
    $lblSignIn.Font      = $LF_Hero
    $lblSignIn.ForeColor = $LC_TextPri
    $lblSignIn.Location  = New-Object System.Drawing.Point(52, 72)
    $lblSignIn.Size      = New-Object System.Drawing.Size(300, 38)
    $pnlRight.Controls.Add($lblSignIn)

    $lblSignInSub        = New-Object System.Windows.Forms.Label
    $lblSignInSub.Text   = "Enter your credentials to access the Intune Device Lookup Portal."
    $lblSignInSub.Font   = $LF_Sub
    $lblSignInSub.ForeColor = $LC_TextSec
    $lblSignInSub.Location  = New-Object System.Drawing.Point(52, 116)
    $lblSignInSub.Size      = New-Object System.Drawing.Size(400, 32)
    $pnlRight.Controls.Add($lblSignInSub)

    # -- Username --
    $lblUser             = New-Object System.Windows.Forms.Label
    $lblUser.Text        = "USERNAME"
    $lblUser.Font        = $LF_LabelSm
    $lblUser.ForeColor   = $LC_Teal
    $lblUser.Location    = New-Object System.Drawing.Point(52, 172)
    $lblUser.Size        = New-Object System.Drawing.Size(120, 14)
    $pnlRight.Controls.Add($lblUser)

    $txtUser             = New-Object System.Windows.Forms.TextBox
    $txtUser.Location    = New-Object System.Drawing.Point(52, 190)
    $txtUser.Size        = New-Object System.Drawing.Size(400, 28)
    $txtUser.Font        = $LF_UI
    $txtUser.ForeColor   = $LC_TextPri
    $txtUser.BackColor   = $LC_Surface
    $txtUser.BorderStyle = "FixedSingle"
    $txtUser.Text        = ""
    $pnlRight.Controls.Add($txtUser)

    # bottom border accent for username
    $pnlUBorder          = New-Object System.Windows.Forms.Panel
    $pnlUBorder.Size     = New-Object System.Drawing.Size(400, 2)
    $pnlUBorder.Location = New-Object System.Drawing.Point(52, 216)
    $pnlUBorder.BackColor = $LC_Teal
    $pnlRight.Controls.Add($pnlUBorder)

    # -- Password --
    $lblPass             = New-Object System.Windows.Forms.Label
    $lblPass.Text        = "PASSWORD"
    $lblPass.Font        = $LF_LabelSm
    $lblPass.ForeColor   = $LC_Teal
    $lblPass.Location    = New-Object System.Drawing.Point(52, 248)
    $lblPass.Size        = New-Object System.Drawing.Size(120, 14)
    $pnlRight.Controls.Add($lblPass)

    $txtPass             = New-Object System.Windows.Forms.TextBox
    $txtPass.Location    = New-Object System.Drawing.Point(52, 266)
    $txtPass.Size        = New-Object System.Drawing.Size(400, 28)
    $txtPass.Font        = $LF_UI
    $txtPass.ForeColor   = $LC_TextPri
    $txtPass.BackColor   = $LC_Surface
    $txtPass.BorderStyle = "FixedSingle"
    $txtPass.UseSystemPasswordChar = $true
    $pnlRight.Controls.Add($txtPass)

    $pnlPBorder          = New-Object System.Windows.Forms.Panel
    $pnlPBorder.Size     = New-Object System.Drawing.Size(400, 2)
    $pnlPBorder.Location = New-Object System.Drawing.Point(52, 292)
    $pnlPBorder.BackColor = $LC_Teal
    $pnlRight.Controls.Add($pnlPBorder)

    # Show/hide password toggle
    $chkShow             = New-Object System.Windows.Forms.CheckBox
    $chkShow.Text        = "Show password"
    $chkShow.Font        = $LF_UISm
    $chkShow.ForeColor   = $LC_TextSec
    $chkShow.Location    = New-Object System.Drawing.Point(52, 304)
    $chkShow.Size        = New-Object System.Drawing.Size(130, 20)
    $chkShow.FlatStyle   = "Flat"
    $chkShow.Add_CheckedChanged({
        $txtPass.UseSystemPasswordChar = -not $chkShow.Checked
    })
    $pnlRight.Controls.Add($chkShow)

    # -- Error label --
    $lblError            = New-Object System.Windows.Forms.Label
    $lblError.Text       = ""
    $lblError.Font       = $LF_UISm
    $lblError.ForeColor  = $LC_Red
    $lblError.Location   = New-Object System.Drawing.Point(52, 334)
    $lblError.Size       = New-Object System.Drawing.Size(400, 18)
    $pnlRight.Controls.Add($lblError)

    # -- Login button --
    $btnLogin            = New-Object System.Windows.Forms.Button
    $btnLogin.Text       = "Sign In  ?"
    $btnLogin.Size       = New-Object System.Drawing.Size(400, 42)
    $btnLogin.Location   = New-Object System.Drawing.Point(52, 362)
    $btnLogin.BackColor  = $LC_Teal
    $btnLogin.ForeColor  = $LC_White
    $btnLogin.FlatStyle  = "Flat"
    $btnLogin.FlatAppearance.BorderSize = 0
    $btnLogin.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 140, 150)
    $btnLogin.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(0, 120, 130)
    $btnLogin.Font       = $LF_Bold
    $btnLogin.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $pnlRight.Controls.Add($btnLogin)

    # -- Attempt counter & lockout --
    $script:LoginAttempts = 0
    $script:MaxAttempts   = 5
    $script:LoginSuccess  = $false

    $doLogin = {
        $u = $txtUser.Text.Trim()
        $p = $txtPass.Text

        if ([string]::IsNullOrWhiteSpace($u) -or [string]::IsNullOrWhiteSpace($p)) {
            $lblError.Text = "Please enter both username and password."
            return
        }

        if ($u -eq "admin" -and $p -eq "admin") {
            $script:LoginSuccess = $true
            $lblError.ForeColor  = $LC_Green
            $lblError.Text       = "Authentication successful. Loading…"
            $btnLogin.Enabled    = $false
            Start-Sleep -Milliseconds 600
            $dlg.DialogResult    = [System.Windows.Forms.DialogResult]::OK
            $dlg.Close()
        } else {
            $script:LoginAttempts++
            $remaining = $script:MaxAttempts - $script:LoginAttempts
            if ($script:LoginAttempts -ge $script:MaxAttempts) {
                $lblError.Text    = "Too many failed attempts. Access blocked."
                $btnLogin.Enabled = $false
                $txtUser.Enabled  = $false
                $txtPass.Enabled  = $false
            } else {
                $lblError.Text = "Invalid credentials. $remaining attempt(s) remaining."
            }
            $txtPass.Clear()
            $txtPass.Focus()
        }
    }

    $btnLogin.Add_Click($doLogin)

    $txtPass.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { & $doLogin }
    })
    $txtUser.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $txtPass.Focus() }
    })

    # -- Footer text --
    $lblFooter           = New-Object System.Windows.Forms.Label
    $lblFooter.Text      = "This system is for authorised MOEHE personnel only.  ·  SYSTEMS TEAM"
    $lblFooter.Font      = $LF_Tiny
    $lblFooter.ForeColor = $LC_TextSec
    $lblFooter.TextAlign = "MiddleCenter"
    $lblFooter.Location  = New-Object System.Drawing.Point(0, 488)
    $lblFooter.Size      = New-Object System.Drawing.Size(516, 20)
    $pnlRight.Controls.Add($lblFooter)

    $dlg.AcceptButton    = $btnLogin

    # Closing the window (X button) must also be treated as a failed login
    $dlg.Add_FormClosing({
        param($s, $e)
        if (-not $script:LoginSuccess) {
            $script:LoginSuccess = $false
        }
    })

    $txtUser.Focus()
    [void]$dlg.ShowDialog()
    $dlg.Dispose()

    # Explicitly return $false if success was never set to $true
    if ($script:LoginSuccess -ne $true) { return $false }
    return $true
}

# -- Run login before anything else ------------------
$authenticated = Show-LoginForm
if ($authenticated -ne $true) {
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@

$type = Add-Type -MemberDefinition $memberDefinition -Name "Win32ShowWindowAsync" -Namespace "Win32Functions" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# CONFIGURATION — edit these values
# =====================================================

$TenantId = ""
$ClientId = "1f4cf379-aad3-4627-a69f-ecee57162ec2"
$ClientSecret = ""

$AllowedIPs = @(
    "103.225.74.17"
    "172.16.0.0/16"
    "172.21.0.0/16"
)

# =====================================================
# DESIGN TOKENS
# =====================================================
$C_NavyDark  = [System.Drawing.Color]::FromArgb(10,  25,  60)
$C_Navy      = [System.Drawing.Color]::FromArgb(15,  40,  90)
$C_Teal      = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_White     = [System.Drawing.Color]::White
$C_Surface   = [System.Drawing.Color]::FromArgb(245, 247, 251)
$C_Border    = [System.Drawing.Color]::FromArgb(220, 226, 235)
$C_TextPri   = [System.Drawing.Color]::FromArgb(18,  30,  55)
$C_TextSec   = [System.Drawing.Color]::FromArgb(100, 116, 139)
$C_RowAlt    = [System.Drawing.Color]::FromArgb(248, 250, 253)
$C_SelBg     = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_Green     = [System.Drawing.Color]::FromArgb(22,  163, 74)
$C_Red       = [System.Drawing.Color]::FromArgb(220, 38,  38)
$C_Orange    = [System.Drawing.Color]::FromArgb(234, 88,  12)

$F_UI        = New-Object System.Drawing.Font("Segoe UI", 9)
$F_UISm      = New-Object System.Drawing.Font("Segoe UI", 8)
$F_UIBold    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$F_Sub       = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)

# =====================================================
# GEOFENCE — runs before anything opens
# =====================================================

function Test-IPInCIDR {
    param([string]$IP, [string]$CIDR)
    try {
        $parts     = $CIDR -split "/"
        $baseIP    = [System.Net.IPAddress]::Parse($parts[0])
        $prefix    = [int]$parts[1]
        $testIP    = [System.Net.IPAddress]::Parse($IP)
        $baseBytes = $baseIP.GetAddressBytes()
        $testBytes = $testIP.GetAddressBytes()
        if ($baseBytes.Length -ne $testBytes.Length) { return $false }
        [Array]::Reverse($baseBytes)
        [Array]::Reverse($testBytes)
        $baseInt = [System.BitConverter]::ToUInt32($baseBytes, 0)
        $testInt = [System.BitConverter]::ToUInt32($testBytes, 0)
        $mask    = [uint32](0xFFFFFFFF -shl (32 - $prefix))
        return (($baseInt -band $mask) -eq ($testInt -band $mask))
    } catch { return $false }
}

function Assert-Geofence {
    try {
        $publicIP = $null
        foreach ($svc in @("https://api.ipify.org", "https://checkip.amazonaws.com")) {
            try {
                $publicIP = (Invoke-RestMethod -Uri $svc -TimeoutSec 5 -ErrorAction Stop).Trim()
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
            if ($entry -match "/") {
                if (Test-IPInCIDR -IP $publicIP -CIDR $entry) { $allowed = $true; break }
            } else {
                if ($publicIP -eq $entry) { $allowed = $true; break }
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
# CREDENTIALS
# =====================================================

function Ensure-Credentials {
    if ([string]::IsNullOrWhiteSpace($script:TenantId)) {
        $script:TenantId = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your Azure Tenant ID:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:TenantId)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
    if ([string]::IsNullOrWhiteSpace($script:ClientId)) {
        $script:ClientId = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your App (Client) ID:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:ClientId)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
    if ([string]::IsNullOrWhiteSpace($script:ClientSecret)) {
        $script:ClientSecret = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your Client Secret:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:ClientSecret)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
}

# =====================================================
# TOKEN — cached, auto-refreshed
# =====================================================

$script:CachedToken = $null
$script:TokenExpiry = [datetime]::MinValue

function Get-GraphToken {
    Ensure-Credentials
    if (-not $script:TenantId -or -not $script:ClientId -or -not $script:ClientSecret) {
        [System.Windows.Forms.MessageBox]::Show("Credentials incomplete.", "Config Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
    if ($script:CachedToken -and ([datetime]::UtcNow -lt $script:TokenExpiry.AddMinutes(-5))) {
        return $script:CachedToken
    }
    $body = @{
        client_id     = $script:ClientId
        client_secret = $script:ClientSecret
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }
    try {
        $resp = Invoke-RestMethod -Method POST `
            -Uri "https://login.microsoftonline.com/$($script:TenantId)/oauth2/v2.0/token" `
            -Body $body -ErrorAction Stop
        $script:CachedToken = $resp.access_token
        $script:TokenExpiry = [datetime]::UtcNow.AddSeconds($resp.expires_in)
        return $script:CachedToken
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Authentication failed.`n`n$($_.Exception.Message)",
            "Auth Error",
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
    $pageUri = $StartUri
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $pageUri -Headers $Headers -ErrorAction Stop
        foreach ($item in $resp.value) {
            if ($Seen.Add($item.id)) { $Accumulator.Add($item) }
        }
        $pageUri = $resp.'@odata.nextLink'
        [System.Windows.Forms.Application]::DoEvents()
    } while ($pageUri)
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

    $encoded   = [Uri]::EscapeDataString($SearchText)
    $uriSearch = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$search=$encoded&`$count=true&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriSearch -Headers $hdrSearch -Accumulator $all -Seen $seen
    } catch { }

    $uriFilter = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$filter=startsWith(deviceName,'$safe')" +
                 " or startsWith(emailAddress,'$safe')" +
                 " or startsWith(serialNumber,'$safe')" +
                 "&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriFilter -Headers $hdrPlain -Accumulator $all -Seen $seen
    } catch { }

    $pageUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
               "?`$select=$select,id&`$top=999"
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
            "Graph API error during full scan.`n`n$($_.Exception.Message)", "Error",
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
        "ok"    { $C_Green }
        "warn"  { $C_Orange }
        "err"   { $C_Red }
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
    $dlg.MaximizeBox     = $false
    $dlg.MinimizeBox     = $false
    $dlg.BackColor       = $C_White
    $dlg.Font            = $F_UI

    $banner              = New-Object System.Windows.Forms.Panel
    $banner.Dock         = "Top"
    $banner.Height       = 80
    $banner.BackColor    = $C_NavyDark
    $dlg.Controls.Add($banner)

    $lblOrg              = New-Object System.Windows.Forms.Label
    $lblOrg.Text         = "Ministry of Education and Higher Education"
    $lblOrg.Font         = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblOrg.ForeColor    = $C_White
    $lblOrg.Location     = New-Object System.Drawing.Point(20, 14)
    $lblOrg.Size         = New-Object System.Drawing.Size(430, 22)
    $banner.Controls.Add($lblOrg)

    $lblSub2             = New-Object System.Windows.Forms.Label
    $lblSub2.Text        = "MOEHE"
    $lblSub2.Font        = $F_Sub
    $lblSub2.ForeColor   = [System.Drawing.Color]::FromArgb(160, 200, 230)
    $lblSub2.Location    = New-Object System.Drawing.Point(20, 40)
    $lblSub2.Size        = New-Object System.Drawing.Size(430, 18)
    $banner.Controls.Add($lblSub2)

    $accent2             = New-Object System.Windows.Forms.Panel
    $accent2.Dock        = "Top"
    $accent2.Height      = 3
    $accent2.BackColor   = $C_Teal
    $dlg.Controls.Add($accent2)

    $body                = New-Object System.Windows.Forms.Label
    $body.Text           = @"
Intune Device Lookup Tool
Version 3.1  |  Internal Use Only
Created by MOEHE System Team

- This tool provides helpdesk staff and authorised users with fast, read-only
access to managed device records via the Microsoft Graph
- API (Intune / Microsoft Endpoint Manager).
- The Tool should only be used as per MOEHE Requirements

Features:
  - Server-side search with OData + Graph search
  - Token caching — no repeated authentication overhead
  - Geofenced access — MOEHE networks only
  - Compliance status, OS, serial, and enrolment data
  - Right-click copy for hostname, email, or full row
  - Export results to CSV

Access is restricted by IP geofence. Unauthorised use
or access attempts are logged.


"@
    $body.Location       = New-Object System.Drawing.Point(24, 100)
    $body.Size           = New-Object System.Drawing.Size(420, 210)
    $body.ForeColor      = $C_TextPri
    $body.Font           = $F_UI
    $dlg.Controls.Add($body)

    $btnOK               = New-Object System.Windows.Forms.Button
    $btnOK.Text          = "Close"
    $btnOK.Size          = New-Object System.Drawing.Size(90, 30)
    $btnOK.Location      = New-Object System.Drawing.Point(370, 290)
    $btnOK.BackColor     = $C_Teal
    $btnOK.ForeColor     = $C_White
    $btnOK.FlatStyle     = "Flat"
    $btnOK.FlatAppearance.BorderSize = 0
    $btnOK.DialogResult  = [System.Windows.Forms.DialogResult]::OK
    $dlg.Controls.Add($btnOK)
    $dlg.AcceptButton    = $btnOK

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
    $btn                                        = New-Object System.Windows.Forms.Button
    $btn.Text                                   = $Text
    $btn.Location                               = $Location
    $btn.Size                                   = $Size
    $btn.Anchor                                 = $Anchor
    $btn.BackColor                              = $BG
    $btn.ForeColor                              = $FG
    $btn.FlatStyle                              = "Flat"
    $btn.FlatAppearance.BorderSize              = 0
    $btn.FlatAppearance.MouseOverBackColor      = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 20), [Math]::Max(0, $BG.G - 20), [Math]::Max(0, $BG.B - 20))
    $btn.FlatAppearance.MouseDownBackColor      = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 40), [Math]::Max(0, $BG.G - 40), [Math]::Max(0, $BG.B - 40))
    $btn.Font                                   = $F_UIBold
    $btn.Cursor                                 = [System.Windows.Forms.Cursors]::Hand
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

# -- HEADER PANEL --------------------------------------
$pnlHeader           = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock      = "Top"
$pnlHeader.Height    = 68
$pnlHeader.BackColor = $C_NavyDark

$lblMOE              = New-Object System.Windows.Forms.Label
$lblMOE.Text         = "Ministry of Education and Higher Education"
$lblMOE.Font         = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$lblMOE.ForeColor    = $C_White
$lblMOE.Location     = New-Object System.Drawing.Point(20, 10)
$lblMOE.Size         = New-Object System.Drawing.Size(620, 26)
$pnlHeader.Controls.Add($lblMOE)

$lblSub              = New-Object System.Windows.Forms.Label
$lblSub.Text         = "Intune Device Lookup  | Helpdesk Portal"
$lblSub.Font         = $F_Sub
$lblSub.ForeColor    = [System.Drawing.Color]::FromArgb(140, 180, 220)
$lblSub.Location     = New-Object System.Drawing.Point(22, 38)
$lblSub.Size         = New-Object System.Drawing.Size(500, 18)
$pnlHeader.Controls.Add($lblSub)

$btnAbout            = New-ModernButton -Text "About" `
    -Location (New-Object System.Drawing.Point(990, 19)) `
    -Size (New-Object System.Drawing.Size(72, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$btnAbout.Font       = $F_UISm
$pnlHeader.Controls.Add($btnAbout)

$lblIP               = New-Object System.Windows.Forms.Label
$lblIP.Text          = "IP: $($script:PublicIP)"
$lblIP.Font          = $F_UISm
$lblIP.ForeColor     = [System.Drawing.Color]::FromArgb(100, 180, 210)
$lblIP.TextAlign     = "MiddleRight"
$lblIP.Location      = New-Object System.Drawing.Point(800, 24)
$lblIP.Size          = New-Object System.Drawing.Size(180, 20)
$lblIP.Anchor        = "Top,Right"
$pnlHeader.Controls.Add($lblIP)

# -- TEAL ACCENT LINE ----------------------------------
$pnlAccent           = New-Object System.Windows.Forms.Panel
$pnlAccent.Dock      = "Top"
$pnlAccent.Height    = 3
$pnlAccent.BackColor = $C_Teal

# -- SEARCH CARD ---------------------------------------
$pnlSearch           = New-Object System.Windows.Forms.Panel
$pnlSearch.Dock      = "Top"
$pnlSearch.Height    = 72
$pnlSearch.BackColor = $C_White
$pnlSearch.Padding   = New-Object System.Windows.Forms.Padding(16, 0, 16, 0)

$pnlSearch.Add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($C_Border, 1)
    $e.Graphics.DrawLine($pen, 0, $pnlSearch.Height - 1, $pnlSearch.Width, $pnlSearch.Height - 1)
    $pen.Dispose()
})

$lblSearchLbl           = New-Object System.Windows.Forms.Label
$lblSearchLbl.Text      = "SEARCH BY DEVICE NAME / USERNAME"
$lblSearchLbl.Font      = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblSearchLbl.ForeColor = $C_Teal
$lblSearchLbl.Location  = New-Object System.Drawing.Point(18, 10)
$lblSearchLbl.Size      = New-Object System.Drawing.Size(200, 14)
$pnlSearch.Controls.Add($lblSearchLbl)

$txtSearch              = New-Object System.Windows.Forms.TextBox
$txtSearch.Location     = New-Object System.Drawing.Point(18, 30)
$txtSearch.Size         = New-Object System.Drawing.Size(620, 26)
$txtSearch.Anchor       = "Top,Left,Right"
$txtSearch.Font         = $F_UI
$txtSearch.ForeColor    = $C_TextPri
$txtSearch.BackColor    = $C_Surface
$txtSearch.BorderStyle  = "FixedSingle"
$pnlSearch.Controls.Add($txtSearch)

$btnSearch              = New-ModernButton -Text "Search" `
    -Location (New-Object System.Drawing.Point(650, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG $C_Teal -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnSearch)

$btnClear               = New-ModernButton -Text "Clear" `
    -Location (New-Object System.Drawing.Point(760, 28)) `
    -Size (New-Object System.Drawing.Size(76, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(226, 232, 240)) -FG $C_TextPri -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnClear)

$btnCopyHost            = New-ModernButton -Text "Copy Hostname" `
    -Location (New-Object System.Drawing.Point(846, 28)) `
    -Size (New-Object System.Drawing.Size(115, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 80, 60)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnCopyHost)

$btnExport              = New-ModernButton -Text "Export CSV" `
    -Location (New-Object System.Drawing.Point(971, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnExport)

# -- STATUS BAR ----------------------------------------
$pnlFooter              = New-Object System.Windows.Forms.Panel
$pnlFooter.Dock         = "Bottom"
$pnlFooter.Height       = 30
$pnlFooter.BackColor    = $C_NavyDark

$script:lblStatus       = New-Object System.Windows.Forms.Label
$script:lblStatus.Text  = "  Ready — enter a search term above"
$script:lblStatus.Font  = $F_UISm
$script:lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(160, 185, 215)
$script:lblStatus.Location  = New-Object System.Drawing.Point(0, 7)
$script:lblStatus.Size      = New-Object System.Drawing.Size(700, 18)
$script:lblStatus.Anchor    = "Top,Left,Right"
$pnlFooter.Controls.Add($script:lblStatus)

$lblClock               = New-Object System.Windows.Forms.Label
$lblClock.Font          = $F_UISm
$lblClock.ForeColor     = [System.Drawing.Color]::FromArgb(120, 155, 190)
$lblClock.TextAlign     = "MiddleRight"
$lblClock.Size          = New-Object System.Drawing.Size(260, 18)
$lblClock.Location      = New-Object System.Drawing.Point(810, 7)
$lblClock.Anchor        = "Top,Right"
$pnlFooter.Controls.Add($lblClock)

$timer                  = New-Object System.Windows.Forms.Timer
$timer.Interval         = 1000
$timer.Add_Tick({ $lblClock.Text = (Get-Date -Format "ddd dd MMM yyyy  HH:mm:ss  ") })
$timer.Start()

# -- GRID PANEL (fills remaining space) ----------------
$pnlGrid                = New-Object System.Windows.Forms.Panel
$pnlGrid.Dock           = "Fill"
$pnlGrid.BackColor      = $C_Surface
$pnlGrid.Padding        = New-Object System.Windows.Forms.Padding(14, 10, 14, 8)

$grid                                           = New-Object System.Windows.Forms.DataGridView
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
    @{ Name="Hostname";   Header="HOSTNAME";    Fill=14 }
    @{ Name="User";       Header="USER";        Fill=16 }
    @{ Name="Email";      Header="EMAIL";       Fill=18 }
    @{ Name="OS";         Header="OS";          Fill=8  }
    @{ Name="OSVer";      Header="OS VERSION";  Fill=12 }
    @{ Name="Compliance"; Header="COMPLIANCE";  Fill=10 }
    @{ Name="Serial";     Header="SERIAL";      Fill=12 }
    @{ Name="LastSync";   Header="LAST SYNC";   Fill=13 }
    @{ Name="Enrolled";   Header="ENROLLED";    Fill=9  }
)
foreach ($c in $colDefs) {
    $col            = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col.Name       = $c.Name
    $col.HeaderText = $c.Header
    $col.FillWeight = $c.Fill
    $col.SortMode   = "Automatic"
    [void]$grid.Columns.Add($col)
}

$form.Controls.Add($pnlFooter)
$form.Controls.Add($pnlGrid)
$form.Controls.Add($pnlSearch)
$form.Controls.Add($pnlAccent)
$form.Controls.Add($pnlHeader)

# -- POPULATE GRID -------------------------------------

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
    $e.CellStyle.Font        = $F_UIBold
    $e.FormattingApplied     = $true
})

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

function Export-ResultsCSV {
    if ($grid.Rows.Count -eq 0) {
        Set-Status "No results to export." "warn"
        return
    }
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Title      = "Export Results"
    $dlg.Filter     = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $dlg.FileName   = "MOEHE-Intune-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
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

$mnuExp.Add_Click({ Export-ResultsCSV })
$btnExport.Add_Click({ Export-ResultsCSV })

$btnCopyHost.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $v = $grid.SelectedRows[0].Cells["Hostname"].Value
        if ($v -and "$v".Trim() -ne "") {
            [System.Windows.Forms.Clipboard]::SetText([string]$v)
            Set-Status "Hostname '$v' copied to clipboard." "ok"
        } else {
            Set-Status "No hostname on selected row." "warn"
        }
    } else {
        Set-Status "Select a row first." "warn"
    }
})

$btnSearch.Add_Click({
    $q = $txtSearch.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($q)) {
        Set-Status "Please enter a search term." "warn"
        return
    }
    Set-Status "Searching for '$q'…" "info"
    $btnSearch.Enabled   = $false
    $btnClear.Enabled    = $false
    $btnExport.Enabled   = $false
    $btnCopyHost.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
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
        [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
    }
})

$btnClear.Add_Click({
    $txtSearch.Clear()
    $grid.Rows.Clear()
    Set-Status "Ready — enter a search term above" "info"
    $txtSearch.Focus()
})

$txtSearch.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $btnSearch.PerformClick() }
})

$btnAbout.Add_Click({ Show-About })

$form.Add_Resize({
    $btnAbout.Left = $form.ClientSize.Width - $btnAbout.Width - 20
    $lblIP.Left    = $form.ClientSize.Width - $lblIP.Width - $btnAbout.Width - 28
    $txtSearch.Width   = $pnlSearch.Width - 460
    $btnSearch.Left    = $txtSearch.Right + 10
    $btnClear.Left     = $btnSearch.Right + 8
    $btnCopyHost.Left  = $btnClear.Right + 8
    $btnExport.Left    = $btnCopyHost.Right + 8
})

# =====================================================
# LAUNCH
# =====================================================

[void]$form.ShowDialog()
$timer.Stop()
$form.Dispose()# =====================================================
# ASSEMBLIES + HIDE CONSOLE — must be first
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@
$type   = Add-Type -MemberDefinition $memberDefinition -Name "Win32ShowWindowAsync" -Namespace "Win32Functions" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# LOGIN FORM — shown before geofence / main UI
# =====================================================

function Show-LoginForm {
    # Design tokens (duplicated here so login runs before main token block)
    $LC_NavyDark = [System.Drawing.Color]::FromArgb(10,  25,  60)
    $LC_Navy     = [System.Drawing.Color]::FromArgb(15,  40,  90)
    $LC_Teal     = [System.Drawing.Color]::FromArgb(0,   162, 173)
    $LC_White    = [System.Drawing.Color]::White
    $LC_Surface  = [System.Drawing.Color]::FromArgb(245, 247, 251)
    $LC_Border   = [System.Drawing.Color]::FromArgb(200, 215, 230)
    $LC_TextPri  = [System.Drawing.Color]::FromArgb(18,  30,  55)
    $LC_TextSec  = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $LC_Red      = [System.Drawing.Color]::FromArgb(220, 38,  38)
    $LC_Green    = [System.Drawing.Color]::FromArgb(22,  163, 74)

    $LF_UI      = New-Object System.Drawing.Font("Segoe UI", 9)
    $LF_UISm    = New-Object System.Drawing.Font("Segoe UI", 8)
    $LF_Bold    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
    $LF_Title   = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $LF_Sub     = New-Object System.Drawing.Font("Segoe UI", 8)
    $LF_Tiny    = New-Object System.Drawing.Font("Segoe UI", 7.5)
    $LF_LabelSm = New-Object System.Drawing.Font("Segoe UI", 7,  [System.Drawing.FontStyle]::Bold)
    $LF_Hero    = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $LF_HeroSm  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    $dlg                 = New-Object System.Windows.Forms.Form
    $dlg.Text            = "MOEHE — Secure Login"
    $dlg.Size            = New-Object System.Drawing.Size(860, 520)
    $dlg.MinimumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.MaximumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.StartPosition   = "CenterScreen"
    $dlg.FormBorderStyle = "FixedSingle"
    $dlg.MaximizeBox     = $false
    $dlg.BackColor       = $LC_White
    $dlg.Font            = $LF_UI

    # -- LEFT PANEL (branding / info) ------------------
    $pnlLeft             = New-Object System.Windows.Forms.Panel
    $pnlLeft.Size        = New-Object System.Drawing.Size(340, 520)
    $pnlLeft.Location    = New-Object System.Drawing.Point(0, 0)
    $pnlLeft.BackColor   = $LC_NavyDark
    $dlg.Controls.Add($pnlLeft)

    # Teal accent bar on right edge of left panel
    $pnlLeftAccent           = New-Object System.Windows.Forms.Panel
    $pnlLeftAccent.Size      = New-Object System.Drawing.Size(4, 520)
    $pnlLeftAccent.Location  = New-Object System.Drawing.Point(336, 0)
    $pnlLeftAccent.BackColor = $LC_Teal
    $dlg.Controls.Add($pnlLeftAccent)

    # Logo / crest area (teal circle placeholder)
    $pnlCrest            = New-Object System.Windows.Forms.Panel
    $pnlCrest.Size       = New-Object System.Drawing.Size(72, 72)
    $pnlCrest.Location   = New-Object System.Drawing.Point(34, 44)
    $pnlCrest.BackColor  = $LC_NavyDark
    $pnlLeft.Controls.Add($pnlCrest)

    $pnlCrest.Add_Paint({
        param($s2, $e2)
        $g   = $e2.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        # Outer teal ring
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($LC_Teal)), 0, 0, 70, 70)
        # Inner navy circle
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($LC_NavyDark)), 6, 6, 58, 58)
        # Monogram "M"
        $font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $sf   = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString("M", $font, (New-Object System.Drawing.SolidBrush($LC_Teal)), [System.Drawing.RectangleF]::new(0,0,70,70), $sf)
    })

    $lblOrg1             = New-Object System.Windows.Forms.Label
    $lblOrg1.Text        = "Ministry of Education"
    $lblOrg1.Font        = $LF_HeroSm
    $lblOrg1.ForeColor   = $LC_White
    $lblOrg1.Location    = New-Object System.Drawing.Point(34, 128)
    $lblOrg1.Size        = New-Object System.Drawing.Size(280, 22)
    $pnlLeft.Controls.Add($lblOrg1)

    $lblOrg2             = New-Object System.Windows.Forms.Label
    $lblOrg2.Text        = "and Higher Education"
    $lblOrg2.Font        = $LF_HeroSm
    $lblOrg2.ForeColor   = $LC_White
    $lblOrg2.Location    = New-Object System.Drawing.Point(34, 150)
    $lblOrg2.Size        = New-Object System.Drawing.Size(280, 22)
    $pnlLeft.Controls.Add($lblOrg2)

    $lblAbbr             = New-Object System.Windows.Forms.Label
    $lblAbbr.Text        = "MOEHE"
    $lblAbbr.Font        = $LF_Sub
    $lblAbbr.ForeColor   = [System.Drawing.Color]::FromArgb(0, 162, 173)
    $lblAbbr.Location    = New-Object System.Drawing.Point(34, 178)
    $lblAbbr.Size        = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblAbbr)

    # Divider line
    $pnlDiv              = New-Object System.Windows.Forms.Panel
    $pnlDiv.Size         = New-Object System.Drawing.Size(260, 1)
    $pnlDiv.Location     = New-Object System.Drawing.Point(34, 208)
    $pnlDiv.BackColor    = [System.Drawing.Color]::FromArgb(35, 60, 100)
    $pnlLeft.Controls.Add($pnlDiv)

    # Info bullets
    $infoItems = @(
        [char]0x25CF + "  Intune Device Lookup Tool"
        [char]0x25CF + "  Read-only helpdesk access"
        [char]0x25CF + "  Geofenced — MOEHE networks only"
        [char]0x25CF + "  Microsoft Graph API integration"
        [char]0x25CF + "  Compliance & enrolment insights"
    )
    $y = 226
    foreach ($item in $infoItems) {
        $lbl           = New-Object System.Windows.Forms.Label
        $lbl.Text      = $item
        $lbl.Font      = $LF_Tiny
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(160, 195, 225)
        $lbl.Location  = New-Object System.Drawing.Point(34, $y)
        $lbl.Size      = New-Object System.Drawing.Size(280, 18)
        $pnlLeft.Controls.Add($lbl)
        $y += 22
    }

    # Warning box
    $pnlWarn             = New-Object System.Windows.Forms.Panel
    $pnlWarn.Size        = New-Object System.Drawing.Size(272, 72)
    $pnlWarn.Location    = New-Object System.Drawing.Point(34, 360)
    $pnlWarn.BackColor   = [System.Drawing.Color]::FromArgb(20, 50, 90)
    $pnlLeft.Controls.Add($pnlWarn)

    $pnlWarnAccent       = New-Object System.Windows.Forms.Panel
    $pnlWarnAccent.Size  = New-Object System.Drawing.Size(3, 72)
    $pnlWarnAccent.Location = New-Object System.Drawing.Point(0, 0)
    $pnlWarnAccent.BackColor = [System.Drawing.Color]::FromArgb(234, 88, 12)
    $pnlWarn.Controls.Add($pnlWarnAccent)

    $lblWarnH            = New-Object System.Windows.Forms.Label
    $lblWarnH.Text       = "AUTHORISED ACCESS ONLY"
    $lblWarnH.Font       = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
    $lblWarnH.ForeColor  = [System.Drawing.Color]::FromArgb(234, 88, 12)
    $lblWarnH.Location   = New-Object System.Drawing.Point(12, 10)
    $lblWarnH.Size       = New-Object System.Drawing.Size(250, 14)
    $pnlWarn.Controls.Add($lblWarnH)

    $lblWarnB            = New-Object System.Windows.Forms.Label
    $lblWarnB.Text       = "Unauthorised access attempts are logged and may result in disciplinary or legal action."
    $lblWarnB.Font       = $LF_Tiny
    $lblWarnB.ForeColor  = [System.Drawing.Color]::FromArgb(140, 175, 210)
    $lblWarnB.Location   = New-Object System.Drawing.Point(12, 28)
    $lblWarnB.Size       = New-Object System.Drawing.Size(252, 36)
    $pnlWarn.Controls.Add($lblWarnB)

    # Version tag bottom-left
    $lblVer              = New-Object System.Windows.Forms.Label
    $lblVer.Text         = "v3.1  ·  Internal Use Only"
    $lblVer.Font         = $LF_Tiny
    $lblVer.ForeColor    = [System.Drawing.Color]::FromArgb(60, 90, 130)
    $lblVer.Location     = New-Object System.Drawing.Point(34, 488)
    $lblVer.Size         = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblVer)

    # -- RIGHT PANEL (login fields) --------------------
    $pnlRight            = New-Object System.Windows.Forms.Panel
    $pnlRight.Size       = New-Object System.Drawing.Size(516, 520)
    $pnlRight.Location   = New-Object System.Drawing.Point(344, 0)
    $pnlRight.BackColor  = $LC_White
    $dlg.Controls.Add($pnlRight)

    # "Sign In" heading
    $lblSignIn           = New-Object System.Windows.Forms.Label
    $lblSignIn.Text      = "Sign In"
    $lblSignIn.Font      = $LF_Hero
    $lblSignIn.ForeColor = $LC_TextPri
    $lblSignIn.Location  = New-Object System.Drawing.Point(52, 72)
    $lblSignIn.Size      = New-Object System.Drawing.Size(300, 38)
    $pnlRight.Controls.Add($lblSignIn)

    $lblSignInSub        = New-Object System.Windows.Forms.Label
    $lblSignInSub.Text   = "Enter your credentials to access the Intune Device Lookup Portal."
    $lblSignInSub.Font   = $LF_Sub
    $lblSignInSub.ForeColor = $LC_TextSec
    $lblSignInSub.Location  = New-Object System.Drawing.Point(52, 116)
    $lblSignInSub.Size      = New-Object System.Drawing.Size(400, 32)
    $pnlRight.Controls.Add($lblSignInSub)

    # -- Username --
    $lblUser             = New-Object System.Windows.Forms.Label
    $lblUser.Text        = "USERNAME"
    $lblUser.Font        = $LF_LabelSm
    $lblUser.ForeColor   = $LC_Teal
    $lblUser.Location    = New-Object System.Drawing.Point(52, 172)
    $lblUser.Size        = New-Object System.Drawing.Size(120, 14)
    $pnlRight.Controls.Add($lblUser)

    $txtUser             = New-Object System.Windows.Forms.TextBox
    $txtUser.Location    = New-Object System.Drawing.Point(52, 190)
    $txtUser.Size        = New-Object System.Drawing.Size(400, 28)
    $txtUser.Font        = $LF_UI
    $txtUser.ForeColor   = $LC_TextPri
    $txtUser.BackColor   = $LC_Surface
    $txtUser.BorderStyle = "FixedSingle"
    $txtUser.Text        = ""
    $pnlRight.Controls.Add($txtUser)

    # bottom border accent for username
    $pnlUBorder          = New-Object System.Windows.Forms.Panel
    $pnlUBorder.Size     = New-Object System.Drawing.Size(400, 2)
    $pnlUBorder.Location = New-Object System.Drawing.Point(52, 216)
    $pnlUBorder.BackColor = $LC_Teal
    $pnlRight.Controls.Add($pnlUBorder)

    # -- Password --
    $lblPass             = New-Object System.Windows.Forms.Label
    $lblPass.Text        = "PASSWORD"
    $lblPass.Font        = $LF_LabelSm
    $lblPass.ForeColor   = $LC_Teal
    $lblPass.Location    = New-Object System.Drawing.Point(52, 248)
    $lblPass.Size        = New-Object System.Drawing.Size(120, 14)
    $pnlRight.Controls.Add($lblPass)

    $txtPass             = New-Object System.Windows.Forms.TextBox
    $txtPass.Location    = New-Object System.Drawing.Point(52, 266)
    $txtPass.Size        = New-Object System.Drawing.Size(400, 28)
    $txtPass.Font        = $LF_UI
    $txtPass.ForeColor   = $LC_TextPri
    $txtPass.BackColor   = $LC_Surface
    $txtPass.BorderStyle = "FixedSingle"
    $txtPass.UseSystemPasswordChar = $true
    $pnlRight.Controls.Add($txtPass)

    $pnlPBorder          = New-Object System.Windows.Forms.Panel
    $pnlPBorder.Size     = New-Object System.Drawing.Size(400, 2)
    $pnlPBorder.Location = New-Object System.Drawing.Point(52, 292)
    $pnlPBorder.BackColor = $LC_Teal
    $pnlRight.Controls.Add($pnlPBorder)

    # Show/hide password toggle
    $chkShow             = New-Object System.Windows.Forms.CheckBox
    $chkShow.Text        = "Show password"
    $chkShow.Font        = $LF_UISm
    $chkShow.ForeColor   = $LC_TextSec
    $chkShow.Location    = New-Object System.Drawing.Point(52, 304)
    $chkShow.Size        = New-Object System.Drawing.Size(130, 20)
    $chkShow.FlatStyle   = "Flat"
    $chkShow.Add_CheckedChanged({
        $txtPass.UseSystemPasswordChar = -not $chkShow.Checked
    })
    $pnlRight.Controls.Add($chkShow)

    # -- Error label --
    $lblError            = New-Object System.Windows.Forms.Label
    $lblError.Text       = ""
    $lblError.Font       = $LF_UISm
    $lblError.ForeColor  = $LC_Red
    $lblError.Location   = New-Object System.Drawing.Point(52, 334)
    $lblError.Size       = New-Object System.Drawing.Size(400, 18)
    $pnlRight.Controls.Add($lblError)

    # -- Login button --
    $btnLogin            = New-Object System.Windows.Forms.Button
    $btnLogin.Text       = "Sign In  ?"
    $btnLogin.Size       = New-Object System.Drawing.Size(400, 42)
    $btnLogin.Location   = New-Object System.Drawing.Point(52, 362)
    $btnLogin.BackColor  = $LC_Teal
    $btnLogin.ForeColor  = $LC_White
    $btnLogin.FlatStyle  = "Flat"
    $btnLogin.FlatAppearance.BorderSize = 0
    $btnLogin.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 140, 150)
    $btnLogin.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(0, 120, 130)
    $btnLogin.Font       = $LF_Bold
    $btnLogin.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $pnlRight.Controls.Add($btnLogin)

    # -- Attempt counter & lockout --
    $script:LoginAttempts = 0
    $script:MaxAttempts   = 5
    $script:LoginSuccess  = $false

    $doLogin = {
        $u = $txtUser.Text.Trim()
        $p = $txtPass.Text

        if ([string]::IsNullOrWhiteSpace($u) -or [string]::IsNullOrWhiteSpace($p)) {
            $lblError.Text = "Please enter both username and password."
            return
        }

        if ($u -eq "admin" -and $p -eq "M03@2026!") {
            $script:LoginSuccess = $true
            $lblError.ForeColor  = $LC_Green
            $lblError.Text       = "Authentication successful. Loading…"
            $btnLogin.Enabled    = $false
            Start-Sleep -Milliseconds 600
            $dlg.DialogResult    = [System.Windows.Forms.DialogResult]::OK
            $dlg.Close()
        } else {
            $script:LoginAttempts++
            $remaining = $script:MaxAttempts - $script:LoginAttempts
            if ($script:LoginAttempts -ge $script:MaxAttempts) {
                $lblError.Text    = "Too many failed attempts. Access blocked."
                $btnLogin.Enabled = $false
                $txtUser.Enabled  = $false
                $txtPass.Enabled  = $false
            } else {
                $lblError.Text = "Invalid credentials. $remaining attempt(s) remaining."
            }
            $txtPass.Clear()
            $txtPass.Focus()
        }
    }

    $btnLogin.Add_Click($doLogin)

    $txtPass.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { & $doLogin }
    })
    $txtUser.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $txtPass.Focus() }
    })

    # -- Footer text --
    $lblFooter           = New-Object System.Windows.Forms.Label
    $lblFooter.Text      = "This system is for authorised MOEHE personnel only.  ·  Helpdesk Division"
    $lblFooter.Font      = $LF_Tiny
    $lblFooter.ForeColor = $LC_TextSec
    $lblFooter.TextAlign = "MiddleCenter"
    $lblFooter.Location  = New-Object System.Drawing.Point(0, 488)
    $lblFooter.Size      = New-Object System.Drawing.Size(516, 20)
    $pnlRight.Controls.Add($lblFooter)

    $dlg.AcceptButton    = $btnLogin

    # Closing the window (X button) must also be treated as a failed login
    $dlg.Add_FormClosing({
        param($s, $e)
        if (-not $script:LoginSuccess) {
            $script:LoginSuccess = $false
        }
    })

    $txtUser.Focus()
    [void]$dlg.ShowDialog()
    $dlg.Dispose()

    # Explicitly return $false if success was never set to $true
    if ($script:LoginSuccess -ne $true) { return $false }
    return $true
}

# -- Run login before anything else ------------------
$authenticated = Show-LoginForm
if ($authenticated -ne $true) {
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@

$type = Add-Type -MemberDefinition $memberDefinition -Name "Win32ShowWindowAsync" -Namespace "Win32Functions" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# CONFIGURATION — edit these values
# =====================================================

$TenantId     = ""
$ClientId     = ""
$ClientSecret = ""

$AllowedIPs = @(
    "103.225.74.17"
    "172.16.0.0/16"
    "172.21.0.0/16"
)

# =====================================================
# DESIGN TOKENS
# =====================================================
$C_NavyDark  = [System.Drawing.Color]::FromArgb(10,  25,  60)
$C_Navy      = [System.Drawing.Color]::FromArgb(15,  40,  90)
$C_Teal      = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_White     = [System.Drawing.Color]::White
$C_Surface   = [System.Drawing.Color]::FromArgb(245, 247, 251)
$C_Border    = [System.Drawing.Color]::FromArgb(220, 226, 235)
$C_TextPri   = [System.Drawing.Color]::FromArgb(18,  30,  55)
$C_TextSec   = [System.Drawing.Color]::FromArgb(100, 116, 139)
$C_RowAlt    = [System.Drawing.Color]::FromArgb(248, 250, 253)
$C_SelBg     = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_Green     = [System.Drawing.Color]::FromArgb(22,  163, 74)
$C_Red       = [System.Drawing.Color]::FromArgb(220, 38,  38)
$C_Orange    = [System.Drawing.Color]::FromArgb(234, 88,  12)

$F_UI        = New-Object System.Drawing.Font("Segoe UI", 9)
$F_UISm      = New-Object System.Drawing.Font("Segoe UI", 8)
$F_UIBold    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$F_Sub       = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)

# =====================================================
# GEOFENCE — runs before anything opens
# =====================================================

function Test-IPInCIDR {
    param([string]$IP, [string]$CIDR)
    try {
        $parts     = $CIDR -split "/"
        $baseIP    = [System.Net.IPAddress]::Parse($parts[0])
        $prefix    = [int]$parts[1]
        $testIP    = [System.Net.IPAddress]::Parse($IP)
        $baseBytes = $baseIP.GetAddressBytes()
        $testBytes = $testIP.GetAddressBytes()
        if ($baseBytes.Length -ne $testBytes.Length) { return $false }
        [Array]::Reverse($baseBytes)
        [Array]::Reverse($testBytes)
        $baseInt = [System.BitConverter]::ToUInt32($baseBytes, 0)
        $testInt = [System.BitConverter]::ToUInt32($testBytes, 0)
        $mask    = [uint32](0xFFFFFFFF -shl (32 - $prefix))
        return (($baseInt -band $mask) -eq ($testInt -band $mask))
    } catch { return $false }
}

function Assert-Geofence {
    try {
        $publicIP = $null
        foreach ($svc in @("https://api.ipify.org", "https://checkip.amazonaws.com")) {
            try {
                $publicIP = (Invoke-RestMethod -Uri $svc -TimeoutSec 5 -ErrorAction Stop).Trim()
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
            if ($entry -match "/") {
                if (Test-IPInCIDR -IP $publicIP -CIDR $entry) { $allowed = $true; break }
            } else {
                if ($publicIP -eq $entry) { $allowed = $true; break }
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
# CREDENTIALS
# =====================================================

function Ensure-Credentials {
    if ([string]::IsNullOrWhiteSpace($script:TenantId)) {
        $script:TenantId = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your Azure Tenant ID:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:TenantId)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
    if ([string]::IsNullOrWhiteSpace($script:ClientId)) {
        $script:ClientId = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your App (Client) ID:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:ClientId)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
    if ([string]::IsNullOrWhiteSpace($script:ClientSecret)) {
        $script:ClientSecret = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your Client Secret:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:ClientSecret)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
}

# =====================================================
# TOKEN — cached, auto-refreshed
# =====================================================

$script:CachedToken = $null
$script:TokenExpiry = [datetime]::MinValue

function Get-GraphToken {
    Ensure-Credentials
    if (-not $script:TenantId -or -not $script:ClientId -or -not $script:ClientSecret) {
        [System.Windows.Forms.MessageBox]::Show("Credentials incomplete.", "Config Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
    if ($script:CachedToken -and ([datetime]::UtcNow -lt $script:TokenExpiry.AddMinutes(-5))) {
        return $script:CachedToken
    }
    $body = @{
        client_id     = $script:ClientId
        client_secret = $script:ClientSecret
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }
    try {
        $resp = Invoke-RestMethod -Method POST `
            -Uri "https://login.microsoftonline.com/$($script:TenantId)/oauth2/v2.0/token" `
            -Body $body -ErrorAction Stop
        $script:CachedToken = $resp.access_token
        $script:TokenExpiry = [datetime]::UtcNow.AddSeconds($resp.expires_in)
        return $script:CachedToken
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Authentication failed.`n`n$($_.Exception.Message)",
            "Auth Error",
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
    $pageUri = $StartUri
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $pageUri -Headers $Headers -ErrorAction Stop
        foreach ($item in $resp.value) {
            if ($Seen.Add($item.id)) { $Accumulator.Add($item) }
        }
        $pageUri = $resp.'@odata.nextLink'
        [System.Windows.Forms.Application]::DoEvents()
    } while ($pageUri)
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

    $encoded   = [Uri]::EscapeDataString($SearchText)
    $uriSearch = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$search=$encoded&`$count=true&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriSearch -Headers $hdrSearch -Accumulator $all -Seen $seen
    } catch { }

    $uriFilter = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$filter=startsWith(deviceName,'$safe')" +
                 " or startsWith(emailAddress,'$safe')" +
                 " or startsWith(serialNumber,'$safe')" +
                 "&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriFilter -Headers $hdrPlain -Accumulator $all -Seen $seen
    } catch { }

    $pageUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
               "?`$select=$select,id&`$top=999"
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
            "Graph API error during full scan.`n`n$($_.Exception.Message)", "Error",
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
        "ok"    { $C_Green }
        "warn"  { $C_Orange }
        "err"   { $C_Red }
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
    $dlg.MaximizeBox     = $false
    $dlg.MinimizeBox     = $false
    $dlg.BackColor       = $C_White
    $dlg.Font            = $F_UI

    $banner              = New-Object System.Windows.Forms.Panel
    $banner.Dock         = "Top"
    $banner.Height       = 80
    $banner.BackColor    = $C_NavyDark
    $dlg.Controls.Add($banner)

    $lblOrg              = New-Object System.Windows.Forms.Label
    $lblOrg.Text         = "Ministry of Education and Higher Education"
    $lblOrg.Font         = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblOrg.ForeColor    = $C_White
    $lblOrg.Location     = New-Object System.Drawing.Point(20, 14)
    $lblOrg.Size         = New-Object System.Drawing.Size(430, 22)
    $banner.Controls.Add($lblOrg)

    $lblSub2             = New-Object System.Windows.Forms.Label
    $lblSub2.Text        = "MOEHE"
    $lblSub2.Font        = $F_Sub
    $lblSub2.ForeColor   = [System.Drawing.Color]::FromArgb(160, 200, 230)
    $lblSub2.Location    = New-Object System.Drawing.Point(20, 40)
    $lblSub2.Size        = New-Object System.Drawing.Size(430, 18)
    $banner.Controls.Add($lblSub2)

    $accent2             = New-Object System.Windows.Forms.Panel
    $accent2.Dock        = "Top"
    $accent2.Height      = 3
    $accent2.BackColor   = $C_Teal
    $dlg.Controls.Add($accent2)

    $body                = New-Object System.Windows.Forms.Label
    $body.Text           = @"
Intune Device Lookup Tool
Version 3.1  |  Internal Use Only

This tool provides helpdesk staff with fast, read-only
access to managed device records via the Microsoft Graph
API (Intune / Microsoft Endpoint Manager).
- The Tool should only be used as per MOEHE Requirements

Features:
  - Server-side search with OData + Graph search
  - Token caching — no repeated authentication overhead
  - Geofenced access — MOEHE networks only
  - Compliance status, OS, serial, and enrolment data
  - Right-click copy for hostname, email, or full row
  - Export results to CSV

Access is restricted by IP geofence. Unauthorised use
or access attempts are logged.

Created by MOEHE System Team
"@
    $body.Location       = New-Object System.Drawing.Point(24, 100)
    $body.Size           = New-Object System.Drawing.Size(420, 210)
    $body.ForeColor      = $C_TextPri
    $body.Font           = $F_UI
    $dlg.Controls.Add($body)

    $btnOK               = New-Object System.Windows.Forms.Button
    $btnOK.Text          = "Close"
    $btnOK.Size          = New-Object System.Drawing.Size(90, 30)
    $btnOK.Location      = New-Object System.Drawing.Point(370, 290)
    $btnOK.BackColor     = $C_Teal
    $btnOK.ForeColor     = $C_White
    $btnOK.FlatStyle     = "Flat"
    $btnOK.FlatAppearance.BorderSize = 0
    $btnOK.DialogResult  = [System.Windows.Forms.DialogResult]::OK
    $dlg.Controls.Add($btnOK)
    $dlg.AcceptButton    = $btnOK

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
    $btn                                        = New-Object System.Windows.Forms.Button
    $btn.Text                                   = $Text
    $btn.Location                               = $Location
    $btn.Size                                   = $Size
    $btn.Anchor                                 = $Anchor
    $btn.BackColor                              = $BG
    $btn.ForeColor                              = $FG
    $btn.FlatStyle                              = "Flat"
    $btn.FlatAppearance.BorderSize              = 0
    $btn.FlatAppearance.MouseOverBackColor      = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 20), [Math]::Max(0, $BG.G - 20), [Math]::Max(0, $BG.B - 20))
    $btn.FlatAppearance.MouseDownBackColor      = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 40), [Math]::Max(0, $BG.G - 40), [Math]::Max(0, $BG.B - 40))
    $btn.Font                                   = $F_UIBold
    $btn.Cursor                                 = [System.Windows.Forms.Cursors]::Hand
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

# -- HEADER PANEL --------------------------------------
$pnlHeader           = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock      = "Top"
$pnlHeader.Height    = 68
$pnlHeader.BackColor = $C_NavyDark

$lblMOE              = New-Object System.Windows.Forms.Label
$lblMOE.Text         = "Ministry of Education and Higher Education"
$lblMOE.Font         = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$lblMOE.ForeColor    = $C_White
$lblMOE.Location     = New-Object System.Drawing.Point(20, 10)
$lblMOE.Size         = New-Object System.Drawing.Size(620, 26)
$pnlHeader.Controls.Add($lblMOE)

$lblSub              = New-Object System.Windows.Forms.Label
$lblSub.Text         = "Intune Device Lookup  ·  Helpdesk Portal"
$lblSub.Font         = $F_Sub
$lblSub.ForeColor    = [System.Drawing.Color]::FromArgb(140, 180, 220)
$lblSub.Location     = New-Object System.Drawing.Point(22, 38)
$lblSub.Size         = New-Object System.Drawing.Size(500, 18)
$pnlHeader.Controls.Add($lblSub)

$btnAbout            = New-ModernButton -Text "About" `
    -Location (New-Object System.Drawing.Point(990, 19)) `
    -Size (New-Object System.Drawing.Size(72, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$btnAbout.Font       = $F_UISm
$pnlHeader.Controls.Add($btnAbout)

$lblIP               = New-Object System.Windows.Forms.Label
$lblIP.Text          = "IP: $($script:PublicIP)"
$lblIP.Font          = $F_UISm
$lblIP.ForeColor     = [System.Drawing.Color]::FromArgb(100, 180, 210)
$lblIP.TextAlign     = "MiddleRight"
$lblIP.Location      = New-Object System.Drawing.Point(800, 24)
$lblIP.Size          = New-Object System.Drawing.Size(180, 20)
$lblIP.Anchor        = "Top,Right"
$pnlHeader.Controls.Add($lblIP)

# -- TEAL ACCENT LINE ----------------------------------
$pnlAccent           = New-Object System.Windows.Forms.Panel
$pnlAccent.Dock      = "Top"
$pnlAccent.Height    = 3
$pnlAccent.BackColor = $C_Teal

# -- SEARCH CARD ---------------------------------------
$pnlSearch           = New-Object System.Windows.Forms.Panel
$pnlSearch.Dock      = "Top"
$pnlSearch.Height    = 72
$pnlSearch.BackColor = $C_White
$pnlSearch.Padding   = New-Object System.Windows.Forms.Padding(16, 0, 16, 0)

$pnlSearch.Add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($C_Border, 1)
    $e.Graphics.DrawLine($pen, 0, $pnlSearch.Height - 1, $pnlSearch.Width, $pnlSearch.Height - 1)
    $pen.Dispose()
})

$lblSearchLbl           = New-Object System.Windows.Forms.Label
$lblSearchLbl.Text      = "SEARCH BY DEVICE NAME / USERNAME"
$lblSearchLbl.Font      = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblSearchLbl.ForeColor = $C_Teal
$lblSearchLbl.Location  = New-Object System.Drawing.Point(18, 10)
$lblSearchLbl.Size      = New-Object System.Drawing.Size(200, 14)
$pnlSearch.Controls.Add($lblSearchLbl)

$txtSearch              = New-Object System.Windows.Forms.TextBox
$txtSearch.Location     = New-Object System.Drawing.Point(18, 30)
$txtSearch.Size         = New-Object System.Drawing.Size(620, 26)
$txtSearch.Anchor       = "Top,Left,Right"
$txtSearch.Font         = $F_UI
$txtSearch.ForeColor    = $C_TextPri
$txtSearch.BackColor    = $C_Surface
$txtSearch.BorderStyle  = "FixedSingle"
$pnlSearch.Controls.Add($txtSearch)

$btnSearch              = New-ModernButton -Text "Search" `
    -Location (New-Object System.Drawing.Point(650, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG $C_Teal -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnSearch)

$btnClear               = New-ModernButton -Text "Clear" `
    -Location (New-Object System.Drawing.Point(760, 28)) `
    -Size (New-Object System.Drawing.Size(76, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(226, 232, 240)) -FG $C_TextPri -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnClear)

$btnCopyHost            = New-ModernButton -Text "Copy Hostname" `
    -Location (New-Object System.Drawing.Point(846, 28)) `
    -Size (New-Object System.Drawing.Size(115, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 80, 60)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnCopyHost)

$btnExport              = New-ModernButton -Text "Export CSV" `
    -Location (New-Object System.Drawing.Point(971, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnExport)

# -- STATUS BAR ----------------------------------------
$pnlFooter              = New-Object System.Windows.Forms.Panel
$pnlFooter.Dock         = "Bottom"
$pnlFooter.Height       = 30
$pnlFooter.BackColor    = $C_NavyDark

$script:lblStatus       = New-Object System.Windows.Forms.Label
$script:lblStatus.Text  = "  Ready — enter a search term above"
$script:lblStatus.Font  = $F_UISm
$script:lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(160, 185, 215)
$script:lblStatus.Location  = New-Object System.Drawing.Point(0, 7)
$script:lblStatus.Size      = New-Object System.Drawing.Size(700, 18)
$script:lblStatus.Anchor    = "Top,Left,Right"
$pnlFooter.Controls.Add($script:lblStatus)

$lblClock               = New-Object System.Windows.Forms.Label
$lblClock.Font          = $F_UISm
$lblClock.ForeColor     = [System.Drawing.Color]::FromArgb(120, 155, 190)
$lblClock.TextAlign     = "MiddleRight"
$lblClock.Size          = New-Object System.Drawing.Size(260, 18)
$lblClock.Location      = New-Object System.Drawing.Point(810, 7)
$lblClock.Anchor        = "Top,Right"
$pnlFooter.Controls.Add($lblClock)

$timer                  = New-Object System.Windows.Forms.Timer
$timer.Interval         = 1000
$timer.Add_Tick({ $lblClock.Text = (Get-Date -Format "ddd dd MMM yyyy  HH:mm:ss  ") })
$timer.Start()

# -- GRID PANEL (fills remaining space) ----------------
$pnlGrid                = New-Object System.Windows.Forms.Panel
$pnlGrid.Dock           = "Fill"
$pnlGrid.BackColor      = $C_Surface
$pnlGrid.Padding        = New-Object System.Windows.Forms.Padding(14, 10, 14, 8)

$grid                                           = New-Object System.Windows.Forms.DataGridView
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
    @{ Name="Hostname";   Header="HOSTNAME";    Fill=14 }
    @{ Name="User";       Header="USER";        Fill=16 }
    @{ Name="Email";      Header="EMAIL";       Fill=18 }
    @{ Name="OS";         Header="OS";          Fill=8  }
    @{ Name="OSVer";      Header="OS VERSION";  Fill=12 }
    @{ Name="Compliance"; Header="COMPLIANCE";  Fill=10 }
    @{ Name="Serial";     Header="SERIAL";      Fill=12 }
    @{ Name="LastSync";   Header="LAST SYNC";   Fill=13 }
    @{ Name="Enrolled";   Header="ENROLLED";    Fill=9  }
)
foreach ($c in $colDefs) {
    $col            = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col.Name       = $c.Name
    $col.HeaderText = $c.Header
    $col.FillWeight = $c.Fill
    $col.SortMode   = "Automatic"
    [void]$grid.Columns.Add($col)
}

$form.Controls.Add($pnlFooter)
$form.Controls.Add($pnlGrid)
$form.Controls.Add($pnlSearch)
$form.Controls.Add($pnlAccent)
$form.Controls.Add($pnlHeader)

# -- POPULATE GRID -------------------------------------

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
    $e.CellStyle.Font        = $F_UIBold
    $e.FormattingApplied     = $true
})

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

function Export-ResultsCSV {
    if ($grid.Rows.Count -eq 0) {
        Set-Status "No results to export." "warn"
        return
    }
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Title      = "Export Results"
    $dlg.Filter     = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $dlg.FileName   = "MOEHE-Intune-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
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

$mnuExp.Add_Click({ Export-ResultsCSV })
$btnExport.Add_Click({ Export-ResultsCSV })

$btnCopyHost.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $v = $grid.SelectedRows[0].Cells["Hostname"].Value
        if ($v -and "$v".Trim() -ne "") {
            [System.Windows.Forms.Clipboard]::SetText([string]$v)
            Set-Status "Hostname '$v' copied to clipboard." "ok"
        } else {
            Set-Status "No hostname on selected row." "warn"
        }
    } else {
        Set-Status "Select a row first." "warn"
    }
})

$btnSearch.Add_Click({
    $q = $txtSearch.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($q)) {
        Set-Status "Please enter a search term." "warn"
        return
    }
    Set-Status "Searching for '$q'…" "info"
    $btnSearch.Enabled   = $false
    $btnClear.Enabled    = $false
    $btnExport.Enabled   = $false
    $btnCopyHost.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
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
        [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
    }
})

$btnClear.Add_Click({
    $txtSearch.Clear()
    $grid.Rows.Clear()
    Set-Status "Ready — enter a search term above" "info"
    $txtSearch.Focus()
})

$txtSearch.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $btnSearch.PerformClick() }
})

$btnAbout.Add_Click({ Show-About })

$form.Add_Resize({
    $btnAbout.Left = $form.ClientSize.Width - $btnAbout.Width - 20
    $lblIP.Left    = $form.ClientSize.Width - $lblIP.Width - $btnAbout.Width - 28
    $txtSearch.Width   = $pnlSearch.Width - 460
    $btnSearch.Left    = $txtSearch.Right + 10
    $btnClear.Left     = $btnSearch.Right + 8
    $btnCopyHost.Left  = $btnClear.Right + 8
    $btnExport.Left    = $btnCopyHost.Right + 8
})

# =====================================================
# LAUNCH
# =====================================================

[void]$form.ShowDialog()
$timer.Stop()
$form.Dispose()# =====================================================
# ASSEMBLIES + HIDE CONSOLE — must be first
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@
$type   = Add-Type -MemberDefinition $memberDefinition -Name "Win32ShowWindowAsync" -Namespace "Win32Functions" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# LOGIN FORM — shown before geofence / main UI
# =====================================================

function Show-LoginForm {
    # Design tokens (duplicated here so login runs before main token block)
    $LC_NavyDark = [System.Drawing.Color]::FromArgb(10,  25,  60)
    $LC_Navy     = [System.Drawing.Color]::FromArgb(15,  40,  90)
    $LC_Teal     = [System.Drawing.Color]::FromArgb(0,   162, 173)
    $LC_White    = [System.Drawing.Color]::White
    $LC_Surface  = [System.Drawing.Color]::FromArgb(245, 247, 251)
    $LC_Border   = [System.Drawing.Color]::FromArgb(200, 215, 230)
    $LC_TextPri  = [System.Drawing.Color]::FromArgb(18,  30,  55)
    $LC_TextSec  = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $LC_Red      = [System.Drawing.Color]::FromArgb(220, 38,  38)
    $LC_Green    = [System.Drawing.Color]::FromArgb(22,  163, 74)

    $LF_UI      = New-Object System.Drawing.Font("Segoe UI", 9)
    $LF_UISm    = New-Object System.Drawing.Font("Segoe UI", 8)
    $LF_Bold    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
    $LF_Title   = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $LF_Sub     = New-Object System.Drawing.Font("Segoe UI", 8)
    $LF_Tiny    = New-Object System.Drawing.Font("Segoe UI", 7.5)
    $LF_LabelSm = New-Object System.Drawing.Font("Segoe UI", 7,  [System.Drawing.FontStyle]::Bold)
    $LF_Hero    = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $LF_HeroSm  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    $dlg                 = New-Object System.Windows.Forms.Form
    $dlg.Text            = "MOEHE — Secure Login"
    $dlg.Size            = New-Object System.Drawing.Size(860, 520)
    $dlg.MinimumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.MaximumSize     = New-Object System.Drawing.Size(860, 520)
    $dlg.StartPosition   = "CenterScreen"
    $dlg.FormBorderStyle = "FixedSingle"
    $dlg.MaximizeBox     = $false
    $dlg.BackColor       = $LC_White
    $dlg.Font            = $LF_UI

    # -- LEFT PANEL (branding / info) ------------------
    $pnlLeft             = New-Object System.Windows.Forms.Panel
    $pnlLeft.Size        = New-Object System.Drawing.Size(340, 520)
    $pnlLeft.Location    = New-Object System.Drawing.Point(0, 0)
    $pnlLeft.BackColor   = $LC_NavyDark
    $dlg.Controls.Add($pnlLeft)

    # Teal accent bar on right edge of left panel
    $pnlLeftAccent           = New-Object System.Windows.Forms.Panel
    $pnlLeftAccent.Size      = New-Object System.Drawing.Size(4, 520)
    $pnlLeftAccent.Location  = New-Object System.Drawing.Point(336, 0)
    $pnlLeftAccent.BackColor = $LC_Teal
    $dlg.Controls.Add($pnlLeftAccent)

    # Logo / crest area (teal circle placeholder)
    $pnlCrest            = New-Object System.Windows.Forms.Panel
    $pnlCrest.Size       = New-Object System.Drawing.Size(72, 72)
    $pnlCrest.Location   = New-Object System.Drawing.Point(34, 44)
    $pnlCrest.BackColor  = $LC_NavyDark
    $pnlLeft.Controls.Add($pnlCrest)

    $pnlCrest.Add_Paint({
        param($s2, $e2)
        $g   = $e2.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        # Outer teal ring
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($LC_Teal)), 0, 0, 70, 70)
        # Inner navy circle
        $g.FillEllipse((New-Object System.Drawing.SolidBrush($LC_NavyDark)), 6, 6, 58, 58)
        # Monogram "M"
        $font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $sf   = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString("M", $font, (New-Object System.Drawing.SolidBrush($LC_Teal)), [System.Drawing.RectangleF]::new(0,0,70,70), $sf)
    })

    $lblOrg1             = New-Object System.Windows.Forms.Label
    $lblOrg1.Text        = "Ministry of Education"
    $lblOrg1.Font        = $LF_HeroSm
    $lblOrg1.ForeColor   = $LC_White
    $lblOrg1.Location    = New-Object System.Drawing.Point(34, 128)
    $lblOrg1.Size        = New-Object System.Drawing.Size(280, 22)
    $pnlLeft.Controls.Add($lblOrg1)

    $lblOrg2             = New-Object System.Windows.Forms.Label
    $lblOrg2.Text        = "and Higher Education"
    $lblOrg2.Font        = $LF_HeroSm
    $lblOrg2.ForeColor   = $LC_White
    $lblOrg2.Location    = New-Object System.Drawing.Point(34, 150)
    $lblOrg2.Size        = New-Object System.Drawing.Size(280, 22)
    $pnlLeft.Controls.Add($lblOrg2)

    $lblAbbr             = New-Object System.Windows.Forms.Label
    $lblAbbr.Text        = "MOEHE"
    $lblAbbr.Font        = $LF_Sub
    $lblAbbr.ForeColor   = [System.Drawing.Color]::FromArgb(0, 162, 173)
    $lblAbbr.Location    = New-Object System.Drawing.Point(34, 178)
    $lblAbbr.Size        = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblAbbr)

    # Divider line
    $pnlDiv              = New-Object System.Windows.Forms.Panel
    $pnlDiv.Size         = New-Object System.Drawing.Size(260, 1)
    $pnlDiv.Location     = New-Object System.Drawing.Point(34, 208)
    $pnlDiv.BackColor    = [System.Drawing.Color]::FromArgb(35, 60, 100)
    $pnlLeft.Controls.Add($pnlDiv)

    # Info bullets
    $infoItems = @(
        [char]0x25CF + "  Intune Device Lookup Tool"
        [char]0x25CF + "  Read-only helpdesk access"
        [char]0x25CF + "  Geofenced — MOEHE networks only"
        [char]0x25CF + "  Microsoft Graph API integration"
        [char]0x25CF + "  Compliance & enrolment insights"
    )
    $y = 226
    foreach ($item in $infoItems) {
        $lbl           = New-Object System.Windows.Forms.Label
        $lbl.Text      = $item
        $lbl.Font      = $LF_Tiny
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(160, 195, 225)
        $lbl.Location  = New-Object System.Drawing.Point(34, $y)
        $lbl.Size      = New-Object System.Drawing.Size(280, 18)
        $pnlLeft.Controls.Add($lbl)
        $y += 22
    }

    # Warning box
    $pnlWarn             = New-Object System.Windows.Forms.Panel
    $pnlWarn.Size        = New-Object System.Drawing.Size(272, 72)
    $pnlWarn.Location    = New-Object System.Drawing.Point(34, 360)
    $pnlWarn.BackColor   = [System.Drawing.Color]::FromArgb(20, 50, 90)
    $pnlLeft.Controls.Add($pnlWarn)

    $pnlWarnAccent       = New-Object System.Windows.Forms.Panel
    $pnlWarnAccent.Size  = New-Object System.Drawing.Size(3, 72)
    $pnlWarnAccent.Location = New-Object System.Drawing.Point(0, 0)
    $pnlWarnAccent.BackColor = [System.Drawing.Color]::FromArgb(234, 88, 12)
    $pnlWarn.Controls.Add($pnlWarnAccent)

    $lblWarnH            = New-Object System.Windows.Forms.Label
    $lblWarnH.Text       = "AUTHORISED ACCESS ONLY"
    $lblWarnH.Font       = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
    $lblWarnH.ForeColor  = [System.Drawing.Color]::FromArgb(234, 88, 12)
    $lblWarnH.Location   = New-Object System.Drawing.Point(12, 10)
    $lblWarnH.Size       = New-Object System.Drawing.Size(250, 14)
    $pnlWarn.Controls.Add($lblWarnH)

    $lblWarnB            = New-Object System.Windows.Forms.Label
    $lblWarnB.Text       = "Unauthorised access attempts are logged and may result in disciplinary or legal action."
    $lblWarnB.Font       = $LF_Tiny
    $lblWarnB.ForeColor  = [System.Drawing.Color]::FromArgb(140, 175, 210)
    $lblWarnB.Location   = New-Object System.Drawing.Point(12, 28)
    $lblWarnB.Size       = New-Object System.Drawing.Size(252, 36)
    $pnlWarn.Controls.Add($lblWarnB)

    # Version tag bottom-left
    $lblVer              = New-Object System.Windows.Forms.Label
    $lblVer.Text         = "v3.1  ·  Internal Use Only"
    $lblVer.Font         = $LF_Tiny
    $lblVer.ForeColor    = [System.Drawing.Color]::FromArgb(60, 90, 130)
    $lblVer.Location     = New-Object System.Drawing.Point(34, 488)
    $lblVer.Size         = New-Object System.Drawing.Size(200, 16)
    $pnlLeft.Controls.Add($lblVer)

    # -- RIGHT PANEL (login fields) --------------------
    $pnlRight            = New-Object System.Windows.Forms.Panel
    $pnlRight.Size       = New-Object System.Drawing.Size(516, 520)
    $pnlRight.Location   = New-Object System.Drawing.Point(344, 0)
    $pnlRight.BackColor  = $LC_White
    $dlg.Controls.Add($pnlRight)

    # "Sign In" heading
    $lblSignIn           = New-Object System.Windows.Forms.Label
    $lblSignIn.Text      = "Sign In"
    $lblSignIn.Font      = $LF_Hero
    $lblSignIn.ForeColor = $LC_TextPri
    $lblSignIn.Location  = New-Object System.Drawing.Point(52, 72)
    $lblSignIn.Size      = New-Object System.Drawing.Size(300, 38)
    $pnlRight.Controls.Add($lblSignIn)

    $lblSignInSub        = New-Object System.Windows.Forms.Label
    $lblSignInSub.Text   = "Enter your credentials to access the Intune Device Lookup Portal."
    $lblSignInSub.Font   = $LF_Sub
    $lblSignInSub.ForeColor = $LC_TextSec
    $lblSignInSub.Location  = New-Object System.Drawing.Point(52, 116)
    $lblSignInSub.Size      = New-Object System.Drawing.Size(400, 32)
    $pnlRight.Controls.Add($lblSignInSub)

    # -- Username --
    $lblUser             = New-Object System.Windows.Forms.Label
    $lblUser.Text        = "USERNAME"
    $lblUser.Font        = $LF_LabelSm
    $lblUser.ForeColor   = $LC_Teal
    $lblUser.Location    = New-Object System.Drawing.Point(52, 172)
    $lblUser.Size        = New-Object System.Drawing.Size(120, 14)
    $pnlRight.Controls.Add($lblUser)

    $txtUser             = New-Object System.Windows.Forms.TextBox
    $txtUser.Location    = New-Object System.Drawing.Point(52, 190)
    $txtUser.Size        = New-Object System.Drawing.Size(400, 28)
    $txtUser.Font        = $LF_UI
    $txtUser.ForeColor   = $LC_TextPri
    $txtUser.BackColor   = $LC_Surface
    $txtUser.BorderStyle = "FixedSingle"
    $txtUser.Text        = ""
    $pnlRight.Controls.Add($txtUser)

    # bottom border accent for username
    $pnlUBorder          = New-Object System.Windows.Forms.Panel
    $pnlUBorder.Size     = New-Object System.Drawing.Size(400, 2)
    $pnlUBorder.Location = New-Object System.Drawing.Point(52, 216)
    $pnlUBorder.BackColor = $LC_Teal
    $pnlRight.Controls.Add($pnlUBorder)

    # -- Password --
    $lblPass             = New-Object System.Windows.Forms.Label
    $lblPass.Text        = "PASSWORD"
    $lblPass.Font        = $LF_LabelSm
    $lblPass.ForeColor   = $LC_Teal
    $lblPass.Location    = New-Object System.Drawing.Point(52, 248)
    $lblPass.Size        = New-Object System.Drawing.Size(120, 14)
    $pnlRight.Controls.Add($lblPass)

    $txtPass             = New-Object System.Windows.Forms.TextBox
    $txtPass.Location    = New-Object System.Drawing.Point(52, 266)
    $txtPass.Size        = New-Object System.Drawing.Size(400, 28)
    $txtPass.Font        = $LF_UI
    $txtPass.ForeColor   = $LC_TextPri
    $txtPass.BackColor   = $LC_Surface
    $txtPass.BorderStyle = "FixedSingle"
    $txtPass.UseSystemPasswordChar = $true
    $pnlRight.Controls.Add($txtPass)

    $pnlPBorder          = New-Object System.Windows.Forms.Panel
    $pnlPBorder.Size     = New-Object System.Drawing.Size(400, 2)
    $pnlPBorder.Location = New-Object System.Drawing.Point(52, 292)
    $pnlPBorder.BackColor = $LC_Teal
    $pnlRight.Controls.Add($pnlPBorder)

    # Show/hide password toggle
    $chkShow             = New-Object System.Windows.Forms.CheckBox
    $chkShow.Text        = "Show password"
    $chkShow.Font        = $LF_UISm
    $chkShow.ForeColor   = $LC_TextSec
    $chkShow.Location    = New-Object System.Drawing.Point(52, 304)
    $chkShow.Size        = New-Object System.Drawing.Size(130, 20)
    $chkShow.FlatStyle   = "Flat"
    $chkShow.Add_CheckedChanged({
        $txtPass.UseSystemPasswordChar = -not $chkShow.Checked
    })
    $pnlRight.Controls.Add($chkShow)

    # -- Error label --
    $lblError            = New-Object System.Windows.Forms.Label
    $lblError.Text       = ""
    $lblError.Font       = $LF_UISm
    $lblError.ForeColor  = $LC_Red
    $lblError.Location   = New-Object System.Drawing.Point(52, 334)
    $lblError.Size       = New-Object System.Drawing.Size(400, 18)
    $pnlRight.Controls.Add($lblError)

    # -- Login button --
    $btnLogin            = New-Object System.Windows.Forms.Button
    $btnLogin.Text       = "Sign In  ?"
    $btnLogin.Size       = New-Object System.Drawing.Size(400, 42)
    $btnLogin.Location   = New-Object System.Drawing.Point(52, 362)
    $btnLogin.BackColor  = $LC_Teal
    $btnLogin.ForeColor  = $LC_White
    $btnLogin.FlatStyle  = "Flat"
    $btnLogin.FlatAppearance.BorderSize = 0
    $btnLogin.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 140, 150)
    $btnLogin.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(0, 120, 130)
    $btnLogin.Font       = $LF_Bold
    $btnLogin.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $pnlRight.Controls.Add($btnLogin)

    # -- Attempt counter & lockout --
    $script:LoginAttempts = 0
    $script:MaxAttempts   = 5
    $script:LoginSuccess  = $false

    $doLogin = {
        $u = $txtUser.Text.Trim()
        $p = $txtPass.Text

        if ([string]::IsNullOrWhiteSpace($u) -or [string]::IsNullOrWhiteSpace($p)) {
            $lblError.Text = "Please enter both username and password."
            return
        }

        if ($u -eq "admin" -and $p -eq "M03@2026!") {
            $script:LoginSuccess = $true
            $lblError.ForeColor  = $LC_Green
            $lblError.Text       = "Authentication successful. Loading…"
            $btnLogin.Enabled    = $false
            Start-Sleep -Milliseconds 600
            $dlg.DialogResult    = [System.Windows.Forms.DialogResult]::OK
            $dlg.Close()
        } else {
            $script:LoginAttempts++
            $remaining = $script:MaxAttempts - $script:LoginAttempts
            if ($script:LoginAttempts -ge $script:MaxAttempts) {
                $lblError.Text    = "Too many failed attempts. Access blocked."
                $btnLogin.Enabled = $false
                $txtUser.Enabled  = $false
                $txtPass.Enabled  = $false
            } else {
                $lblError.Text = "Invalid credentials. $remaining attempt(s) remaining."
            }
            $txtPass.Clear()
            $txtPass.Focus()
        }
    }

    $btnLogin.Add_Click($doLogin)

    $txtPass.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { & $doLogin }
    })
    $txtUser.Add_KeyDown({
        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $txtPass.Focus() }
    })

    # -- Footer text --
    $lblFooter           = New-Object System.Windows.Forms.Label
    $lblFooter.Text      = "This system is for authorised MOEHE personnel only.  ·  Helpdesk Division"
    $lblFooter.Font      = $LF_Tiny
    $lblFooter.ForeColor = $LC_TextSec
    $lblFooter.TextAlign = "MiddleCenter"
    $lblFooter.Location  = New-Object System.Drawing.Point(0, 488)
    $lblFooter.Size      = New-Object System.Drawing.Size(516, 20)
    $pnlRight.Controls.Add($lblFooter)

    $dlg.AcceptButton    = $btnLogin

    # Closing the window (X button) must also be treated as a failed login
    $dlg.Add_FormClosing({
        param($s, $e)
        if (-not $script:LoginSuccess) {
            $script:LoginSuccess = $false
        }
    })

    $txtUser.Focus()
    [void]$dlg.ShowDialog()
    $dlg.Dispose()

    # Explicitly return $false if success was never set to $true
    if ($script:LoginSuccess -ne $true) { return $false }
    return $true
}

# -- Run login before anything else ------------------
$authenticated = Show-LoginForm
if ($authenticated -ne $true) {
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$memberDefinition = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@

$type = Add-Type -MemberDefinition $memberDefinition -Name "Win32ShowWindowAsync" -Namespace "Win32Functions" -PassThru
$handle = $type::GetConsoleWindow()
$type::ShowWindow($handle, 0) | Out-Null

# =====================================================
# CONFIGURATION — edit these values
# =====================================================

$TenantId     = ""
$ClientId     = ""
$ClientSecret = ""

$AllowedIPs = @(
    "103.225.74.17"
    "172.16.0.0/16"
    "172.21.0.0/16"
)

# =====================================================
# DESIGN TOKENS
# =====================================================
$C_NavyDark  = [System.Drawing.Color]::FromArgb(10,  25,  60)
$C_Navy      = [System.Drawing.Color]::FromArgb(15,  40,  90)
$C_Teal      = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_White     = [System.Drawing.Color]::White
$C_Surface   = [System.Drawing.Color]::FromArgb(245, 247, 251)
$C_Border    = [System.Drawing.Color]::FromArgb(220, 226, 235)
$C_TextPri   = [System.Drawing.Color]::FromArgb(18,  30,  55)
$C_TextSec   = [System.Drawing.Color]::FromArgb(100, 116, 139)
$C_RowAlt    = [System.Drawing.Color]::FromArgb(248, 250, 253)
$C_SelBg     = [System.Drawing.Color]::FromArgb(0,   162, 173)
$C_Green     = [System.Drawing.Color]::FromArgb(22,  163, 74)
$C_Red       = [System.Drawing.Color]::FromArgb(220, 38,  38)
$C_Orange    = [System.Drawing.Color]::FromArgb(234, 88,  12)

$F_UI        = New-Object System.Drawing.Font("Segoe UI", 9)
$F_UISm      = New-Object System.Drawing.Font("Segoe UI", 8)
$F_UIBold    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$F_Sub       = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)

# =====================================================
# GEOFENCE — runs before anything opens
# =====================================================

function Test-IPInCIDR {
    param([string]$IP, [string]$CIDR)
    try {
        $parts     = $CIDR -split "/"
        $baseIP    = [System.Net.IPAddress]::Parse($parts[0])
        $prefix    = [int]$parts[1]
        $testIP    = [System.Net.IPAddress]::Parse($IP)
        $baseBytes = $baseIP.GetAddressBytes()
        $testBytes = $testIP.GetAddressBytes()
        if ($baseBytes.Length -ne $testBytes.Length) { return $false }
        [Array]::Reverse($baseBytes)
        [Array]::Reverse($testBytes)
        $baseInt = [System.BitConverter]::ToUInt32($baseBytes, 0)
        $testInt = [System.BitConverter]::ToUInt32($testBytes, 0)
        $mask    = [uint32](0xFFFFFFFF -shl (32 - $prefix))
        return (($baseInt -band $mask) -eq ($testInt -band $mask))
    } catch { return $false }
}

function Assert-Geofence {
    try {
        $publicIP = $null
        foreach ($svc in @("https://api.ipify.org", "https://checkip.amazonaws.com")) {
            try {
                $publicIP = (Invoke-RestMethod -Uri $svc -TimeoutSec 5 -ErrorAction Stop).Trim()
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
            if ($entry -match "/") {
                if (Test-IPInCIDR -IP $publicIP -CIDR $entry) { $allowed = $true; break }
            } else {
                if ($publicIP -eq $entry) { $allowed = $true; break }
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
# CREDENTIALS
# =====================================================

function Ensure-Credentials {
    if ([string]::IsNullOrWhiteSpace($script:TenantId)) {
        $script:TenantId = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your Azure Tenant ID:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:TenantId)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
    if ([string]::IsNullOrWhiteSpace($script:ClientId)) {
        $script:ClientId = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your App (Client) ID:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:ClientId)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
    if ([string]::IsNullOrWhiteSpace($script:ClientSecret)) {
        $script:ClientSecret = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter your Client Secret:", "MOEHE — Configuration")
        if ([string]::IsNullOrWhiteSpace($script:ClientSecret)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Configuration cancelled.`nThe application will now close.",
                "MOEHE — Cancelled",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning)
            exit
        }
    }
}

# =====================================================
# TOKEN — cached, auto-refreshed
# =====================================================

$script:CachedToken = $null
$script:TokenExpiry = [datetime]::MinValue

function Get-GraphToken {
    Ensure-Credentials
    if (-not $script:TenantId -or -not $script:ClientId -or -not $script:ClientSecret) {
        [System.Windows.Forms.MessageBox]::Show("Credentials incomplete.", "Config Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
    if ($script:CachedToken -and ([datetime]::UtcNow -lt $script:TokenExpiry.AddMinutes(-5))) {
        return $script:CachedToken
    }
    $body = @{
        client_id     = $script:ClientId
        client_secret = $script:ClientSecret
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }
    try {
        $resp = Invoke-RestMethod -Method POST `
            -Uri "https://login.microsoftonline.com/$($script:TenantId)/oauth2/v2.0/token" `
            -Body $body -ErrorAction Stop
        $script:CachedToken = $resp.access_token
        $script:TokenExpiry = [datetime]::UtcNow.AddSeconds($resp.expires_in)
        return $script:CachedToken
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Authentication failed.`n`n$($_.Exception.Message)",
            "Auth Error",
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
    $pageUri = $StartUri
    do {
        $resp = Invoke-RestMethod -Method GET -Uri $pageUri -Headers $Headers -ErrorAction Stop
        foreach ($item in $resp.value) {
            if ($Seen.Add($item.id)) { $Accumulator.Add($item) }
        }
        $pageUri = $resp.'@odata.nextLink'
        [System.Windows.Forms.Application]::DoEvents()
    } while ($pageUri)
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

    $encoded   = [Uri]::EscapeDataString($SearchText)
    $uriSearch = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$search=$encoded&`$count=true&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriSearch -Headers $hdrSearch -Accumulator $all -Seen $seen
    } catch { }

    $uriFilter = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
                 "?`$filter=startsWith(deviceName,'$safe')" +
                 " or startsWith(emailAddress,'$safe')" +
                 " or startsWith(serialNumber,'$safe')" +
                 "&`$select=$select,id&`$top=999"
    try {
        Invoke-GraphPage -StartUri $uriFilter -Headers $hdrPlain -Accumulator $all -Seen $seen
    } catch { }

    $pageUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" +
               "?`$select=$select,id&`$top=999"
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
            "Graph API error during full scan.`n`n$($_.Exception.Message)", "Error",
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
        "ok"    { $C_Green }
        "warn"  { $C_Orange }
        "err"   { $C_Red }
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
    $dlg.MaximizeBox     = $false
    $dlg.MinimizeBox     = $false
    $dlg.BackColor       = $C_White
    $dlg.Font            = $F_UI

    $banner              = New-Object System.Windows.Forms.Panel
    $banner.Dock         = "Top"
    $banner.Height       = 80
    $banner.BackColor    = $C_NavyDark
    $dlg.Controls.Add($banner)

    $lblOrg              = New-Object System.Windows.Forms.Label
    $lblOrg.Text         = "Ministry of Education and Higher Education"
    $lblOrg.Font         = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblOrg.ForeColor    = $C_White
    $lblOrg.Location     = New-Object System.Drawing.Point(20, 14)
    $lblOrg.Size         = New-Object System.Drawing.Size(430, 22)
    $banner.Controls.Add($lblOrg)

    $lblSub2             = New-Object System.Windows.Forms.Label
    $lblSub2.Text        = "MOEHE"
    $lblSub2.Font        = $F_Sub
    $lblSub2.ForeColor   = [System.Drawing.Color]::FromArgb(160, 200, 230)
    $lblSub2.Location    = New-Object System.Drawing.Point(20, 40)
    $lblSub2.Size        = New-Object System.Drawing.Size(430, 18)
    $banner.Controls.Add($lblSub2)

    $accent2             = New-Object System.Windows.Forms.Panel
    $accent2.Dock        = "Top"
    $accent2.Height      = 3
    $accent2.BackColor   = $C_Teal
    $dlg.Controls.Add($accent2)

    $body                = New-Object System.Windows.Forms.Label
    $body.Text           = @"
Intune Device Lookup Tool
Version 3.1  |  Internal Use Only

This tool provides helpdesk staff with fast, read-only
access to managed device records via the Microsoft Graph
API (Intune / Microsoft Endpoint Manager).
- The Tool should only be used as per MOEHE Requirements

Features:
  - Server-side search with OData + Graph search
  - Token caching — no repeated authentication overhead
  - Geofenced access — MOEHE networks only
  - Compliance status, OS, serial, and enrolment data
  - Right-click copy for hostname, email, or full row
  - Export results to CSV

Access is restricted by IP geofence. Unauthorised use
or access attempts are logged.

Created by MOEHE System Team
"@
    $body.Location       = New-Object System.Drawing.Point(24, 100)
    $body.Size           = New-Object System.Drawing.Size(420, 210)
    $body.ForeColor      = $C_TextPri
    $body.Font           = $F_UI
    $dlg.Controls.Add($body)

    $btnOK               = New-Object System.Windows.Forms.Button
    $btnOK.Text          = "Close"
    $btnOK.Size          = New-Object System.Drawing.Size(90, 30)
    $btnOK.Location      = New-Object System.Drawing.Point(370, 290)
    $btnOK.BackColor     = $C_Teal
    $btnOK.ForeColor     = $C_White
    $btnOK.FlatStyle     = "Flat"
    $btnOK.FlatAppearance.BorderSize = 0
    $btnOK.DialogResult  = [System.Windows.Forms.DialogResult]::OK
    $dlg.Controls.Add($btnOK)
    $dlg.AcceptButton    = $btnOK

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
    $btn                                        = New-Object System.Windows.Forms.Button
    $btn.Text                                   = $Text
    $btn.Location                               = $Location
    $btn.Size                                   = $Size
    $btn.Anchor                                 = $Anchor
    $btn.BackColor                              = $BG
    $btn.ForeColor                              = $FG
    $btn.FlatStyle                              = "Flat"
    $btn.FlatAppearance.BorderSize              = 0
    $btn.FlatAppearance.MouseOverBackColor      = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 20), [Math]::Max(0, $BG.G - 20), [Math]::Max(0, $BG.B - 20))
    $btn.FlatAppearance.MouseDownBackColor      = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BG.R - 40), [Math]::Max(0, $BG.G - 40), [Math]::Max(0, $BG.B - 40))
    $btn.Font                                   = $F_UIBold
    $btn.Cursor                                 = [System.Windows.Forms.Cursors]::Hand
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

# -- HEADER PANEL --------------------------------------
$pnlHeader           = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock      = "Top"
$pnlHeader.Height    = 68
$pnlHeader.BackColor = $C_NavyDark

$lblMOE              = New-Object System.Windows.Forms.Label
$lblMOE.Text         = "Ministry of Education and Higher Education"
$lblMOE.Font         = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$lblMOE.ForeColor    = $C_White
$lblMOE.Location     = New-Object System.Drawing.Point(20, 10)
$lblMOE.Size         = New-Object System.Drawing.Size(620, 26)
$pnlHeader.Controls.Add($lblMOE)

$lblSub              = New-Object System.Windows.Forms.Label
$lblSub.Text         = "Intune Device Lookup  ·  Helpdesk Portal"
$lblSub.Font         = $F_Sub
$lblSub.ForeColor    = [System.Drawing.Color]::FromArgb(140, 180, 220)
$lblSub.Location     = New-Object System.Drawing.Point(22, 38)
$lblSub.Size         = New-Object System.Drawing.Size(500, 18)
$pnlHeader.Controls.Add($lblSub)

$btnAbout            = New-ModernButton -Text "About" `
    -Location (New-Object System.Drawing.Point(990, 19)) `
    -Size (New-Object System.Drawing.Size(72, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$btnAbout.Font       = $F_UISm
$pnlHeader.Controls.Add($btnAbout)

$lblIP               = New-Object System.Windows.Forms.Label
$lblIP.Text          = "IP: $($script:PublicIP)"
$lblIP.Font          = $F_UISm
$lblIP.ForeColor     = [System.Drawing.Color]::FromArgb(100, 180, 210)
$lblIP.TextAlign     = "MiddleRight"
$lblIP.Location      = New-Object System.Drawing.Point(800, 24)
$lblIP.Size          = New-Object System.Drawing.Size(180, 20)
$lblIP.Anchor        = "Top,Right"
$pnlHeader.Controls.Add($lblIP)

# -- TEAL ACCENT LINE ----------------------------------
$pnlAccent           = New-Object System.Windows.Forms.Panel
$pnlAccent.Dock      = "Top"
$pnlAccent.Height    = 3
$pnlAccent.BackColor = $C_Teal

# -- SEARCH CARD ---------------------------------------
$pnlSearch           = New-Object System.Windows.Forms.Panel
$pnlSearch.Dock      = "Top"
$pnlSearch.Height    = 72
$pnlSearch.BackColor = $C_White
$pnlSearch.Padding   = New-Object System.Windows.Forms.Padding(16, 0, 16, 0)

$pnlSearch.Add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($C_Border, 1)
    $e.Graphics.DrawLine($pen, 0, $pnlSearch.Height - 1, $pnlSearch.Width, $pnlSearch.Height - 1)
    $pen.Dispose()
})

$lblSearchLbl           = New-Object System.Windows.Forms.Label
$lblSearchLbl.Text      = "SEARCH BY DEVICE NAME / USERNAME"
$lblSearchLbl.Font      = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblSearchLbl.ForeColor = $C_Teal
$lblSearchLbl.Location  = New-Object System.Drawing.Point(18, 10)
$lblSearchLbl.Size      = New-Object System.Drawing.Size(200, 14)
$pnlSearch.Controls.Add($lblSearchLbl)

$txtSearch              = New-Object System.Windows.Forms.TextBox
$txtSearch.Location     = New-Object System.Drawing.Point(18, 30)
$txtSearch.Size         = New-Object System.Drawing.Size(620, 26)
$txtSearch.Anchor       = "Top,Left,Right"
$txtSearch.Font         = $F_UI
$txtSearch.ForeColor    = $C_TextPri
$txtSearch.BackColor    = $C_Surface
$txtSearch.BorderStyle  = "FixedSingle"
$pnlSearch.Controls.Add($txtSearch)

$btnSearch              = New-ModernButton -Text "Search" `
    -Location (New-Object System.Drawing.Point(650, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG $C_Teal -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnSearch)

$btnClear               = New-ModernButton -Text "Clear" `
    -Location (New-Object System.Drawing.Point(760, 28)) `
    -Size (New-Object System.Drawing.Size(76, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(226, 232, 240)) -FG $C_TextPri -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnClear)

$btnCopyHost            = New-ModernButton -Text "Copy Hostname" `
    -Location (New-Object System.Drawing.Point(846, 28)) `
    -Size (New-Object System.Drawing.Size(115, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 80, 60)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnCopyHost)

$btnExport              = New-ModernButton -Text "Export CSV" `
    -Location (New-Object System.Drawing.Point(971, 28)) `
    -Size (New-Object System.Drawing.Size(100, 30)) `
    -BG ([System.Drawing.Color]::FromArgb(30, 60, 110)) -FG $C_White -Anchor "Top,Right"
$pnlSearch.Controls.Add($btnExport)

# -- STATUS BAR ----------------------------------------
$pnlFooter              = New-Object System.Windows.Forms.Panel
$pnlFooter.Dock         = "Bottom"
$pnlFooter.Height       = 30
$pnlFooter.BackColor    = $C_NavyDark

$script:lblStatus       = New-Object System.Windows.Forms.Label
$script:lblStatus.Text  = "  Ready — enter a search term above"
$script:lblStatus.Font  = $F_UISm
$script:lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(160, 185, 215)
$script:lblStatus.Location  = New-Object System.Drawing.Point(0, 7)
$script:lblStatus.Size      = New-Object System.Drawing.Size(700, 18)
$script:lblStatus.Anchor    = "Top,Left,Right"
$pnlFooter.Controls.Add($script:lblStatus)

$lblClock               = New-Object System.Windows.Forms.Label
$lblClock.Font          = $F_UISm
$lblClock.ForeColor     = [System.Drawing.Color]::FromArgb(120, 155, 190)
$lblClock.TextAlign     = "MiddleRight"
$lblClock.Size          = New-Object System.Drawing.Size(260, 18)
$lblClock.Location      = New-Object System.Drawing.Point(810, 7)
$lblClock.Anchor        = "Top,Right"
$pnlFooter.Controls.Add($lblClock)

$timer                  = New-Object System.Windows.Forms.Timer
$timer.Interval         = 1000
$timer.Add_Tick({ $lblClock.Text = (Get-Date -Format "ddd dd MMM yyyy  HH:mm:ss  ") })
$timer.Start()

# -- GRID PANEL (fills remaining space) ----------------
$pnlGrid                = New-Object System.Windows.Forms.Panel
$pnlGrid.Dock           = "Fill"
$pnlGrid.BackColor      = $C_Surface
$pnlGrid.Padding        = New-Object System.Windows.Forms.Padding(14, 10, 14, 8)

$grid                                           = New-Object System.Windows.Forms.DataGridView
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
    @{ Name="Hostname";   Header="HOSTNAME";    Fill=14 }
    @{ Name="User";       Header="USER";        Fill=16 }
    @{ Name="Email";      Header="EMAIL";       Fill=18 }
    @{ Name="OS";         Header="OS";          Fill=8  }
    @{ Name="OSVer";      Header="OS VERSION";  Fill=12 }
    @{ Name="Compliance"; Header="COMPLIANCE";  Fill=10 }
    @{ Name="Serial";     Header="SERIAL";      Fill=12 }
    @{ Name="LastSync";   Header="LAST SYNC";   Fill=13 }
    @{ Name="Enrolled";   Header="ENROLLED";    Fill=9  }
)
foreach ($c in $colDefs) {
    $col            = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col.Name       = $c.Name
    $col.HeaderText = $c.Header
    $col.FillWeight = $c.Fill
    $col.SortMode   = "Automatic"
    [void]$grid.Columns.Add($col)
}

$form.Controls.Add($pnlFooter)
$form.Controls.Add($pnlGrid)
$form.Controls.Add($pnlSearch)
$form.Controls.Add($pnlAccent)
$form.Controls.Add($pnlHeader)

# -- POPULATE GRID -------------------------------------

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
    $e.CellStyle.Font        = $F_UIBold
    $e.FormattingApplied     = $true
})

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

function Export-ResultsCSV {
    if ($grid.Rows.Count -eq 0) {
        Set-Status "No results to export." "warn"
        return
    }
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Title      = "Export Results"
    $dlg.Filter     = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $dlg.FileName   = "MOEHE-Intune-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
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

$mnuExp.Add_Click({ Export-ResultsCSV })
$btnExport.Add_Click({ Export-ResultsCSV })

$btnCopyHost.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        $v = $grid.SelectedRows[0].Cells["Hostname"].Value
        if ($v -and "$v".Trim() -ne "") {
            [System.Windows.Forms.Clipboard]::SetText([string]$v)
            Set-Status "Hostname '$v' copied to clipboard." "ok"
        } else {
            Set-Status "No hostname on selected row." "warn"
        }
    } else {
        Set-Status "Select a row first." "warn"
    }
})

$btnSearch.Add_Click({
    $q = $txtSearch.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($q)) {
        Set-Status "Please enter a search term." "warn"
        return
    }
    Set-Status "Searching for '$q'…" "info"
    $btnSearch.Enabled   = $false
    $btnClear.Enabled    = $false
    $btnExport.Enabled   = $false
    $btnCopyHost.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
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
        [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
    }
})

$btnClear.Add_Click({
    $txtSearch.Clear()
    $grid.Rows.Clear()
    Set-Status "Ready — enter a search term above" "info"
    $txtSearch.Focus()
})

$txtSearch.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $btnSearch.PerformClick() }
})

$btnAbout.Add_Click({ Show-About })

$form.Add_Resize({
    $btnAbout.Left = $form.ClientSize.Width - $btnAbout.Width - 20
    $lblIP.Left    = $form.ClientSize.Width - $lblIP.Width - $btnAbout.Width - 28
    $txtSearch.Width   = $pnlSearch.Width - 460
    $btnSearch.Left    = $txtSearch.Right + 10
    $btnClear.Left     = $btnSearch.Right + 8
    $btnCopyHost.Left  = $btnClear.Right + 8
    $btnExport.Left    = $btnCopyHost.Right + 8
})

# =====================================================
# LAUNCH
# =====================================================

[void]$form.ShowDialog()
$timer.Stop()
$form.Dispose()

# SIG # Begin signature block
# MIIQqAYJKoZIhvcNAQcCoIIQmTCCEJUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSXk5pk1n+S5jR0R/OpOx84ZV
# AmCggg4UMIIGLzCCBBegAwIBAgITTgAAAAcCvNZR4FPQtwAAAAAABzANBgkqhkiG
# 9w0BAQ0FADAWMRQwEgYDVQQDEwtFRFUgUk9PVCBDQTAeFw0yMjExMDMwODQ4MzNa
# Fw0zMjExMDMwODU4MzNaMEYxEjAQBgoJkiaJk/IsZAEZFgJxYTEWMBQGCgmSJomT
# 8ixkARkWBnNlY2VkdTEYMBYGA1UEAxMPRURVIElTU1VJTkcgQ0ExMIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArgRAZJTH7AYuWo06gSd9fduraDqA0Bce
# TMYiaxUyzMMiT7uledTSenY/uyZjZV64CxL2FCQtJdGSw/ao3+HNCMKxoVovch9J
# 7nb4jwpJ0ZQmFPqasJlyxfw7HVAwPtN1rWH+X4iBmd7rtlWtTRaesiKOKsl2T6vB
# 2kFL4sZDoOdO5Rpd3x1MEjxXw5nNULHIAEzyrStSvE1B9Q9iuOVSFU32lLvT4+p3
# xwiPZRXYuzWqN8RXwOJDIoo2YFJv2lsnmIJ8hRMJez5YH5Bsz30lMtQRGI+VSCt3
# iLaPvRs9BaD10YRplNVF7WlmYupL54B5DdkZEwW65SCvD+n0KxGrTimAd1AWXAOZ
# au8YO4j7X9oZkfRcStKU3tvl7CMHRJugHIQdB+Cx/Dg6+FkLcz+OOGrXTslqlFmH
# FGI/k/Wf8OzZcAKFNK8ZODH/YJc0JNzvPlWljsmq/42yQVSNeANEgCDlhq0VgAMI
# UcxFHHsHCRaiYAC+KRZihC5vjHcACeQJedEs7UvEwbaG5+hyyjyFPMCf8XpFyeO5
# /qIPgBzKo6wUtLQPOPJlNehVCasQptiPWd/+/uIlTJZyYvOogJNgfITamuoKvSMt
# QPY2GjeAUY0v+kfqporov3VthpS+K1OmKNqgf0g0enBoLl3rObxI/tOtuqLoC80Z
# meA/0D+vOJkCAwEAAaOCAUQwggFAMBAGCSsGAQQBgjcVAQQDAgECMCMGCSsGAQQB
# gjcVAgQWBBQSkr6SvH/HlXVGp8M6P2a4oaVyZzAdBgNVHQ4EFgQU+mlLPOuT9CW0
# XJnxGSFX1akDp6UwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQD
# AgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAUHRCUNY5PkcXUNdz02x0w
# 6SM81FEwOQYDVR0fBDIwMDAuoCygKoYoaHR0cDovL3BraS5lZHUuZ292LnFhL3Br
# aS9FRFUtUk9PVENBLmNybDBTBggrBgEFBQcBAQRHMEUwQwYIKwYBBQUHMAKGN2h0
# dHA6Ly9wa2kuZWR1Lmdvdi5xYS9wa2kvRURVLVJPT1RDQUVEVSUyMFJPT1QlMjBD
# QS5jcnQwDQYJKoZIhvcNAQENBQADggIBAFfaSDREhYWHEiep5rDcDpRKBAZtjWon
# mEl8i+p5dmjmL+5J9BarI76b2z3Up2GFcZeTXnb7Q9ExC22KyQ1zO2h3tEad5Hv6
# efA0V68XEb0/KX2XZHuRqoVslK6dQXX3RSKV5DaKHsSC7mgQkhAfL1voCRJsx4ce
# dYrgUHnk4OureKHOn3x4ppqtljmbbt4lroL9gAI6EwjB9cAcqLyazbGtKW/ykHKn
# /1VCN0VbUKwix0d0PvQLXwuIRL1zTCJZXpUgiG19kUOtJUh6Ul9wil1KM0BeDpOR
# q0X08L/pKp2jSiDZ2eZ4hgrPvr+Eqp3TquAawlZSk8YC7+CrzMmWfhorK8+7+LHP
# PpHAdGsZIlnIz+/gdsuIS0UC5InmxLSPXbT3F0te4Y/0t84f4LgUPwiT9/SwXq5t
# gTR4bbs8bI9Ct1mOUoBcEf6s6jew7NuAuR6weLNaV4LSnZMF1y39cvbc0OidPJts
# 41W6710nloJ+u1uYC8GQcJCwxQOwFq/zH0ROTk2o54Qq7TiAfa1isi9m0DIPL2iW
# oSPLl0HwNtqCWIJ7Ry80CrXoKwQwPwObqUk69XJiojwd2x9WvgG+nwVO17sQlXto
# tgwmGRcpuIz83/O8OsIu2g0rCp1vPS3bdb7z/Y/zFLMjOoPn3JidiSzJ0I6QcjJg
# yZdLPU741V9uMIIH3TCCBcWgAwIBAgITKQAB4Ipwsty+ThrPJwACAAHgijANBgkq
# hkiG9w0BAQ0FADBGMRIwEAYKCZImiZPyLGQBGRYCcWExFjAUBgoJkiaJk/IsZAEZ
# FgZzZWNlZHUxGDAWBgNVBAMTD0VEVSBJU1NVSU5HIENBMTAeFw0yNTA5MDcwODI3
# MjlaFw0zMDA5MDYwODI3MjlaMIGKMRIwEAYKCZImiZPyLGQBGRYCcWExFjAUBgoJ
# kiaJk/IsZAEZFgZzZWNlZHUxDDAKBgNVBAsTA1BBVzEOMAwGA1UECxMFQWRtaW4x
# DzANBgNVBAsTBlRpZXIgMDEUMBIGA1UECxMLVDAtQWNjb3VudHMxFzAVBgNVBAMT
# Dk1PRS1Db2RlU2lnbmVyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# zOdBiPu6Z2IirpWIPlCAkf1n/09d2PLP95A5B9wnAL6kq97ye2REG4b0/x0mFrx7
# 52sDpTG+k5C+p2Xn3CgQiMDl8maON6AWtEIyayPuigZUrUxq5O1+iOeV5ikfX15C
# r7bpHw6R7Dr0DNHxXvoEIdj5aW/wIS2/oq9ZOOFfZ2FI9Y3at5PRkZGin7eU9laB
# y0ROtvLQ6P6hO9Y+vKj2ZyDrytv+dtG4V+cCCpOHTbJ/MBrdhHr1cGr0xYUqXg/5
# LHvz6eTXTwJ0+zWoleEkP4Lc5bG3iwWhH0qDy5ah2SZmn6fCkyRUruPGYrSUMnKn
# g7VL3aQneTdusMH+/cRCGQIDAQABo4IDfTCCA3kwPAYJKwYBBAGCNxUHBC8wLQYl
# KwYBBAGCNxUI6O9FhMmsd4T1lQ6CpdAphu+FT2KGmvlZhvy+YwIBZAIBCzATBgNV
# HSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGCNxUKBA4w
# DDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUeghrjGk9M01i7paK1zkyps8EzB4wHwYD
# VR0jBBgwFoAU+mlLPOuT9CW0XJnxGSFX1akDp6UwggEBBgNVHR8EgfkwgfYwgfOg
# gfCgge2Ggb5sZGFwOi8vL0NOPUVEVSUyMElTU1VJTkclMjBDQTEsQ049RENQUEtJ
# SVNTVUUwMSxDTj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vy
# dmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1zZWNlZHUsREM9cWE/Y2VydGlmaWNh
# dGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlv
# blBvaW50hipodHRwOi8vcGtpLmVkdS5nb3YucWEvcGtpL0VEVS1JU1NVSU5HMS5j
# cmwwggEpBggrBgEFBQcBAQSCARswggEXMIGwBggrBgEFBQcwAoaBo2xkYXA6Ly8v
# Q049RURVJTIwSVNTVUlORyUyMENBMSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1zZWNlZHUs
# REM9cWE/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRp
# b25BdXRob3JpdHkwOQYIKwYBBQUHMAKGLWh0dHA6Ly9wa2kuZWR1Lmdvdi5xYS9w
# a2kvRURVLUlTU1VJTkcxKDIpLmNydDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Au
# ZWR1Lmdvdi5xYS9vY3NwMDMGA1UdEQQsMCqgKAYKKwYBBAGCNxQCA6AaDBhNT0Ut
# Q29kZVNpZ25lckBzZWNlZHUucWEwUAYJKwYBBAGCNxkCBEMwQaA/BgorBgEEAYI3
# GQIBoDEEL1MtMS01LTIxLTk1NTgyMDY0Ny04MjQzNTk0MjAtMzAyNjQ2NzkyMS0z
# OTM5MTEzMA0GCSqGSIb3DQEBDQUAA4ICAQBU4Pc2JsqF6qT7+J52lfKjs1GPsI3i
# bgSNf5tdQbpJx+PjC51sMXn3lm+7RIAHdf3PTh1NQRdL6rTxnJKCTnGCQwPIVE+w
# S/0OUrs33NMq7crx1FF+DRC6F9ivFQRZjNkrfeBxmb1mxLUCjXOa3GCNvKjvAv4r
# DltiHn2mQejAiizpw7q+YTsvJfqODz6gapoAjbxkboVoeMjlWIj/BZtPR2m5Z5Is
# uSqMllAbm3XDeoqY7dDmMD840lz4gTc72u4tXbfQgYxAO042l2+TAB/qNOaaNCPu
# sOlszW3qNO4XLBohYuQeWi/qclCpedMCxY5leRpLiT/NuxiQlSsdSAAIrq1JXlMO
# bQuTscc6S6iDFlEH6ggheg2jbudvytt95qhvfUQ11+S0dm/ML1UdaNol0I1elX2g
# Gl2u+VRLVIPz+RX11Y3oSScch5lDofA/X7EIEWZJPZ9SrcfT3FtSZm4FDhjrI8Y0
# 9OfN2TzQljxpJxtEL95t7cB6Nc4QhR2AMrG9qC9ikk4Msk/lMrI4fftlDh3zZP12
# 6lQVeyST2ffRpeiqCLmF7xq+jAsA4iUq2+VoRV43wFzP+Z4X9stdNZvbv+sJSxL8
# rFLYapdmt2KaClGHwlNhbIlhXVHp3yj53yQXfsEMMd2MOBOgIH5V0HjSy1rHlm7E
# nGk25Vhe4/bluzGCAf4wggH6AgEBMF0wRjESMBAGCgmSJomT8ixkARkWAnFhMRYw
# FAYKCZImiZPyLGQBGRYGc2VjZWR1MRgwFgYDVQQDEw9FRFUgSVNTVUlORyBDQTEC
# EykAAeCKcLLcvk4azycAAgAB4IowCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFNM1TLmnfsaybdV
# XnXc/195/R4zMA0GCSqGSIb3DQEBAQUABIIBAJ5m+RdaoOPA1HrBJoj09tOXcFkm
# P0gT29YEnvQQM9U/UKAjMCKnkjkJjeCxh/df39PrIR0aEr0MbT7HYQ+4cfNHuaF7
# lVWRmldzWB3O2AKptyk6eWzuq4YQ/d/izd37p6wNhVUnFehmUiZIT+6rjNwd5obp
# nykBV+4pXVtA6LTQkf0grxJZv4vVGTqhDvCBc7C3H3xpnsefvZkRsaWMWw93JZ7A
# 7if0RLJUFBvx1ezsjF3wUR4IkCR7ajCgHghsXQVNjlnWcI2C8p5zxOahPR4jJBSt
# PW8nDtyyMHfri1LWt6YtwWE6yFUEpkHabe5tj298KuNI76LYIU0OPj3EOwM=
# SIG # End signature block
