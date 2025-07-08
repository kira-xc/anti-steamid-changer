#include <amxmodx>
#include <sqlx>
#include <regex>


#define IP_X "34.155.24.113:27013"
#define SERVER_PREFIX "lastmaharja" //It is necessary to change it so that there is no conflict or injustice due to other servers.
#define DISCORD "discord.gg/j2sBZmgjGM"

new const LOG_FILE[] = "addons/amxmodx/logs/anti_bota.log";
//id = prefix#timestamp#userid
new Trie:g_tSteamProtection;
new Trie:g_tSteamProtection2;
// MySQL Table
new const g_szTable[] = 
" \
	CREATE TABLE IF NOT EXISTS anti_bot_users \
	( \
		id varchar(70) PRIMARY KEY, \
		steamid varchar(35) NOT NULL  \
	); \
"
// Variables
new Handle:g_hTuple


// Cvars
new g_pCvarDBInfo[4]

// Database
enum
{
	Host = 0,
	User,
	Pass,
	DB
}



public plugin_init() {
    register_plugin("anti bota", "0.1-beta", "CT Spawn")
    g_pCvarDBInfo[Host] = register_cvar("anti_bota_host", "127.0.0.1")
    g_pCvarDBInfo[User] = register_cvar("anti_bota_user", "root")
    g_pCvarDBInfo[Pass] = register_cvar("anti_bota_pass", "1234")
    g_pCvarDBInfo[DB]   = register_cvar("anti_bota_dbname", "anti_fakeplayers_ct_spawn")
        

    set_task(0.1, "Delay_MySQL_Init")
}



public check_input_format(const input[]) {
    new Regex:re
    new ret

    new pattern[] = "^^([a-zA-Z0-9]+)#([0-9]+)#([0-9]+)$"

    re = regex_match(input, pattern, ret)

    if (re!=REGEX_MATCH_FAIL&& re!= REGEX_PATTERN_FAIL && re!=REGEX_NO_MATCH) {
        regex_free(re)
        return 1
    } else {
        return 0
    }
}



public Delay_MySQL_Init()
{
	MySQL_Init()
}

public MySQL_Init()
{

    new szHost[64], szUser[32], szPass[32], szDB[128]

    get_pcvar_string(g_pCvarDBInfo[Host], szHost, charsmax(szHost))
    get_pcvar_string(g_pCvarDBInfo[User], szUser, charsmax(szUser))
    get_pcvar_string(g_pCvarDBInfo[Pass], szPass, charsmax(szPass))
    get_pcvar_string(g_pCvarDBInfo[DB], szDB, charsmax(szDB))

    g_hTuple = SQL_MakeDbTuple(szHost, szUser, szPass, szDB)

    // Let's ensure that the g_hTuple will be valid, we will access the database to make sure
    new iErrorCode, szError[512], Handle:hSQLConnection

    hSQLConnection = SQL_Connect(g_hTuple, iErrorCode, szError, charsmax(szError))

    if(hSQLConnection != Empty_Handle)
    {
        log_amx("[Anti Bota] Successfully connected to host: %s (ALL IS OK).", szHost)
        SQL_FreeHandle(hSQLConnection)
    }
    else
    {
        log_amx("[Anti Bota] Failed to connect to MySQL database: %s", szError)
        // stop the plugin with an error message
        set_fail_state(szError)
    }

    // Create our table
    SQL_ThreadQuery(g_hTuple, "QueryCreateTable", g_szTable)
    g_tSteamProtection = TrieCreate();
    g_tSteamProtection2 = TrieCreate();
}

public QueryCreateTable(iFailState, Handle:hQuery, szError[], iError, szData[], iSize, Float:flQueueTime) 
{
    if (iFailState != TQUERY_SUCCESS) {
        SQL_FreeHandle(hQuery);
        return;
    }
}


public plugin_end()
{
    if (g_hTuple != Empty_Handle)
    {
        SQL_FreeHandle(g_hTuple)
    }
    TrieDestroy(g_tSteamProtection); 
    TrieDestroy(g_tSteamProtection2); 
	
}

