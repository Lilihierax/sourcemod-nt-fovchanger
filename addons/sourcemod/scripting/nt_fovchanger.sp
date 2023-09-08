#include <sourcemod>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

#define NEO_MAX_PLAYERS 32

#define PLUGIN_VERSION  "0.2.0"

// Flip the DEBUG_NOPATCH to test this stuff without having the binary patch.
#define DEBUG_NOPATCH false
#if(DEBUG_NOPATCH)
#warning Building with DEBUG_NOPATCH; you probably don't wanna do this for release.
#endif

#define ENTPROP_FOV "m_iDefaultFOV"

// DEF_MAX_ACCEPTABLE_FOV must be > 0.
// DEF_MIN_ACCEPTABLE_FOV must be >= DEF_MAX_ACCEPTABLE_FOV.
#define DEF_MIN_ACCEPTABLE_FOV "75"
#define DEF_MAX_ACCEPTABLE_FOV "100"

bool g_bIsUsingPatchedFov[NEO_MAX_PLAYERS + 1];

char g_sPluginTag[] = "[nt_fovchanger]";
char g_sDownloadUrl[] = "https://github.com/Lilihierax/sourcemod-nt-fovchanger/";

ConVar g_cMinFov = null, g_cMaxFov = null;

Cookie g_ccFov = null;

public Plugin myinfo =
{
    name              = "Neotokyo FoV Changer",
    version           = PLUGIN_VERSION,
    description       = "SM plugin for NEOTOKYO° enabling \
players to set their preferred field of view. Clients are required to \
have their game binaries (client.dll) patched.",
    author            = "Rain, Lilihierax",
    url               = g_sDownloadUrl
};

public void OnPluginStart()
{
    if ((StringToInt(DEF_MAX_ACCEPTABLE_FOV) <
            StringToInt(DEF_MIN_ACCEPTABLE_FOV)) ||
            StringToInt(DEF_MAX_ACCEPTABLE_FOV) <= 0)
    {
        SetFailState("DEF_MAX_ACCEPTABLE_FOV (%s) < DEF_MIN_ACCEPTABLE_FOV \
(%s) || DEF_MAX_ACCEPTABLE_FOV (%s) <= 0",
            DEF_MAX_ACCEPTABLE_FOV, DEF_MIN_ACCEPTABLE_FOV,
            DEF_MAX_ACCEPTABLE_FOV);
    }
    g_cMinFov = CreateConVar("sm_nt_fov_min", DEF_MIN_ACCEPTABLE_FOV,
        "Minimum acceptable custom FoV", _, true, 1.0, true, 360.0);
    g_cMaxFov = CreateConVar("sm_nt_fov_max", DEF_MAX_ACCEPTABLE_FOV,
        "Maximum acceptable custom FoV", _, true, 1.0, true, 360.0);
    g_cMinFov.AddChangeHook(OnCvarChanged_FovBounds);
    g_cMaxFov.AddChangeHook(OnCvarChanged_FovBounds);

    char minfovbuff[32];
    char maxfovbuff[32];
    g_cMinFov.GetName(minfovbuff, sizeof(minfovbuff));
    g_cMaxFov.GetName(maxfovbuff, sizeof(maxfovbuff));
    char fov_description_base[] = "Client command for FoV adjustment. \
If no parameters are provided, displays a graphical options menu. Optional \
parameters: the FoV number desired; its value will be clamped inside the \
%s-%s range.";
    char fov_description[
        sizeof(fov_description_base) +
        sizeof(minfovbuff) +
        sizeof(maxfovbuff) + 1
    ];
    Format(
        fov_description,
        sizeof(fov_description),
        fov_description_base,
        minfovbuff,
        maxfovbuff
    );
    RegConsoleCmd("sm_fov", Command_Fov, fov_description);

    // view_as... for SM <1.11 support, where RegClientCookie used to return Handle
    g_ccFov = view_as<Cookie>(RegClientCookie("fov_custom", "Desired custom FoV.",
        CookieAccess_Public));
}

