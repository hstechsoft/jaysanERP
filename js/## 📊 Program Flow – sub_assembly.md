graph TD

Start[Page Load]
Start --> Disable[Disable sub_ass_part_div]
Start --> LoadMenu[Load menu and sessionStorage]
Start --> SetUser[Set username from localStorage]
Start --> InitLogin[Call check_login]
InitLogin --> GetRecent[get_bom_recent]
GetRecent --> GetCount[get_bom_count]

UserOut[Select output part]
UserOut --> AutoOut[Autocomplete parts wel]
AutoOut --> BomList[get_bom_list]
AutoOut --> BomComp[get_bom_list_comp]

UserIn[Select input part]
UserIn --> SaveIn[Save part id]

Proc[Enter process name]
Proc --> AutoProc[Autocomplete process]

AddPart[Click Add Part]
AddPart --> AppendPart[Add input item to list]

AddProc[Click Add Process]
AddProc --> AppendProc[Add process item]
AppendProc --> GetMachine[get_machine]

Submit[Click Submit]
Submit --> Validate1[Validate table]
Validate1 --> BuildData[Build allWeldingData]
BuildData --> Insert[POST insert_wel_process1.php]

Update[Click Update]
Update --> Validate2[Validate and build delete list]
Validate2 --> UpdatePHP[POST update_wel_process1.php]

DeleteRow[Click Delete Row]
DeleteRow --> ConfirmDel[Confirm and remove row]

BOMRecent[Select BOM recent]
BOMRecent --> BOMOutput[get_bom_output]
BOMOutput --> SelAuto[selectAutocompleteByPartId]
SelAuto --> BomMain[get_bom]
BomMain --> ProcessDetails[get_bom_process_details]

SubAss[Select sub assembly part]
SubAss --> AutoSub[Autocomplete sub part]
AutoSub --> GetOutput[get_bom_output by id]
GetOutput --> AddSub[GET insert_new_sub_part.php]

DeleteAll[Click delete all process]
DeleteAll --> DelPHP[POST del_wel_process1.php]
