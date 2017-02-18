$thisDir = $PSScriptRoot
$srcDir = "/Users/jberman/Develop/express-xp/"
$tgtDir = "/Build/XP/jeff2"
$system = 'S814JAZZ'
$user = 'JBERMAN'

echo "Source directory: $srcDir"
echo "Target directory: ${system}:$tgtDir"

C:\Users\jberman\Develop\DeltaCopyRaw\rsync.exe -avzh  --exclude .git --exclude removed $srcDir $user@${system}::testing
