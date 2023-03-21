
#Get the bookmarks file
$BookmarksURL = "$env:userprofile\appdata\local\google\chrome\user data\default\Bookmarks"



#import content
$bookmarks = Get-Content $BookmarksURL -raw | ConvertFrom-Json
#Entry for adding a bookmark, you'll want to update name and URL
$data = "[{'meta_info':{'power_bookmark_meta':''},'name':'Github','type':'url','url':'Github.io'}]" | ConvertFrom-Json

$bookmarks.roots.bookmark_bar.children = ($bookmarks.roots.bookmark_bar.children + $data)  
$bookmarks | ConvertTo-Json -Depth 4 | Out-File "$env:userprofile\appdata\local\google\chrome\user data\default\bookmarks" -Encoding UTF8 -Force  
