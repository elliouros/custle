const gamedata = {
  Quality: {
    type: single
  }
  Type: {
    type: single
  }
  Pool: {
    type: multi
  }
  Description: {
    type: multi
  }
  Colors: {
    type: multi
  }
  Unlock: {
    type: single
  }
  Release: {
    type: single
  }
}

# Raw output:
# nu isaacle-to-nuon.nu [--items] | save [-f] <path>
#
# With formatting:
# nu isaacle-to-nuon.nu [--items] | from nuon | to nuon <options> | save [-f] <path>
def main [
  --items (-i) # output just item data instead of game data
] {
  # NOTE: not from official isaacle! Therefore, prone to becoming outdated.
  # I couldn't find an endpoint for the official version by Chunobi.
  http https://raw.githubusercontent.com/MitchLeff/IsaacleSovler/refs/heads/main/items.json
  | rename name Quality Type Pool Description Colors Unlock Release
  | update Pool {split row ','}
  | update Description {split row ','}
  | update Colors {split row ','}
  | if $items {$in} else {
    {
      updated: (date now)
      fields: $gamedata
      items: $in
    }
  }
  | to nuon -r
}
