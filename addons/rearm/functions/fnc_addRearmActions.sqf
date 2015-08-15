/*
 * Author: GitHawk
 * Show the resupplyable ammunition of all surrounding vehicles.
 * Called from "insertChildren" on interact_menu
 *
 * Argument:
 * 0: Target <OBJECT>
 *
 * Return value:
 * ChildActions <ARRAY>
 *
 * Example:
 * [tank] call ace_rearm_fnc_addRearmActions
 *
 * Public: No
 */
#include "script_component.hpp"

private ["_vehicleActions", "_actions", "_action", "_vehicles", "_vehicle", "_needToAdd", "_magazineHelper", "_turretPath", "_magazines", "_magazine", "_icon"];
params ["_target"];

_vehicles = nearestObjects [_target, ["AllVehicles"], 20];
if (count _vehicles < 2) exitWith {false}; // Logistics needs at least 2 vehicles

_vehicleActions = [];
{
    _actions = [];
    _vehicle = _x;
    _needToAdd = false;
    _action = [];
    if !(_vehicle == _target) then {
        _magazineHelper = [];
        {
            _turretPath = _x;
            _magazines = _vehicle magazinesTurret _turretPath;
            {
                _magazine = _x;
                _cnt = { _x == _magazine } count (_vehicle magazinesTurret _turretPath);
                if ((_cnt < ([_vehicle, _turretPath, _magazine] call FUNC(getMaxMagazines))) && !(_magazine in _magazineHelper)) then {
                    _action = [_magazine, getText(configFile >> "CfgMagazines" >> _magazine >> "displayName"), getText(configFile >> "CfgMagazines" >> _magazine >> "picture"), {_this call FUNC(pickUpAmmo)}, {true}, {}, [_magazine, _vehicle]] call EFUNC(interact_menu,createAction);
                    _actions pushBack [_action, [], _target];
                    _magazineHelper pushBack _magazine;
                    _needToAdd = true;
                } else {
                    if (((_vehicle magazineTurretAmmo [_magazine, _turretPath]) < getNumber (configFile >> "CfgMagazines" >> _magazine >> "count")) && !(_magazine in _magazineHelper)) then {
                        _action = [_magazine, getText(configFile >> "CfgMagazines" >> _magazine >> "displayName"), getText(configFile >> "CfgMagazines" >> _magazine >> "picture"), {_this call FUNC(pickUpAmmo)}, {true}, {}, [_magazine, _vehicle]] call EFUNC(interact_menu,createAction);
                        _actions pushBack [_action, [], _target];
                        _magazineHelper pushBack _magazine;
                        _needToAdd = true;
                    };
                };
            } foreach _magazines;
        } foreach [[0], [-1], [0,0], [0,1], [1], [2]];
    };
    if (_needToAdd) then {
        _icon = getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "Icon");
        if !((_icon select [0, 1]) == "\") then {
            _icon = "";
        };
        _action = [_vehicle, getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"), _icon, "", {true}, {}, []] call EFUNC(interact_menu,createAction);
        _vehicleActions pushBack [_action, _actions, _target];
    };
} foreach _vehicles;

_vehicleActions
