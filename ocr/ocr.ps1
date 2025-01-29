# Define the target URL
$URL = "http://localhost:5000/ocr"

# Load clipboard image
Add-Type -AssemblyName System.Windows.Forms
$clipboardImage = [System.Windows.Forms.Clipboard]::GetImage()

if ($clipboardImage -eq $null) {
    Write-Host "No image found in clipboard."
    exit
}

# Convert image to a MemoryStream (PNG format)
$memoryStream = New-Object System.IO.MemoryStream
$clipboardImage.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)
$byteArray = $memoryStream.ToArray()

# Convert byte array to Base64 string
$base64String = [Convert]::ToBase64String($byteArray)

# Create JSON payload
$payload = @{
    image = $base64String
    filename = "clipboard.png"
    mimetype = "image/png"
} | ConvertTo-Json -Depth 2

# Send as HTTP POST request
$headers = @{"Content-Type" = "application/json"}
$response = Invoke-RestMethod -Uri $URL -Method Post -Body $payload -Headers $headers

# Print response
Write-Output "$($response.text)"