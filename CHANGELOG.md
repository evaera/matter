# Changelog

## [Unreleased]
### Changed
- `queryChanged` behavior has changed slightly: If an entity's storage was changed multiple times since your system last observed it, the `old` field in the `ChangeRecord` will be the last value your system observed the entity as having for that component, rather than what it was most recently changed from.
- World and Loop types are now exported (#9)

### Fixed
- System error stack traces are now displayed properly (#12)
- `World:clear()` now correctly resets internal changed storage used by `queryChanged` (#13)

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