This template generator will automatically detect the presence of a CMakePresets.json or CMakeUserPresets.json, 
and add the presets available to you to the list of Overseer tasks. 
**Please note that the preset must have both a name and displayName assigned to it, otherwise it will not show up!**

Running a task is the equivalent of 
>```cmake /path/to/CMakePresets.json --preset=preset_name```
for Configure Presets or
>```cmake /path/to/CMakePresets.json --build --preset=preset_name``` for Build Presets.

Other presets automatically detected are Test Presets, Package Presets, and Workflow Presets. 
However, I have not yet tested these and the commands may be slightly wrong.

### Requirements
  * NeoVim 0.10 >
  * [Overseer](https://github.com/stevearc/overseer.nvim)
  
### How to use
1) Clone this repository into your overseer directory under your NeoVim config directory
> (~/.config/nvim/lua/overseer/template)

2) Call Overseer.setup("overseer-cmake-template/cmake_presets")
