---
sidebar_position: 2
title: "Core Concepts"
---

# Core Concepts

This page goes over some core concepts that you should be familiar with in order to use Matter and effectively write code using an ECS.

## Entities

An entity represents something in your game. It might be a player character, an enemy, or a tree. Generally, you will have one entity per thing you want to represent in your game. In Matter (as well as a typical ECS), an entity is just a unique number.

## Components

Components are pieces of data that you can attach to entities. Since entities are just numbers, all the information about an entity is stored in its components. Components are data structures that you define and reuse across many different entities.

For example, you might define a `Health` component, which has two fields: `current` and `max`. You can then reuse the `Health` component across many different entities. You might add it to both player entities and enemy entites. Or even a tree, if you have trees that can take damage.

An important distinction between a more object-oriented way of thinking and ECS is that instead of having an object that has methods and fields (`Enemy` class to represent an enemy), entities are much more flexible. There is really no such thing as an "enemy entity" or "tree entity". Instead, there are entities that have the `Enemy` component, or have the `Tree` component. It's possible, then, for there to be an entity that has both the `Enemy` *and* `Tree` components. You might also give it the `Health` component if you want it to be able to take damage.

So, instead of thinking about things based on what they are, we instead think of the in terms of characteristics that they have. This creates a much more flexible data model and enables code reuse in ways that are difficult to achieve with an inheritance-based object-oriented model.

## World

A World is an object that contains all of your entities and all of their components. You will usually only have one World in your game. You create it when your game starts. (See: [GettingStarted](/docs/GettingStarted))

You can create entities in your World by using the [`World:spawn`](/api/World#spawn) method:

```lua
local newEntityId = world:spawn(
    Enemy(),
    Health({
        current = 100,
        max = 100,
    }),
    Name({
        name = "Evil Tree"
    }),
    Tree({
        type = "oak"
    })
)
```

Now, the new entity has been created with all of our specified components. We got back the new entity ID (just a number) and stored it in the variable `newEntityid`.

We can get a specific component like this:

```lua
local nameComponent = world:get(newEntityId, Name)

print(nameComponent.name)
```


Here's a quick, incomplete reference of the things you can do:

Method | Description
-------|------------
`spawn` | spawn a new entity with given components
`insert`| Add new or replace an existing  component on an existing entity
`get` | Get a specific component or set of components from an existing entity
`remove` | Remove a component from an existing entity.
`despawn` | Remove all components from an entity and delete the entity.
`contains` | Check whether or not an entity still exists in the world.

Check out the [`World` API reference](/api/World) to see everything else you can do!

## Systems

Since components are just data, we need a way to actually... do things! This is where Systems come in. A system is just a function that runs every frame in a specific order alongside your other systems. Typically, a system only does one job, using a specific set of components.

We can reuse our `Health` component from earlier. Let's say that in our game, we want anything with health to regenerate its HP over time. Remember, we don't care about what the things actually are that we are dealing with here. We don't care if it's a player, an enemy, or a tree: all we know is that it has health.

A good way to name systems is by declaring something about the world that they do. In this case: "Health Regenerates."

```lua title="healthRegenerates.lua"
for id, health in world:query(Health) do
    if health.current < health.max then
        world:insert(id, health:patch({
            -- Regenerate 0.1% of maximum health per frame
            current = math.min(health.max, health.current + (health.max * 0.001))
        })
    end
end
```

In the above code sample, we use the [World:query](/api/World#query) method to loop over everything in the world that has `Health`, and regenerate some.

You can also query for multiple components at once, i.e. if you only wanted to select `Player`s with `Health`. Then, you will only get entities that have both components.

Systems can also interact with Roblox Instances and change things through side effects. The [Reconciliation](/docs/BestPractices/Reconciliation) page goes over this in more detail.

## Loop

The `Loop` object in Matter is a simple way to handle running your Systems in the same order every frame. This is covered on the [GettingStarted](/docs/GettingStarted) page. It's not technically required, but makes setting up Matter much easier and enables some topologically-aware features.

## Topologically-aware functions

Many functions in matter are *topologically-aware*: this means that they store some state which is referenced by the file and line number where the function is called from. `useEvent`, `useThrottle`, and `World:queryChanged` are all examples. This works in a similar way to "hooks" from React/Roact, and so we often refer to topologically-aware functions with the term "hook".

Under the hood, Matter creates and stores state that these functions use and references them by the call location, in contrast to having to come up with a name or place to store it yourself. The script name and line number become the way that we identify the state storage for whatever function you called. This only works when your Systems are invoked by a Matter `Loop`.

You can learn more about this and even implement your own topologically-aware functions on the [`useHookState` docs](/api/Matter#useHookState).
