param(
  [int]$Port = 8000,
  [string]$Root = ""
)

if ([string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Get-Location).Path
}

Write-Host "Starting simple static server on http://localhost:$Port/ serving '$Root'" -ForegroundColor Green

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
$listener.Start()

function Get-ContentType([string]$path) {
  switch ([System.IO.Path]::GetExtension($path).ToLower()) {
    '.html' { 'text/html; charset=utf-8' }
    '.css'  { 'text/css; charset=utf-8' }
    '.js'   { 'application/javascript; charset=utf-8' }
    '.png'  { 'image/png' }
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.gif'  { 'image/gif' }
    '.svg'  { 'image/svg+xml' }
    default { 'application/octet-stream' }
  }
}

try {
  while ($true) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $relPath = $request.Url.AbsolutePath.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($relPath)) { $relPath = 'index.html' }
    $filePath = Join-Path $Root $relPath

    if (Test-Path $filePath -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($filePath)
      $response.ContentType = Get-ContentType $filePath
      $response.StatusCode = 200
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $response.StatusCode = 404
      $errorHtml = "<html><body><h1>404 Not Found</h1><p>$relPath</p></body></html>"
      $errorBytes = [System.Text.Encoding]::UTF8.GetBytes($errorHtml)
      $response.ContentType = 'text/html; charset=utf-8'
      $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
    }
    $response.OutputStream.Close()
  }
}
finally {
  $listener.Stop()
  $listener.Close()
}