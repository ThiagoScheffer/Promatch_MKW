del z_promatch2.iwd
7za a -r -tzip z_promatch2.iwd rulesets\promatch\promatch.gsc > NUL
7za a -r -tzip z_promatch2.iwd rulesets\promatch\rulesets.gsc > NUL
7za a -r -tzip z_promatch2.iwd rulesets\custom.gsc > NUL
7za a -r -tzip z_promatch2.iwd weapons\mp\*_mp > NUL
7za a -r -tzip z_promatch2.iwd mod.arena > NUL
7za a -r -tzip z_promatch2.iwd promatch\*.gsc > NUL
7za a -r -tzip z_promatch2.iwd maps\mp\gametypes\*.gsc > NUL
7za a -r -tzip z_promatch2.iwd maps\mp\*.gsc > NUL


copy /y mod.ff "H:\COD4\Mods\promatch207"
copy /y mod.ff "H:\COD4SERVER\Mods\promatch207"

copy /y z_promatch1.iwd "H:\COD4\Mods\promatch207"
copy /y z_promatch1.iwd "H:\COD4SERVER\Mods\promatch207"
copy /y z_promatch2.iwd "H:\COD4\Mods\promatch207"
copy /y z_promatch2.iwd "H:\COD4SERVER\Mods\promatch207"
copy /y z_promatch3.iwd "H:\COD4\Mods\promatch207"
copy /y z_promatch3.iwd "H:\COD4SERVER\Mods\promatch207"
exit