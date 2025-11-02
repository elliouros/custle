# clone `cxhuy/terradle-web`, find the file `/src/lib/data/weapons.json`
open terradle.json
| get $.weaponData.data
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
| save terra-items.nuon
# copy output into the `items` field of terra.nuon
# note: saves unformatted- good for minification but not ideal for debugging
