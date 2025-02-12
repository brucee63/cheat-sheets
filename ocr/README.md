# ocr - tesseract

```bash
docker build -t tesseract-ocr-service .
docker run -d -p 5000:5000 --name tesseract_service tesseract-ocr-service
curl -X POST -F file=@test.jpg http://localhost:5000/ocr | jq -r '.text' >| test.txt
```

## PowerShell support
To get the images in your clipboard and ocr them, add this to your $PROFILE
```powershell
function ocr {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $args
    )
    & "C:\scripts\ocr.ps1" $args
}
```
