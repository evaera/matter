---
sidebar_position: 1
---

# Matter

Matter is a modern ECS library for Roblox.

:::danger Still baking!
Matter isn't quite ready for production yet. There might be bugs and missing features!
:::

Matter is a pure ECS library with fast archetypical entity storage, automatic system scheduling, and a slick API featuring topologically-aware state. Matter empowers users to build games that are extensible, performant, and easy to debug.

## Goals

- Simple, obvious API
- Performant
- Great debuggability, error handling and insight into what's actually happening each frame
- Common patterns are easy to fall into and hard to mess up

## Non-goals

- Many similar libraries, ECS or not, end up with a bloated API, requiring significant cognitive overhead to use. We want to avoid this as much as possible.
- We don't want to provide every thing the user could ever want in our library. Instead, it should be easy for users to write obvious code that does those things.

## Performance today

Matter currently achieves an average frame time of 0.65ms spent inside Matter code for the following benchmark:

- World with 1000 entities
- Between 2-30 components on each entity
- 300 unique component types
- 200 systems
- Each system queries between 1 and 10 components
