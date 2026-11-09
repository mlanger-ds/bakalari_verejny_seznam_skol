$url = "https://sluzby.bakalari.cz/api/v1/municipality"
$doc = New-Object System.Xml.XmlDocument

$abc = @("a","á","b","c","č","d","ď","e","é","ě","f","g","h","ch","i","í","j","k","l","m","n","ň","o","ó","p","q","r","ř","s","š","t","ť","u","ú","ů","v","w","x","y","ý","z","ž")

$ba = New-Object -TypeName PSObject
Add-Member -InputObject $ba -MemberType NoteProperty -Name id -Value "id"
Add-Member -InputObject $ba -MemberType NoteProperty -Name name -Value "name"
Add-Member -InputObject $ba -MemberType NoteProperty -Name schoolurl -Value "schoolurl"
Add-Member -InputObject $ba -MemberType NoteProperty -Name IP -Value "IP"
Add-Member -InputObject $ba -MemberType NoteProperty -Name port -Value "port"

For ($i=0; $i -lt $abc.Length; $i++) 
   {
    $ErrorActionPreference = "SilentlyContinue"
    $doc.Load($url+'/'+$abc[$i])
    $ErrorActionPreference = "Continue"
    if ($?)
     {
     #$doc.municipality.schools.schoolInfo | Export-Csv -Path 'Bak-weby.csv' -Encoding Default -NoTypeInformation -Append 

     foreach ($si in $doc.municipality.schools.schoolInfo) 
      {
        if ($si.schoolUrl.Contains('//'))
        {
         $dom = $si.schoolUrl.Substring($si.schoolUrl.IndexOfAny('//')+2)
        }
        else
        {
         $dom = $si.schoolUrl
        }
        if ($dom.Contains(':'))
        {
         $port = $dom.Substring($dom.IndexOfAny(':')+1)
         if ($port.Contains('/'))
          {
           $port = $port.Substring(0,$port.IndexOfAny('/'))
          }
         $dom = $dom.Substring(0,$dom.IndexOfAny(':'))
        }
        else
        {
         $port = ''
        }
        if ($dom.Contains('/'))
        {
         $dom = $dom.Substring(0,$dom.IndexOfAny('/'))
        }
        $ErrorActionPreference = "SilentlyContinue"
        $dns = Resolve-DnsName -Name $dom -Type A
        $ErrorActionPreference = "Continue"
         if ($?)
          {
           $IP = $dns.IPAddress
          }
          else
          {
           $IP = ''
          }
          $ba.id        = $si.id
          $ba.name      = $si.name
          $ba.schoolurl = $si.schoolurl
          $ba.IP        = $IP
          $ba.port      = $port
          Write-Host $dom $IP $port
          $ba | Export-Csv -Path 'Bak-weby.csv' -Encoding Default -NoTypeInformation -Append
        }
      }
     }

 