public to_admins(text[]){
    new players[32],num;
    get_players(players,num,"ch")
    for (new i=0;i<num;i++){
        if(get_user_flags(players[i]) & ( ADMIN_BAN | ADMIN_KICK )){
            client_print_color(players[i],print_team_red,"^4[ANTI BOTA] Player ^1[^3%s^1] ^4has kicked for using hacks.",text)
        }
    }
}


public kicker(args[]){
    server_cmd(args)
}

public LoadCoins(id,const idd[])
{

    new szQuery[255], szData[1]
    formatex(szQuery, charsmax(szQuery), "SELECT steamid FROM anti_bot_users WHERE ( `id` = '%s' );", idd)

    szData[0]=id
    SQL_ThreadQuery(g_hTuple, "QuerySelectData", szQuery, szData, 1)
	
}

public QuerySelectData(iFailState, Handle:hQuery, szError[], iError, szData[]) 
{
    if (iFailState != TQUERY_SUCCESS) {
        SQL_FreeHandle(hQuery);
        return;
    }
    new id = szData[0]
    if(!is_user_connecting(id)&&!is_user_connected(id)){
        SQL_FreeHandle(hQuery);
        return;        
    }

    new szAuthID[35],szAuthID2[35]
    get_user_authid(id, szAuthID, charsmax(szAuthID))
    // No results for this query means that player not saved before
    new text_kick[128]
    if(!SQL_NumResults(hQuery))
    {
        SQL_FreeHandle(hQuery);
        query_client_cvar(id, "team", "cvar_create")
        return
    }
    SQL_ReadResult(hQuery,0,szAuthID2, charsmax(szAuthID2))
    if(!equali(szAuthID,szAuthID2)){
        formatex(text_kick,127,"kick #%d ^"why are you a gay ? reconnect here : %s or visit : %s^"",get_user_userid(id),IP_X,DISCORD)
        set_task(2.0,"kicker",_,text_kick,128)
    }
    SQL_FreeHandle(hQuery);

}

public QueryInsertData(iFailState, Handle:hQuery, szError[], iError, szData[], iSize, Float:flQueueTime)
{
    if (iFailState != TQUERY_SUCCESS) {
        SQL_FreeHandle(hQuery);
        return;
    }
    SQL_FreeHandle(hQuery);
}

public SaveCoins(id,const idd[])
{
    new szQuery[255]
    new szAuthID[35], szData[1]
    get_user_authid(id, szAuthID, charsmax(szAuthID))
    formatex(szQuery, charsmax(szQuery), "INSERT INTO `anti_bot_users` (`id`, `steamid`) VALUES ('%s', '%s');",idd , szAuthID)
    szData[0]=id
    SQL_ThreadQuery(g_hTuple, "QueryUpdateData", szQuery,szData,1)	
}

public QueryUpdateData(iFailState, Handle:hQuery, szError[], iError, szData[], iSize, Float:flQueueTime) 
{
    if (iFailState != TQUERY_SUCCESS) {
        SQL_FreeHandle(hQuery);
        return;
    }
    new id = szData[0]
    if(!is_user_connecting(id)&&!is_user_connected(id)){
        SQL_FreeHandle(hQuery);
        return;        
    }
    detect_bota_repeater(id)
    new text_kick[128]
    formatex(text_kick,127,"kick #%d ^"robot checking, please reconnect here : %s^"",get_user_userid(id),IP_X)
    set_task(2.0,"kicker",_,text_kick,128)
    SQL_FreeHandle(hQuery);
}



public client_connect(id){
	if (is_user_bot(id) || is_user_hltv(id))
		return
	
	// Just 1 second delay
	set_task(1.0, "DelayLoad", id)
}

public DelayLoad(id)
{
    query_client_cvar(id, "team", "cvar_result_pitch")
}

public cvar_result_pitch(id, const cvar[], const value[]) 
{
    if(check_input_format(value)){
        LoadCoins(id,value)
    }
    else{
        new idd[128]
        formatex(idd,127,"%s#%d#%d",SERVER_PREFIX,get_systime(),get_user_userid(id))
        client_cmd(id,"team ^"%s^"",idd)
        SaveCoins(id, idd)
    }
} 


