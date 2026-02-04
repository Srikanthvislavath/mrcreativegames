# convert_webm_to_mp4.ps1
# Batch-convert all .webm files in the projects/ folder to H.264 MP4 (suitable for iOS/Safari playback)
# Usage: Open PowerShell in the repo root and run: `.	emplates\convert_webm_to_mp4.ps1` or dot-run the script

param(
  [string]$SourceDir = "projects",
  [int]$CRF = 22,            # quality: lower = better quality, larger file. 18-23 recommended.
  [string]$Preset = "medium" # ffmpeg preset: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
)

function Check-FFmpeg {
  $ff = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if(-not $ff){
    Write-Error "ffmpeg not found in PATH. Install ffmpeg (choco install ffmpeg) or add it to PATH and re-run."
    exit 1
  }
}

Check-FFmpeg

$srcPath = Join-Path -Path (Get-Location) -ChildPath $SourceDir
if(-not (Test-Path $srcPath)){
  Write-Error "Source folder not found: $srcPath"
  exit 1
}

Get-ChildItem -Path $srcPath -Filter *.webm -File | ForEach-Object {
  $in = $_.FullName
  $out = [System.IO.Path]::ChangeExtension($in, '.mp4')

  if(Test-Path $out){
    Write-Host "Skipping existing: $([System.IO.Path]::GetFileName($out))"
    return
  }

  Write-Host "Converting: $($_.Name) → $([System.IO.Path]::GetFileName($out))"

  & ffmpeg -hide_banner -y -i "$in" -c:v libx264 -preset $Preset -crf $CRF -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 128k "$out"

  if($LASTEXITCODE -ne 0){
    Write-Error "ffmpeg failed for $($_.Name) (exit code $LASTEXITCODE)"
  } else {
    $inSize = [math]::Round((Get-Item $in).Length / 1MB, 2)
    $outSize = [math]::Round((Get-Item $out).Length / 1MB, 2)
    Write-Host "Done: $($_.Name) — Input: ${inSize}MB → Output: ${outSize}MB (CRF=$CRF, preset=$Preset)"
  }
}

Write-Host "All done. Review generated .mp4 files in $srcPath"
