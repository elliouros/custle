#!/usr/bin/env nu

def 'compare multi' [hidden: list]: list -> string {
  let input = $in
  let target = $hidden | length
  let in_length = $input | length
  mut matches = 0
  for value in $input {
    if ($value | in $hidden) {
      $matches += 1
    }
  }
  let input = $input | str join ', '
  $matches
  | if ($in <= 0) {
    ansi rb
  } else if ($in < $target or $in_length != $target) {
    #                       # ^bandaid-ish logic here? it works, though
    ansi yb
  } else {
    ansi gb
  }
  | $'($in)($input)(ansi reset)'
}

def 'compare single' [hidden: any]: any -> string {
  let input = $in
  if ($hidden == $in) {
    ansi gb
  } else {
    ansi rb
  }
  | $'($in)($input)(ansi reset)'
}

def 'compare ordered' [
  fields: record
  field: string
  hidden: any
]: any -> string {
  let input = $in
  let hidden_index = $fields | get ([$field values $hidden] | into cell-path)
  let input_index = $fields | get ([$field values $input] | into cell-path)
  if ($input_index > $hidden_index) {
    $'(ansi rb)($input) \/(ansi reset)'
  } else if ($input_index == $hidden_index) {
    $'(ansi gb)($input)'
  } else {
    $'(ansi rb)($input) /\(ansi reset)'
  }
}

def 'compare numbered' [hidden: number]: number -> string {
  let input = $in
  if ($input > $hidden) {
    $'(ansi rb)($input) \/(ansi reset)'
  } else if ($input == $hidden) {
    $'(ansi gb)($input)'
  } else {
    $'(ansi rb)($input) /\(ansi reset)'
  }
}

def compare [
  fields: record
  hidden: record
]: record -> any {
  let input = $in
  if ($input == $hidden) {return true}
  $input
  | reject name
  | transpose key value
  | each {|it|
    let type = $fields | get ([$it.key type] | into cell-path)
    let hidden = $hidden | get $it.key
    $it.value
    | match $type {
      'numbered' => {
        compare numbered $hidden
      },
      'ordered' => {
        compare ordered $fields $it.key $hidden
      },
      'single' => {
        compare single $hidden
      },
      'multi' => {
        compare multi $hidden
      }
    }
    | {key: $it.key val: $in}
  }
}

def 'random choice' []: list -> any {
  let list = $in
  let max = $in | length | $in - 1
  $list
  | get (random int 0..$max)
}

def in [list] {
  let value = $in
  $list
  | reduce -f false {|it,acc|
    if ($acc == true) {return true}
    if ($it == $value) {return true}
    false
  }
}

def only []: list -> any {
  if ($in | length | $in == 1) {
    first
  } else {
    error make {msg: 'Tried to take only of non-singleton!'}
  }
}

def main [
  game: path
  --item (-i): any # Specify item to use. Clears the terminal!
  --base64 (-b): any # Specify item by base64 code.
] {
  let game = open $game
  let hidden = $game.items
    | if ($item != null) {
      let $items = $in
      clear
      $items
      | where name == $item
      | only
    } else if ($base64 != null) {
      where name == ($base64 | decode base64 | decode)
      | only
    } else {
      random choice
    }
  loop {
    $game.items
    | input list -fd name
    | do {let i = $in; $'($i.name):' | print; $i}
    | compare $game.fields $hidden
    | if ($in == true) {
      break
    } else { $in }
    | transpose -ird # ???
    | print
  }
  'You win!'
}

# cheats

def 'resolve-ordered' [fields] {
  let items = $in
  $items
  | columns
  | reduce -f $items {|column, items|
    if (
      $column != name and (
        $fields
        | get ([$column type] | into cell-path)
        | $in == ordered
      )
    ) {
      $items
      | update $column {|row| let value = $in
        $fields
        | get ([$column values $value] | into cell-path)
      }
    } else {$items}
  }
}

# Search a game's database by comparing with known statistics
#
# Queries take the form of <field><comparator><value>, in which the comparator:
# For numbered or ordered fields is one of <=>
# For single fields, is one of -=
# For multi fields, is one of -*=
#
# Queries can be separated by semicolons ; for multiple queries in one round.
# Malformed queries will be ignored and *will not throw errors!*
def 'main cheat' [
  game: path
] {
  let game = open $game
  mut items = $game.items | resolve-ordered $game.fields
  while ($items | length | $in > 1) {
    $items = input
    | split row ';'
    | parse -r '(?<field>.+?)(?<compare>[-*=<>])(?<value>.+)$'
    | str trim
    | reduce -f $items {|q,acc|
      # todo TwT
    }
  }
  $items
}