public void OnCvarChanged_FovBounds(ConVar convar, const char[] oldValue,
    const char[] newValue)
{
    int new_fov = StringToInt(newValue);
    // If invalid value, reset to default
    if (new_fov == 0)
    {
        new_fov = StringToInt(
            (convar == g_cMinFov) ?
            DEF_MIN_ACCEPTABLE_FOV : DEF_MAX_ACCEPTABLE_FOV
        );
        if (new_fov == 0)
        {
            SetFailState("Failed to restore default cvar value");
        }
    }
    else
    {
        new_fov = Min(360, Max(1, new_fov));
    }

    int other_fov = (convar == g_cMinFov) ?
        g_cMaxFov.IntValue : g_cMinFov.IntValue;
    if (convar == g_cMinFov)
    {
        // Max FoV should never be smaller than min FoV
        if (g_cMaxFov.IntValue < new_fov)
        {
            other_fov = new_fov;
        }
    }
    else if (g_cMinFov.IntValue > new_fov)
    {
        // Min FoV should never be larger than max FoV
        other_fov = new_fov;
    }

    convar.IntValue = new_fov;
    // If min or max FoV stepped over the other FoV limit, also adjust that
    // one to ensure min <= max.
    if (other_fov == new_fov)
    {
        SetConVarInt(
            (convar == g_cMinFov) ? g_cMaxFov : g_cMinFov,
            other_fov
        );
    }
    // Clamp players' current FoV values in accordance with the new cvars.
    for (int client = 1; client <= MaxClients; ++client)
    {
        if (!IsClientInGame(client) || IsFakeClient(client))
        {
            continue;
        }
        SetClientFov(client, _, false);
    }
}

public void OnClientPutInServer(int client)
{
    // Queries the client for the custom client cvar,
    // and uses its existence to detect the presence of the FoV patch.
    QueryClientConVar(client, "fovispatched", OnCvarQueryFinished_FovPatch);
}

public void OnCvarQueryFinished_FovPatch(QueryCookie cookie, int client,
    ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
    g_bIsUsingPatchedFov[client] = (result == ConVarQuery_Okay);
    if (!g_bIsUsingPatchedFov[client])
    {
        return;
    }
    // If the client has the FoV patch, set their FoV from the clientpref
    // cookie, if the client has one.
    char buffer_fov[4];
    g_ccFov.Get(client, buffer_fov, sizeof(buffer_fov));
    int new_fov = StringToInt(buffer_fov);
    // Parse failure or client didn't have a preference.
    if (new_fov == 0)
    {
        return;
    }

    SetClientFov(client, new_fov);
}

public void OnClientDisconnect_Post(int client)
{
    g_bIsUsingPatchedFov[client] = false;
}

// Set the custom FoV entprop of a client (will be clamped),
// and optionally store it to the client's preference cookie.
// If desired_fov is -1, only apply the FoV clamp restrictions to their
// current FoV.
void SetClientFov(int client, const int desired_fov = -1,
    bool save_preference = true)
{
    int fov = desired_fov;
    if (fov == -1)
    {
        fov = GetEntProp(client, Prop_Send, ENTPROP_FOV);
        if (fov == -1)
        {
            ThrowError("Unexpected \"fov\" value: %d", fov);
        }
    }

    SetEntProp(client, Prop_Send, ENTPROP_FOV, ClampFov(fov));
    if (save_preference)
    {
        char fov_buffer[4];
        if (IntToString(desired_fov, fov_buffer, sizeof(fov_buffer)) > 0)
        {
            g_ccFov.Set(client, fov_buffer);
        }
    }
}

public Action Command_Fov(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client,
            "%s This command cannot be executed by the server.",
            g_sPluginTag
        );
        return Plugin_Handled;
    }

#if(!DEBUG_NOPATCH)
    if (!g_bIsUsingPatchedFov[client])
    {
        // TODO: replace these placeholder texts with the correct informational stuff
        ReplyToCommand(client, "%s Sorry, you don't seem to have the client patch installed.", g_sPluginTag);
        ReplyToCommand(client, "Please download the client patch from: %s and try again.", g_sDownloadUrl);

        // This stuff only makes sense to the user if the client is patched,
        // so early return if that is not the case.
        return Plugin_Handled;
    }
