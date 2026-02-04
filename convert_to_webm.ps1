# WebM Conversion Script for Video Portfolio
# This script converts MP4 videos to WebM format for optimal web performance

$projectPath = "c:\Users\ANUSHA\OneDrive\Desktop\MR_CREATIVE_GAMES\MRCREATIVEGAMES\projects"
$mp4Files = Get-ChildItem -Path $projectPath -Filter "*.mp4"

if ($mp4Files.Count -eq 0) {
    Write-Host "No MP4 files found. All videos are already in WebM format!" -ForegroundColor Green
    exit
}

Write-Host "Found $($mp4Files.Count) MP4 file(s) to convert to WebM" -ForegroundColor Cyan
Write-Host ""

foreach ($file in $mp4Files) {
    $inputFile = $file.FullName
    $outputFile = $inputFile -replace '\.mp4$', '.webm'
    $fileName = $file.Name
    $outputName = Split-Path -Leaf $outputFile
    
    Write-Host "Converting: $fileName → $outputName" -ForegroundColor Yellow
    
    # FFmpeg command with optimized WebM settings for animations
    # Using VP9 codec for best quality/compression ratio
    # Lower bitrate for animations = smaller file size
    $ffmpegArgs = @(
        '-i', $inputFile,                    # Input file
        '-c:v', 'vp9',                       # VP9 video codec (superior compression)
        '-b:v', '1500k',                     # 1500kbps bitrate (good for animations)
        '-c:a', 'libopus',                   # Opus audio codec
        '-b:a', '128k',                      # 128kbps audio bitrate
        '-tile-columns', '2',                # Parallel encoding
        '-tile-rows', '2',
        '-frame-parallel', '1',              # Enable frame parallelism
        '-cpu-used', '4',                    # Quality/speed balance (0-8, higher=faster)
        '-y',                                # Overwrite output file
        $outputFile
    )
    
    try {
        ffmpeg @ffmpegArgs 2>&1 | Out-Null
        
        if (Test-Path $outputFile) {
            $inputSize = (Get-Item $inputFile).Length / 1MB
            $outputSize = (Get-Item $outputFile).Length / 1MB
            $reduction = [math]::Round(((1 - ($outputSize / $inputSize)) * 100), 1)
            
            Write-Host "Success! $outputName created" -ForegroundColor Green
            $inputMB = [math]::Round($inputSize, 2)
            $outputMB = [math]::Round($outputSize, 2)
            Write-Host "  Input: $inputMB MB to Output: $outputMB MB (Reduction: $reduction%)" -ForegroundColor Green
        } else {
            Write-Host "Error: Output file was not created" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error converting $fileName : $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "Conversion complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Get-ChildItem -Path $projectPath -Filter "*.webm" | Measure-Object | Select-Object -ExpandProperty Count | ForEach-Object {
    Write-Host "Total WebM files: $_" -ForegroundColor Green
}
