# Why ECS

- Behavior is declarative. Systems run every frame, and declare what the state of the world should be right now. This makes code self-healing and more resilient to game-breaking bugs than in an event-driven model where reacting to something happening only happens once.
- Game state and behavior are entirely decoupled and all game state is accessible to any system.
- Game state is structured and easy to reason about. We [reconcile state into the data model](BestPractices/Reconciliation) so we have one source of truth.
- Systems are self-contained and new adding behaviors to your game is as simple as adding a new system that declares something about how the world should be.
- Reusing code is easy because an entity can have many different types of components. Existing systems can affect new types of entities, and new systems automatically affect all related entities.
- All system code runs contiguously and in a fixed order, every frame. Event-driven code can be sensitive to ordering, because doing anything can trigger an event that jumps into another code path, which in turn could do something else that triggers an event. With systems, your code always runs in the same, fixed order, which makes it much more predictable and resilient to new behaviors caused from refactors.