#endif

    bool success = false;

    if (args == 0)
    {
        success = ShowFovMenu(client);
    }
    else if (args == 1)
    {
        int new_fov;
// Because old SM doesn't have GetCmdArgIntEx
#if SOURCEMOD_V_MAJOR <= 1 && SOURCEMOD_V_MINOR < 11
        char fov_buffer[4];
        if (GetCmdArg(1, fov_buffer, sizeof(fov_buffer)) > 0)
        {
            new_fov = StringToInt(fov_buffer);
            if (new_fov != 0)
#else
        {
            if (GetCmdArgIntEx(1, new_fov))
#endif
            {
                SetClientFov(client, new_fov);
                success = true;
            }
        }
    }

    if (success)
    {
        ReplyToCommand(client,
            "%s Your FoV is now: %d",
            g_sPluginTag,
            GetEntProp(client, Prop_Send, ENTPROP_FOV)
        );
    }
    else
    {
        char cmdname[16];
        GetCmdArg(0, cmdname, sizeof(cmdname));
        ReplyToCommand(client, "%s Usage: %s <optional: FoV number>",
            g_sPluginTag, cmdname);
    }

    return Plugin_Handled;
}

int Min(int a, int b)
{
    return a < b ? a : b;
}

int Max(int a, int b)
{
    return a > b ? a : b;
}

// For a given integer val, returns that val bound within the min-max range,
// inclusive.
int ClampInt(int val, int min, int max)
{
    return Min(Max(val, min), max);
}

// For a given integer FoV, returns that FoV bound within the min/max FoV
// server cvars range, inclusive.
int ClampFov(int fov)
{
    return ClampInt(fov, g_cMinFov.IntValue, g_cMaxFov.IntValue);
}

// For a given FoV, passes by reference an ASCII string representation of a
// progress slider of that FoV bound inside the min/max FoV server cvars range.
// Returns boolean of whether a string representation was successfully passed.
bool GetFovSliderAsciiArt(int fov, char[] out_art, int out_art_maxlen)
{
    if (out_art_maxlen < 2)
    {
        return false;
    }

    fov = ClampFov(fov);
    // Construct a "<----I---->" style slider character art,
    // where the boundaries are represented as "<" and ">",
    // the line as "-", and the current value's position as "I".
    out_art[0] = '<';
    for (int i = 1; i < out_art_maxlen - 1; ++i)
    {
        out_art[i] = '-';
    }
    out_art[out_art_maxlen - 1] = '>';
    // Place the "I" character in the slider to represent
    // the current slider position.
    int current_slider_pos = ClampInt(       // This should stay in range, but
        RoundToNearest(                      // is bothersome to recover from
            ((fov - g_cMinFov.FloatValue) /  // if it doesn't, so clamp it jic
            (float(GetAllowedFovRange() + 3))
        ) * out_art_maxlen) + 1,
        1,
        out_art_maxlen - 2
    );
    out_art[current_slider_pos] = 'I';

    return true;
}

// Returns the difference between max and min allowed FoV server cvars range.
// Assumes max value will never be smaller than min value.
int GetAllowedFovRange()
{
    return g_cMaxFov.IntValue - g_cMinFov.IntValue;
}

// Create and display a new FoV menu to a client.
// Assumes valid client.
// The memory of the menu is freed by the menu handler callback.
// Returns a boolean of whether a menu was successfully displayed.
bool ShowFovMenu(int client)
{
    int fov_range = GetAllowedFovRange();
    if (fov_range < 1)
    {
        return false;
    }

    int current_fov = GetEntProp(client, Prop_Send, ENTPROP_FOV);

    char[] slider_acsii_art = new char[fov_range + 1];
    if (!GetFovSliderAsciiArt(current_fov, slider_acsii_art, fov_range))
    {
        return false;
    }

    Menu menu_fov = new Menu(MenuHandler_Fov);
    menu_fov.SetTitle("Your current FoV is: %d\n%s", current_fov,
        slider_acsii_art);
    menu_fov.AddItem("", "Decrease FoV", ITEMDRAW_DEFAULT);
    menu_fov.AddItem("", "Increase FoV", ITEMDRAW_DEFAULT);
    return menu_fov.Display(client, MENU_TIME_FOREVER);
}

// MenuHandler callback of the FoV menu.
// Responsible for freeing the menu memory on MenuAction_End.
// Always returns 0, because we do not modify any menu items.
// Note that "client" and "selection" assume a context of MenuAction_Select;
// for other MenuAction contexts they may contain other things,
// such as MenuEnd reason enumerations etc.
public int MenuHandler_Fov(Menu menu, MenuAction action,
    int client, int selection)
{
    if (action == MenuAction_Select)
    {
        bool make_smaller = (selection == 0);
        int addendum = make_smaller ? -1 : 1;
        int new_fov = GetEntProp(client, Prop_Send, ENTPROP_FOV) + addendum;
        SetClientFov(client, new_fov);
        ShowFovMenu(client);
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }

    return 0;
}
