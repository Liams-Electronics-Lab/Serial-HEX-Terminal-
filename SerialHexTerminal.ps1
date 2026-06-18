Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- GUI Window Creation ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Serial Hex Terminal"
# Height increased from 480 to 500 to fit the footer
$form.Size = New-Object System.Drawing.Size(450, 500) 
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Font Styling
$font = New-Object System.Drawing.Font("Segoe UI", 10)
$fontMono = New-Object System.Drawing.Font("Consolas", 10)

# --- COM Port Selection UI ---
$lblPort = New-Object System.Windows.Forms.Label
$lblPort.Text = "Port:"
$lblPort.Location = New-Object System.Drawing.Point(20, 22)
$lblPort.Size = New-Object System.Drawing.Size(40, 20)
$lblPort.Font = $font
$form.Controls.Add($lblPort)

$txtPort = New-Object System.Windows.Forms.TextBox
$txtPort.Text = "COM8"
$txtPort.Location = New-Object System.Drawing.Point(60, 20)
$txtPort.Size = New-Object System.Drawing.Size(70, 20)
$txtPort.Font = $font
$form.Controls.Add($txtPort)

$lblBaud = New-Object System.Windows.Forms.Label
$lblBaud.Text = "Baud:"
$lblBaud.Location = New-Object System.Drawing.Point(150, 22)
$lblBaud.Size = New-Object System.Drawing.Size(45, 20)
$lblBaud.Font = $font
$form.Controls.Add($lblBaud)

$txtBaud = New-Object System.Windows.Forms.TextBox
$txtBaud.Text = "115200"
$txtBaud.Location = New-Object System.Drawing.Point(195, 20)
$txtBaud.Size = New-Object System.Drawing.Size(80, 20)
$txtBaud.Font = $font
$form.Controls.Add($txtBaud)

# --- Hex Input UI ---
$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Text = "Hex Bytes to Send (spaces optional, e.g., AA 09 00 09):"
$lblInput.Location = New-Object System.Drawing.Point(20, 60)
$lblInput.Size = New-Object System.Drawing.Size(400, 20)
$lblInput.Font = $font
$form.Controls.Add($lblInput)

$txtHexInput = New-Object System.Windows.Forms.TextBox
$txtHexInput.Text = "AA 09 00 09"
$txtHexInput.Location = New-Object System.Drawing.Point(20, 85)
$txtHexInput.Size = New-Object System.Drawing.Size(390, 25)
$txtHexInput.Font = $fontMono
$form.Controls.Add($txtHexInput)

# --- Send Button ---
$btnSend = New-Object System.Windows.Forms.Button
$btnSend.Text = "Send Bytes"
$btnSend.Location = New-Object System.Drawing.Point(20, 120)
$btnSend.Size = New-Object System.Drawing.Size(390, 35)
$btnSend.Font = $font
$btnSend.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($btnSend)

# --- Response Window UI ---
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "Terminal Log & Responses:"
$lblOutput.Location = New-Object System.Drawing.Point(20, 170)
$lblOutput.Size = New-Object System.Drawing.Size(200, 20)
$lblOutput.Font = $font
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Multiline = $true
$txtOutput.ReadOnly = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.Location = New-Object System.Drawing.Point(20, 195)
$txtOutput.Size = New-Object System.Drawing.Size(390, 220)
$txtOutput.Font = $fontMono
$txtOutput.BackColor = [System.Drawing.Color]::Black
$txtOutput.ForeColor = [System.Drawing.Color]::LimeGreen
$form.Controls.Add($txtOutput)

# --- Footer UI ---
$lblCredit = New-Object System.Windows.Forms.Label
$lblCredit.Text = "Made by Liam's Electronics Lab"
$lblCredit.Location = New-Object System.Drawing.Point(20, 427)
$lblCredit.AutoSize = $true
$lblCredit.Font = $font
$form.Controls.Add($lblCredit)

$linkGit = New-Object System.Windows.Forms.LinkLabel
$linkGit.Text = "GitHub"
$linkGit.Location = New-Object System.Drawing.Point(235, 427)
$linkGit.AutoSize = $true
$linkGit.Font = $font
$linkGit.Add_LinkClicked({ 
    [System.Diagnostics.Process]::Start("https://github.com/Liams-Electronics-Lab") 
})
$form.Controls.Add($linkGit)

$linkYT = New-Object System.Windows.Forms.LinkLabel
$linkYT.Text = "YouTube"
$linkYT.Location = New-Object System.Drawing.Point(295, 427)
$linkYT.AutoSize = $true
$linkYT.Font = $font
$linkYT.Add_LinkClicked({ 
    [System.Diagnostics.Process]::Start("https://www.youtube.com/@Slot1Gamer/videos") 
})
$form.Controls.Add($linkYT)

# --- Serial Logic Function ---
function Send-SerialData {
    # Remove everything except hexadecimal numbers
    $cleanHex = $txtHexInput.Text -replace '[^a-fA-F0-9]', ''
    
    if ($cleanHex.Length -eq 0 -or $cleanHex.Length % 2 -ne 0) {
        $txtOutput.AppendText("[(Error) Invalid Hex String length]`r`n")
        return
    }

    # Convert text string to raw byte array
    $bytes = New-Object byte[] ($cleanHex.Length / 2)
    for ($i = 0; $i -lt $cleanHex.Length; $i += 2) {
        $bytes[$i/2] = [Convert]::ToByte($cleanHex.Substring($i, 2), 16)
    }

    # Format output preview
    $displaySent = ($bytes | ForEach-Object { "{0:X2}" -f $_ }) -join " "
    $txtOutput.AppendText("TX -> $displaySent`r`n")

    $serialPort = $null
    try {
        # Fixed parser constraint by encapsulating type conversion
        $portName = $txtPort.Text.Trim()
        $baudRate = [int]$txtBaud.Text.Trim()
        
        $serialPort = New-Object System.IO.Ports.SerialPort $portName, $baudRate, None, 8, One
        $serialPort.ReadTimeout = 1000
        $serialPort.Open()

        # Send payload
        $serialPort.Write($bytes, 0, $bytes.Length)

        # Pause to let the hardware assemble a response 
        Start-Sleep -Milliseconds 400

        # Look for return strings
        if ($serialPort.BytesToRead -gt 0) {
            $buffer = New-Object byte[] $serialPort.BytesToRead
            [void]$serialPort.Read($buffer, 0, $buffer.Length)
            
            $hexResponse = ($buffer | ForEach-Object { "{0:X2}" -f $_ }) -join " "
            $txtOutput.AppendText("RX <- $hexResponse`r`n`r`n")
        } else {
            $txtOutput.AppendText("RX <- [No response received]`r`n`r`n")
        }
    }
    catch {
        $txtOutput.AppendText("[(Error) " + $_.Exception.Message + "]`r`n`r`n")
    }
    finally {
        if ($serialPort -ne $null -and $serialPort.IsOpen) {
            $serialPort.Close()
        }
    }
}

# Attach Button Actions
$btnSend.Add_Click({ Send-SerialData })

# Run app
$form.ShowDialog()