public cvar_create(id, const cvar[], const value[]) 
{
    if(!is_user_connecting(id)&&!is_user_connected(id)){
        return;        
    }
    if(same_nigga_detector(value)==1){
        new ip_client[32]
        get_user_ip(id,ip_client,31,1)
        server_cmd("amx_banip ^"#%d^" ^"60^" ^"why are you a gay ? visit : %s^"",get_user_userid(id) ,DISCORD)
        to_admins(ip_client)
        log_to_file(LOG_FILE, "%s was banned for 1h, detected bot or hacker ", ip_client);
        return;
    }
    if(check_input_format(value)){
        SaveCoins(id, value)
    }
    else{
        new idd[128]
        formatex(idd,127,"%s#%d#%d",SERVER_PREFIX,get_systime(),get_user_userid(id))
        client_cmd(id,"team ^"%s^"",idd)
        SaveCoins(id, idd)
    }
}

public same_nigga_detector(const input[]){
    new part1[40], part2[40], part3[40]
    new temp[128]
    copy(temp, charsmax(temp), input)
    if (test_explode_string(temp, "#", part1, charsmax(part1), part2, charsmax(part2), part3, charsmax(part3)) != 3) {
        return 0
    }
    trim(part2)
    remove_quotes(part2)
    trim(part2)
    if(is_str_num(part2)){
        if(str_to_num(part2)>get_systime()){
            return 1
        }
    }
    return 0;

}

stock test_explode_string(const str[], const delimiter[], part1[], len1, part2[], len2, part3[], len3) {
    new temp[128]
    copy(temp, charsmax(temp), str)

    new pos = containi(temp, delimiter)
    if (pos == -1) return 0
    copy(part1, len1, temp)
    part1[pos] = 0

    copy(temp, charsmax(temp), str[pos + 1])
    pos = containi(temp, delimiter)
    if (pos == -1) return 0
    copy(part2, len2, temp)
    part2[pos] = 0

    copy(part3, len3, temp[pos + 1])
    return 3
}


public detect_bota_repeater(id){
    if(!is_user_connecting(id)&&!is_user_connected(id)){
        return;        
    }
    new szIP[32];
    get_user_ip(id, szIP, charsmax(szIP), 1);       // 1 = remove port

    new repeat_login[10];
    if (TrieKeyExists(g_tSteamProtection, szIP))
    {
        TrieGetString(g_tSteamProtection, szIP, repeat_login, charsmax(repeat_login))
        if (str_to_num(repeat_login)>=2)
        {
            server_cmd("amx_banip ^"#%d^" ^"60^" ^"[Fake Player] why are you a gay ? visit : %s^"", get_user_userid(id), DISCORD)
            log_to_file(LOG_FILE, "%s was banned for 1h, detected steam id change ", szIP);
            to_admins(szIP)
            TrieDeleteKey(g_tSteamProtection,szIP)
            return ;
        }
        else{
            num_to_str(str_to_num(repeat_login)+1,repeat_login,9)
            TrieSetString(g_tSteamProtection, szIP, repeat_login);
        }
    }
    else
    {   num_to_str(1,repeat_login,9)
        TrieSetString(g_tSteamProtection, szIP, repeat_login);
    }
    detect_bota_repeater_steam(id)
    return ;
}

public detect_bota_repeater_steam(id){
    if(!is_user_connecting(id)&&!is_user_connected(id)){
        return;        
    }
    new szAuthID[35];
    get_user_authid(id,szAuthID,34)

    new repeat_login[10];
    if (TrieKeyExists(g_tSteamProtection2, szAuthID))
    {
        TrieGetString(g_tSteamProtection2, szAuthID, repeat_login, charsmax(repeat_login))
        if (str_to_num(repeat_login)>=2)
        {
            server_cmd("amx_ban ^"%s^" ^"60^" ^"[Fake Player] why are you a gay ? visit : %s^"", szAuthID, DISCORD)
            log_to_file(LOG_FILE, "%s was banned for 1h, detected bot or hacker ", szAuthID);
            to_admins(szAuthID)
            TrieDeleteKey(g_tSteamProtection2,szAuthID)
            return ;
        }
        else{
            num_to_str(str_to_num(repeat_login)+1,repeat_login,9)
            TrieSetString(g_tSteamProtection2, szAuthID, repeat_login);
        }
    }
    else
    {   num_to_str(1,repeat_login,9)
        TrieSetString(g_tSteamProtection2, szAuthID, repeat_login);
    }
    return ;
}

