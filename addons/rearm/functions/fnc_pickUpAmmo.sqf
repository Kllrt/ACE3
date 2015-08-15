/*
 * Author: GitHawk
 * Picks up a specific kind of magazine from an ammo truck
 *
 * Arguments:
 * 0: The Ammo Truck <OBJECT>
 * 1: The Player <OBJECT>
 * 2: The Params <ARRAY>
 * 2,0: The Magazine <STRING>
 * 2,1: The Vehicle to be armed <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [ammo_truck, player, ["500Rnd_127x99_mag_Tracer_Red", tank]] call ace_rearm_fnc_pickUpAmmo
 *
 * Public: No
 */
#include "script_component.hpp"

private ["_ammo", "_tmpCal", "_cal"];
params ["_target","_unit","_args"];
_args params ["_magazine", "_vehicle"];

_ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
_tmpCal = getNumber (configFile >> "CfgAmmo" >> _ammo >> "ace_caliber");
_cal = 8;
if (_tmpCal > 0) then {
    _cal = _tmpCal;
} else {
    _tmpCal = getNumber (configFile >> "CfgAmmo" >> _ammo >> "ace_logistics_caliber");
    if (_tmpCal > 0) then {
        _cal = _tmpCal;
    } else {
        diag_log format ["ACE_Logistics: Undefined Ammo [%1 : %2]", _ammo, inheritsFrom (configFile >> "CfgAmmo" >> _ammo)];
        if (_ammo isKindOf "BulletBase") then {
            _cal = 8;
        } else {
            _cal = 100;
        };
    };
};
_cal = round _cal;
_idx = CALIBERS find _cal;
if (_idx == -1 ) then {
    _idx = 2;
};

[
    (DURATION_PICKUP select _idx),
    [_unit, _magazine],
    FUNC(pickUpSuccess),
    "",
    format [localize LSTRING(PickUpAction), getText(configFile >> "CfgMagazines" >> _magazine >> "displayName"), getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")],
    {true},
    ["isnotinside"]
] call EFUNC(common,progressBar);