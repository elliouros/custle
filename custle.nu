#!/usr/bin/env nu

def 'compare multi' [hidden: list]: list -> string {
  let input = $in
  let target = $hidden | length
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
  } else if ($in < $target) {
    ansi yb
  } else {
    ansi gb
  }
  | $'($in)($input)(ansi rst)'
}

def 'compare single' [hidden: any]: any -> string {
  let input = $in
  if ($hidden == $in) {
    ansi gb
  } else {
    ansi rb
  }
  | $'($in)($input)(ansi rst)'
}

def 'compare ordered' [
  game: record
  field: string
  hidden: any
]: any -> string {
  let input = $in
  let hidden_index = $game | get ([fields $field values $hidden] | into cell-path)
  let input_index = $game | get ([fields $field values $input] | into cell-path)
  if ($input_index > $hidden_index) {
    $'(ansi rb)($input) \/(ansi rst)'
  } else if ($input_index == $hidden_index) {
    $'(ansi gb)($input)'
  } else {
    $'(ansi rb)($input) /\(ansi rst)'
  }
}

def 'compare numbered' [hidden: number]: number -> string {
  let input = $in
  if ($input > $hidden) {
    $'(ansi rb)($input) \/(ansi rst)'
  } else if ($input == $hidden) {
    $'(ansi gb)($input)'
  } else {
    $'(ansi rb)($input) /\(ansi rst)'
  }
}

def compare [
  game: record
  hidden: record
]: record -> any {
  let input = $in | reject name
  $input
  | transpose key value
  | each {|it|
    let type = $game | get ([fields $it.key type] | into cell-path)
    let hidden = $hidden | get $it.key
    $it.value
    | match $type {
      'numbered' => {
        compare numbered $hidden
      },
      'ordered' => {
        compare ordered $game $it.key $hidden
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

# def only []: list -> any {
#   if ($in | length | $in == 1) {
#     $in | first
#   } else {
#     error make {msg: 'tried to take only of non-singleton or empty list'}
#   }
# }

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

def main [game: path] {
  let game = open $game
  let hidden = $game.items | random choice
  loop {
    $game.items
    | input list -fd name
    | compare $game $hidden
    | transpose -ird # ???
    | print
  }
}
