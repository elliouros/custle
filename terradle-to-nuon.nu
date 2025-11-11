const gamedata = {
  Type: {
    type: single
  }
  Damage: {
    type: numbered
  }
  Knockback: {
    type: ordered
    values: {
      'No knockback': 0
      'Extremely weak': 1
      'Very weak': 2
      'Weak': 3
      'Average': 4
      'Strong': 5
      'Very strong': 6
      'Extremely strong': 7
      'Insane': 8
    }
  }
  Speed: {
    type: ordered
    values: {
      'Snail': 0
      'Extremely slow': 1
      'Very slow': 2
      'Slow': 3
      'Average': 4
      'Fast': 5
      'Very fast': 6
      'Insanely fast': 7
    }
  }
  Rarity: {
    type: ordered
    values: {
      'White': 0
      'Blue': 1
      'Green': 2
      'Orange': 3
      'Light Red': 4
      'Pink': 5
      'Light Purple': 6
      'Lime': 7
      'Yellow': 8
      'Cyan': 9
      'Red': 10
    }
  }
  Autoswing: {
    type: single
  }
  Material: {
    type: single
  }
  Obtained: {
    type: multi
  }
}

# Raw output:
# nu terradle-to-nuon.nu [--items] | save [-f] <path>
#
# With formatting:
# nu terradle-to-nuon.nu [--items] | from nuon | to nuon <options> | save [-f] <path>
def main [
  --items (-i) # output just item data instead of game data
] {
  let data = http https://raw.githubusercontent.com/cxhuy/terradle-web/refs/heads/main/src/lib/data/weapons.js
  | [$in] # Anti-multiline hack for parse (necessary?)
  | parse -r 'export const gameVersion = "(?<version>[\d\.]+)"

export const weaponData = (?<items>[\w\W]+)' # hack shittttttt
  | get $.0

  $data
  | get $.items
  | from json
  | get data
  | select name damageType damage knockback speed rarity autoswing material obtained
  | upsert damage {|item| $item.damage | into int}
  | upsert rarity {|item|
    match $item.rarity {
      '0' =>  {'White'}
      '1' =>  {'Blue'}
      '2' =>  {'Green'}
      '3' =>  {'Orange'}
      '4' =>  {'Light Red'}
      '5' =>  {'Pink'}
      '6' =>  {'Light Purple'}
      '7' =>  {'Lime'}
      '8' =>  {'Yellow'}
      '9' =>  {'Cyan'}
      '10' => {'Red'}
    }
  }
  | upsert autoswing {|item|
    if $item.autoswing {
      'Yes'
    } else {
      'No'
    }
  }
  | upsert material {|item|
    if $item.material {
      'Yes'
    } else {
      'No'
    }
  }
  | rename name Type Damage Knockback Speed Rarity Autoswing Material Obtained
  | if $items {$in} else {
    {
      game-version: $data.version
      updated: (date now)
      fields: $gamedata
      items: $in
    }
  }
  | to nuon -r
}
