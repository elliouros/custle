# Custle

Custom statistic matching games, the likes of [Terradle](https://terradle.com)
(Implemented in Custle!), [Isaacle](https://isaacle.net),
[Wardle](https://wardlegame.com), and (probably) many others.

To get started, play terradle with `nu custle.nu games/terra.nuon` or make your
own by following the guide below.

## Creating a game

### Fields

Each game is defined by a single record containing a `fields` field and `items`
field. the `fields` field is a record, the keys of which correspond to an
item's stat. Each value is a record containing at least a `type` field.

Types of fields currently implemented are:
- single: Either the value matches, or not.
- multi: multiple values at once, can have partial matches.
- numbered: integer or float types that are compared automatically
- ordered: values correspond to a hierarchy.

In an `ordered` field, a `values` field should also be included in the record.
This field contains all possible values and enumerates them for comparison.
If this makes your game too easy, consider using `single` even when `ordered`
might make sense.

### Items

Now, it's time to define items. This is most easily done using nuon's
`[[]; []]` table constructing syntax. A `name` field is required (and ideally
first/leftmost), and the rest should be the same as you put earlier.

See `games/terra.nuon` for an example.
