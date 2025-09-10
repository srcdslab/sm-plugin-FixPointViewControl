# Copilot Instructions for FixPointViewControl

## Repository Overview

This repository contains a SourceMod plugin called **FixPointViewControl** that fixes a critical bug with `point_viewcontrol` entities in Source engine games. The plugin uses DHooks to intercept the `AcceptInput` function and properly handle the "Disable" command for viewcontrol entities.

**Key Technical Details:**
- **Language**: SourcePawn
- **Platform**: SourceMod 1.12+ (configured for 1.11.0-git6917 minimum)
- **Build System**: SourceKnight (modern SourceMod build tool)
- **Primary Function**: Hooks `point_viewcontrol` entities to fix disable functionality

## Project Structure

```
/addons/sourcemod/scripting/
├── FixPointViewControl.sp    # Main plugin source code
/sourceknight.yaml           # Build configuration
/.github/workflows/ci.yml    # CI/CD pipeline
/.gitignore                  # Git ignore patterns
```

## Build System & Development Workflow

### SourceKnight Build Tool
This project uses SourceKnight for compilation, configured in `sourceknight.yaml`:
- **Target**: SourceMod 1.11.0-git6917
- **Output**: `/addons/sourcemod/plugins`
- **Build Command**: Use GitHub Actions or install SourceKnight locally

### Building Locally
```bash
# If SourceKnight is installed:
sourceknight build

# The compiled .smx file will be in the configured output directory
```

### CI/CD Pipeline
- Automatic builds on push/PR via GitHub Actions
- Uses `maxime1907/action-sourceknight@v1` action
- Creates releases with artifacts for master/main branch pushes
- Tags latest builds automatically

## Code Style & Standards

### SourcePawn Specific Guidelines
- **ALWAYS** use `#pragma semicolon 1` and `#pragma newdecls required` at the top
- Use tabs for indentation (4 spaces)
- Follow camelCase for local variables: `iActivator`, `sCommand`
- Use PascalCase for functions: `OnPluginStart()`, `Hook_AcceptInput()`
- Prefix global variables with "g_": `g_hAcceptInput`
- Use descriptive variable names that indicate type and purpose

### Memory Management
- Use `delete` for Handle cleanup (never check for null first)
- Set handles to `INVALID_HANDLE` after deletion if reused
- Always clean up DHook handles in `OnPluginEnd()` if needed

### DHooks Best Practices
- Create DHooks in `OnPluginStart()` with proper parameter definitions
- Use `DHookEntity()` for entity-specific hooks (as done with `point_viewcontrol`)
- Always validate parameters with `DHookIsNullParam()` before use
- Return `MRES_Ignored` when not modifying behavior

## Plugin-Specific Knowledge

### Core Functionality
This plugin specifically addresses a bug where `point_viewcontrol` entities don't properly handle the "Disable" input. The fix:

1. **Entity Hook**: Hooks all `point_viewcontrol` entities when created
2. **Input Interception**: Intercepts `AcceptInput` calls
3. **Disable Fix**: When "Disable" command is received, sets `m_hPlayer` property to the activator

### Critical Code Patterns
```sourcepawn
// Proper DHook setup for AcceptInput
g_hAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, Hook_AcceptInput);
DHookAddParam(g_hAcceptInput, HookParamType_CharPtr);      // Command name
DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);  // Activator
DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);  // Caller
DHookAddParam(g_hAcceptInput, HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP);
DHookAddParam(g_hAcceptInput, HookParamType_Int);          // Output ID

// Proper parameter validation
if(DHookIsNullParam(hParams, 2))
    return MRES_Ignored;

// Client validation for activator
if (iActivator < 1 || iActivator > MaxClients)
    return MRES_Ignored;
```

## Testing & Validation

### Manual Testing
1. Load plugin on a Source engine game server (CS:S, CS:GO, TF2, etc.)
2. Create a map with `point_viewcontrol` entities
3. Test the "Disable" input functionality
4. Verify the viewcontrol properly releases player control

### Code Quality Checks
- Ensure no memory leaks (use SourceMod's memory profiler)
- Validate all client indices before use
- Check DHook parameter validation
- Test with different Source engine games if applicable

## Common Modification Patterns

### Extending Functionality
When adding new features to this plugin:

1. **New Entity Types**: Add similar hooks in `OnEntityCreated()` for other entity classes
2. **Additional Inputs**: Extend the `Hook_AcceptInput()` function to handle more commands
3. **Player Validation**: Always validate player indices when dealing with activators
4. **Error Handling**: Add proper error handling for SDK calls and entity operations

### Performance Considerations
- This plugin hooks every `point_viewcontrol` entity creation (low impact)
- `AcceptInput` hook only fires when inputs are triggered (event-driven)
- Minimal performance impact due to targeted entity-specific hooks

## Dependencies & Requirements

### Required Includes
```sourcepawn
#include <sourcemod>   // Core SourceMod functionality
#include <sdkhooks>    // SDK hooks for engine integration
#include <sdktools>    // SDK tools for entity manipulation
#include <dhooks>      // Dynamic hooks for runtime patching
```

### Game Support
- All Source engine games with `point_viewcontrol` entities
- Tested on: Counter-Strike: Source, Counter-Strike: Global Offensive, Team Fortress 2
- Requires sdktools.games gamedata for `AcceptInput` offset

## Version Management

- Current version: 1.1 (as defined in plugin info)
- Use semantic versioning for future releases
- Update version in plugin info block when making changes
- CI automatically creates releases for tagged versions

## Security Considerations

- Always validate client indices (1 ≤ client ≤ MaxClients)
- Use `DHookIsNullParam()` to check for null parameters
- No user input validation needed (engine handles input parsing)
- DHooks operate at engine level - be cautious with modifications

## Troubleshooting Common Issues

### Build Failures
- Ensure SourceKnight configuration matches SourceMod version
- Check that all required includes are available
- Validate gamedata files exist for target SourceMod version

### Runtime Issues
- Verify `AcceptInput` offset exists in gamedata
- Check that `point_viewcontrol` entities exist in the target game
- Ensure DHook handles are created successfully before use

### Integration Problems
- Test compatibility with other plugins that hook `AcceptInput`
- Verify entity property names (`m_hPlayer`) are correct for target games
- Check for conflicts with other entity manipulation plugins