//-----USS Almayer Machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.

/obj/machinery/vending/marine/uniform_supply
	name = "ColMarTech Surplus Uniform Vender"
	desc = "A automated weapon rack hooked up to a colossal storage of uniforms"
	icon_state = "armory"
	icon_vend = "armory-vend"
	icon_deny = "armory"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/storage/backpack/marine = 10,
					/obj/item/device/radio/headset/msulaco = 10,
					/obj/item/weapon/storage/belt/marine = 10,
					/obj/item/clothing/shoes/marine = 10,
					/obj/item/clothing/under/marine = 10
					)

	prices = list()

	New()

		..()
		if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
			var/products2[]
			switch(squad_tag)
				if("Alpha")
					products2 = list(/obj/item/device/radio/headset/malpha = 20)
				if("Bravo")
					products2 = list(/obj/item/device/radio/headset/mbravo = 20)
				if("Charlie")
					products2 = list(/obj/item/device/radio/headset/mcharlie = 20)
				if("Delta")
					products2 = list(/obj/item/device/radio/headset/mdelta = 20)
			build_inventory(products2)
		marine_vendors.Add(src)

