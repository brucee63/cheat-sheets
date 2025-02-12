param (
    [string]$filePath
)

# Add necessary assembly reference
Add-Type -AssemblyName System.Drawing

# Define the target URL
$URL = "http://localhost:5000/ocr"

if ($filePath) {
    # Check if the file path is relative
    if ($filePath -notmatch "^[A-Z]:\\|^\\\\|^/") {
        $currentFolderPath = Join-Path (Get-Location) $filePath

        if (-Not (Test-Path $currentFolderPath)) {
            Write-Host "File not found: $filePath"
            exit
        }
        $filePath = $currentFolderPath
    }

    # Load image from file path
    $image = [System.Drawing.Image]::FromFile($filePath)
} else {
    # Load clipboard image
    Add-Type -AssemblyName System.Windows.Forms
    $image = [System.Windows.Forms.Clipboard]::GetImage()

    if ($image -eq $null) {
        Write-Host "No image found in clipboard."
        exit
    }
}

# Convert image to a MemoryStream (PNG format)
$memoryStream = New-Object System.IO.MemoryStream
$image.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)
$byteArray = $memoryStream.ToArray()

# Convert byte array to Base64 string
$base64String = [Convert]::ToBase64String($byteArray)

# Create JSON payload
$payload = @{
    image = $base64String
    filename = "image.png"
    mimetype = "image/png"
} | ConvertTo-Json -Depth 2

# Send as HTTP POST request
$headers = @{"Content-Type" = "application/json"}
$response = Invoke-RestMethod -Uri $URL -Method Post -Body $payload -Headers $headers

# Print response
Write-Output "$($response.text)"