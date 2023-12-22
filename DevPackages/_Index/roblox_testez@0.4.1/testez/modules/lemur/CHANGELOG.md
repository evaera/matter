# Lemur Changelog

## Master
* Added stub for `spawn` that doesn't do anything
* Added `Script` and `LocalScript` containers
* Added `Color3.new()` and `Color3.fromRGB(r, g, b)` constructor variants ([#2](https://github.com/LPGhatguy/lemur/pull/2))
* Added `Instance:GetPropertyChangedSignal(name)` ([#5](https://github.com/LPGhatguy/lemur/pull/5))
* Improved `Instance:Destroy()` ([#17](https://github.com/LPGhatguy/lemur/pull/17))
* Added `Instance:GetFullName()` ([#23](https://github.com/LPGhatguy/lemur/pull/23))
* Added `Instance:ClearAllChildren()`, `Instance:FindFirstAncestor(name)` and `Instance:FindFirstAncestorOfClass(className)` ([#24](https://github.com/LPGhatguy/lemur/pull/24))
* Roblox Instances are now `userdata`
* `RunService` is now correctly named `Run Service` ([#25](https://github.com/LPGhatguy/lemur/pull/25))
* Added `Instance:FindFirstChildOfClass(name)` and `Instance:FindFirstChildWhichIsA(className)`
* Changed `Signal:Wait()` mechanism to error instead of fire the event
* Added `bit32`; requires `bit32` luarock to be installed

## v0.1.0 (November 28, 2017)
* Initial release
* Fairly minimal API coverage