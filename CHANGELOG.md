# Changelog

## [0.5.3] - 2022-07-05
## Added
- Added performance information to debugger
- Add World inspector to debugger

## Fixed
- Fix confusing error when a system yields inside a plasma context

## [0.5.2] - 2022-07-01
### Fixed
- Fixed debugger panel not scrolling.
- In the debugger panel, the module name is now used when function is not named.

## [0.5.1] - 2022-06-30
### Fixed
- Fix custom debugger widgets not using the Plasma instance the user passed in.

## [0.5.0] - 2022-06-30
### Added
- Added Matter debugger.
### Changed
- Middleware now receive event name as a second parameter

## [0.4.0] - 2022-06-25
### Changed
- Modifying the World while inside `World:query` can no longer cause iterator invalidation. All operations to World while inside a query are now safe. 🎉
  - If you aren't using `Loop`, you must call `World:optimizeQueries` periodically (e.g., every frame)
- If a system stops calling `queryChanged`, its internal storage will now be cleaned up. It is no longer a requirement that a system calls `queryChanged` forever.
- `Matter.merge` (an undocumented function) now only accepts two parameters.
### Fixed
- `replaceSystem` now correctly works when other systems reference a system being reloaded in their `after` table
- If `spawnAt` is called with an entity ID that already exists, it now errors as expected.

## [0.3.0] - 2022-06-22
### Added
- Added `World:spawnAt` to spawn a new entity with a specified ID.
- Added `World:__iter` to allow iteration over all entities in the world the world from a for loop.
- Added `Loop:evictSystem(system)`, which removes a previously-scheduled system from the Loop. Evicting a system also cleans up any storage from hooks. This is intended to be used for hot reloading. Dynamically loading and unloading systems for gameplay logic is not recommended.
- Added `Loop:replaceSystem(before, after)`, which replaces an older version of a system with a newer version of the system. Internal system storage (which is used by hooks) will be moved to be associated with the new system. This is intended to be used for hot reloading.
- The Matter example game has been updated and adds support for both replication and hot reloading.
### Changed
- The first entity ID is now `1` instead of `0`
- Events that have no systems scheduled to run on them are no longer skipped upon calling `Loop:begin`.
### Fixed
- Old event listeners created by `useEvent` were not properly disconnected when the passed event changed after having been already created. The event parameter passed to useEvent is not intended to be dynamically changed, so an warning has been added when this happens.

## [0.2.0] - 2022-06-04
### Added
- Added a second parameter to `Matter.component`, which allows specifying default component data.
- Add `QueryResult:snapshot` to convert a `QueryResult` into an immutable list

### Changed
- `queryChanged` behavior has changed slightly: If an entity's storage was changed multiple times since your system last observed it, the `old` field in the `ChangeRecord` will be the last value your system observed the entity as having for that component, rather than what it was most recently changed from.
- World and Loop types are now exported (#9)
- Matter now uses both `__iter` and `__call` for iteration over `QueryResult`.
- Improved many error messages from World methods, including passing nil values or passing a Component instead of a Component instance.
- Removed dependency on Llama

### Fixed
- System error stack traces are now displayed properly (#12)
- `World:clear()` now correctly resets internal changed storage used by `queryChanged` (#13)

### Removed
- Additional query parameters to `queryChanged` have been removed. `queryChanged` now only takes one argument. If your code used these additional parameters, you can use `World:get(entityId, ComponentName)` to get a component, and use `continue` to skip iteration if it is not present.

## [0.1.2]- 2022-01-06
### Fixed
- Fix Loop sort by priority to sort properly

## [0.1.1] - 2022-01-05
### Fixed
- Fix accidental system yield error message in Loop

### Changed
- Accidentally yielding or erroring in a system does not prevent other systems from running.

## [0.1.0] - 2022-01-02

- Initial release