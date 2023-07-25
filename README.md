# Instance and Currency Tracker
Tracks instance currency information across all characters on your account.
To view, load the Looking For Group Frame (i by default).

The addon uses IDs so should work in any language however labels are not localized.

Feel free to comment for additional features or suggestions.

## Information Collected
+ Instance lockout and encounter information  
+ Currency available for an instance  
+ Total currency in an instance  
+ Currency collected and available for each character  
+ Daily quest completed and prerequisites met  

## Options
+ Show Realm Name  
_Enables `[Realm] Player` versus `Player` for name fields._
+ Verbose Currency  
_Multi-line currency versus single line currency information_
+ Simple Currency Tooltip  
_Shows only current and available currency per player, otherwise includes instances and quests collected._
+ All Quests  
_Shows all quests including those you have not met the prerequisite for._
+ Currency  
_Select the currency you wish to view defaults to all currencies._
+ Instances  
_Select the instances you wish to view, defaults to all WOTLK instances._

## Color Codes
**Purple** Locked Instances and Completed Dailies  
**White** Available Instances and Dailies  
**Red** Dailies where you don't meet the prerequisites  

## Wiping Data
\# current player  
`/ict wipe`  
\# specific player  
`/ict wipe player [{REALM_NAME}] {PLAYER_NAME}`  
\# all players on realm  
`/ict wipe realm {REALM_NAME}`  
\# all players  
`/ict wipe all`  
