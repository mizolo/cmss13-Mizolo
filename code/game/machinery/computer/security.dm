//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/machinery/computer/secure_data//TODO:SANITY
	name = "Security Records"
	desc = "Used to view and edit personnel's security records"
	icon_state = "security"
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_WY_CORPORATE, ACCESS_MARINE_BRIDGE)
	circuit = "/obj/item/circuitboard/computer/secure_data"
	var/obj/item/card/id/scan = null
	var/obj/item/device/clue_scanner/scanner = null
	var/rank = null
	var/screen = 1
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

/obj/structure/machinery/computer/secure_data/verb/eject_id()
	set category = "Object"
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.stat || usr.lying)	return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.loc = get_turf(src)
		if(!usr.get_active_hand() && istype(usr,/mob/living/carbon/human))
			usr.put_in_hands(scan)
		scan = null
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/structure/machinery/computer/secure_data/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/card/id) && !scan)
		if(usr.drop_held_item())
			O.forceMove(src)
			scan = O
			to_chat(user, "You insert [O].")

	if(istype(O, /obj/item/device/clue_scanner) && !scanner)
		var/obj/item/device/clue_scanner/S = O
		if(!S.found_prints)
			to_chat(user, "No prints")
			return

		if(usr.drop_held_item())
			O.forceMove(src)
			scanner = O
			to_chat(user, "You insert [O].")
	
	..()

/obj/structure/machinery/computer/secure_data/attack_ai(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/structure/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..() || !allowed(usr) || stat & (NOPOWER|BROKEN))
		return

	if(!z == MAIN_SHIP_Z_LEVEL)
		to_chat(user, SPAN_DANGER("<b>Unable to establish a connection</b>: \black You're too far away from the station!"))
		return
	var/dat

	if (temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		switch(screen)
			if(1.0)
				dat += {"
<p style='text-align:center;'>"}
				dat += text("<A href='?src=\ref[];choice=Search Records'>Search Records</A><BR>", src)
				dat += text("<A href='?src=\ref[];choice=New Record (General)'>New Record</A><BR>", src)
				if(scanner)
					dat += text("<A href='?src=\ref[];choice=read_fingerprint'>Read Fingerprint</A><BR>", src)
				dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th>Criminal Status</th>
</tr>"}
				if(!isnull(data_core.general))
					for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
						var/crimstat = ""
						for(var/datum/data/record/E in data_core.security)
							if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
								crimstat = E.fields["criminal"]
						var/background
						switch(crimstat)
							if("*Arrest*")
								background = "'background-color:#DC143C;'"
							if("Incarcerated")
								background = "'background-color:#CD853F;'"
							if("Released")
								background = "'background-color:#3BB9FF;'"
							if("None")
								background = "'background-color:#00FF7F;'"
							if("")
								background = "'background-color:#FFFFFF;'"
								crimstat = "No Record."
						dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
						dat += text("<td>[]</td>", R.fields["id"])
						dat += text("<td>[]</td>", R.fields["rank"])
						dat += text("<td>[]</td></tr>", crimstat)
					dat += "</table><hr width='75%' />"
				dat += text("<A href='?src=\ref[];choice=Record Maintenance'>Record Maintenance</A><br><br>", src)
			if(2.0)
				dat += "<B>Records Maintenance</B><HR>"
				dat += "<BR><A href='?src=\ref[src];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=\ref[src];choice=Return'>Back</A>"
			if(3.0)
				dat += "<CENTER><B>Security Record</B></CENTER><BR>"
				if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
					dat += text("<table><tr><td>	\
					Name: <A href='?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
					ID: <A href='?src=\ref[src];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>\n \
					Sex: <A href='?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n	\
					Age: <A href='?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n	\
					Rank: <A href='?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n	\
					Physical Status: [active1.fields["p_stat"]]<BR>\n	\
					Mental Status: [active1.fields["m_stat"]]<BR></td>	\
					<td align = center valign = top>Photo:<br> \
					<table><td align = center><img src=front.png height=80 width=80 border=4><BR><A href='?src=\ref[src];choice=Edit Field;field=photo front'>Update front photo</A></td> \
					<td align = center><img src=side.png height=80 width=80 border=4><BR><A href='?src=\ref[src];choice=Edit Field;field=photo side'>Update side photo</A></td></table> \
					</td></tr></table>")
				else
					dat += "<B>General Record Lost!</B><BR>"
				if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
					dat += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=\ref[];choice=Edit Field;field=criminal'>[]</A><BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[];choice=Edit Field;field=mi_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];choice=Edit Field;field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[];choice=Edit Field;field=ma_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];choice=Edit Field;field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];choice=Edit Field;field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, active2.fields["criminal"], src, active2.fields["mi_crim"], src, active2.fields["mi_crim_d"], src, active2.fields["ma_crim"], src, active2.fields["ma_crim_d"], src, decode(active2.fields["notes"]))
					var/counter = 1
					while(active2.fields[text("com_[]", counter)])
						dat += text("[]<BR><A href='?src=\ref[];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", active2.fields[text("com_[]", counter)], src, counter)
						counter++
					dat += text("<A href='?src=\ref[];choice=Add Entry'>Add Entry</A><BR><BR>", src)
					dat += text("<A href='?src=\ref[];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR><BR>", src)
				else
					dat += "<B>Security Record Lost!</B><BR>"
					dat += text("<A href='?src=\ref[];choice=New Record (Security)'>New Security Record</A><BR><BR>", src)
				dat += text("\n<A href='?src=\ref[];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=\ref[];choice=Print Record'>Print Record</A><BR>\n<A href='?src=\ref[];choice=Return'>Back</A><BR>", src, src, src)
			if(4.0)
				if(!Perp.len)
					dat += text("ERROR.  String could not be located.<br><br><A href='?src=\ref[];choice=Return'>Back</A>", src)
				else
					dat += {"
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>					"}
					dat += text("<th>Search Results for '[]':</th>", tempname)
					dat += {"
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Criminal Status</th>
</tr>					"}
					for(var/i=1, i<=Perp.len, i += 2)
						var/crimstat = ""
						var/datum/data/record/R = Perp[i]
						if(istype(Perp[i+1],/datum/data/record/))
							var/datum/data/record/E = Perp[i+1]
							crimstat = E.fields["criminal"]
						var/background
						switch(crimstat)
							if("*Arrest*")
								background = "'background-color:#BB1133;'"
							if("Incarcerated")
								background = "'background-color:#B6732F;'"
							if("Released")
								background = "'background-color:#3BB9FF;'"
							if("None")
								background = "'background-color:#1AAFFF;'"
							if("")
								background = ""
								crimstat = "No Record."
						dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
						dat += text("<td>[]</td>", R.fields["id"])
						dat += text("<td>[]</td>", R.fields["rank"])
						dat += text("<td>[]</td></tr>", crimstat)
					dat += "</table><hr width='75%' />"
					dat += text("<br><A href='?src=\ref[];choice=Return'>Return to index.</A>", src)
			if(5)
				dat += generate_fingerprint_menu()

	show_browser(user, dat, "Security Records", "secure_rec", "size=600x400")
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/structure/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(active1) ))
		active1 = null
	if (!( data_core.security.Find(active2) ))
		active2 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (ishighersilicon(usr)))
		usr.set_interaction(src)
		switch(href_list["choice"])
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if ("Return")
				screen = 1
				active1 = null
				active2 = null

			if("read_fingerprint")
				screen = 5

			if("print_report")
				var/obj/effect/decal/prints/D = scanner.found_prints
				var/obj/item/paper/fingerprint/P = new /obj/item/paper/fingerprint(D.criminal_name, D.criminal_rank, D.criminal_rank, D.description)
				P.loc = loc
				P.name = "fingerprint report ([D.generate_clue()])"
				playsound(loc, 'sound/machines/twobeep.ogg', 15, 1)

			if("return_menu")
				screen = 1

			if("return_clear")
				qdel(scanner.found_prints)
				scanner.found_prints = null
				scanner.update_icon()
				scanner.forceMove(get_turf(src))
				scanner = null
				screen = 1

//RECORD FUNCTIONS
			if("Search Records")
				var/t1 = input("Search String: (Partial Name or ID or Rank)", "Secure. records", null, null)  as text
				if ((!t1 || usr.stat || usr.is_mob_restrained() || !in_range(src, usr)))
					return
				Perp = new/list()
				t1 = lowertext(t1)
				var/list/components = splittext(t1, " ")
				if(components.len > 5)
					return //Lets not let them search too greedily.
				for(var/datum/data/record/R in data_core.general)
					var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["rank"]
					for(var/i = 1, i<=components.len, i++)
						if(findtext(temptext,components[i]))
							var/prelist = new/list(2)
							prelist[1] = R
							Perp += prelist
				for(var/i = 1, i<=Perp.len, i+=2)
					for(var/datum/data/record/E in data_core.security)
						var/datum/data/record/R = Perp[i]
						if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
							Perp[i+1] = E
				tempname = t1
				screen = 4

			if("Record Maintenance")
				screen = 2
				active1 = null
				active2 = null

			if ("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/S = locate(href_list["d_rec"])
				if (!( data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							S = E
					active1 = R
					active2 = S
					screen = 3


			if ("Print Record")
				if (!( printing ))
					printing = 1
					var/datum/data/record/record1 = null
					var/datum/data/record/record2 = null
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						record1 = active1
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						record2 = active2
					sleep(50)
					var/obj/item/paper/P = new /obj/item/paper( loc )
					P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
					if (record1)
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", record1.fields["name"], record1.fields["id"], record1.fields["sex"], record1.fields["age"], record1.fields["p_stat"], record1.fields["m_stat"])
						P.name = text("Security Record ([])", record1.fields["name"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
						P.name = "Security Record"
					if (record2)
						P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nMajor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", record2.fields["criminal"], record2.fields["mi_crim"], record2.fields["mi_crim_d"], record2.fields["ma_crim"], record2.fields["ma_crim_d"], decode(record2.fields["notes"]))
						var/counter = 1
						while(record2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", record2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Security Record Lost!</B><BR>"
					P.info += "</TT>"
					printing = null
					updateUsrDialog()
//RECORD DELETE
			if ("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Security records?<br>"
				temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Purge All Records")
				for(var/datum/data/record/R in data_core.security)
					data_core.security -= R
					qdel(R)
				temp = "All Security records deleted."

			if ("Add Entry")
				if (!(istype(active2, /datum/data/record)))
					return
				var/a2 = active2
				var/t1 = copytext(trim(strip_html(input("Add Comment:", "Secure. records", null, null)  as message)),1,MAX_MESSAGE_LEN)
				if ((!t1 || usr.stat || usr.is_mob_restrained() || (!in_range(src, usr) && (!ishighersilicon(usr))) || active2 != a2))
					return
				var/counter = 1
				while(active2.fields[text("com_[]", counter)])
					counter++

			if ("Delete Record (ALL)")
				if (active1)
					temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Delete Record (Security)")
				if (active2)
					temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (Security) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Delete Entry")
				if ((istype(active2, /datum/data/record) && active2.fields[text("com_[]", href_list["del_c"])]))
					active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
//RECORD CREATE
			if ("New Record (Security)")
				if ((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
					active2 = CreateSecurityRecord(active1.fields["name"], active1.fields["id"])
					screen = 3

			if ("New Record (General)")
				active1 = CreateGeneralRecord()
				active2 = null

//FIELD FUNCTIONS
			if ("Edit Field")
				if (is_not_allowed(usr))
					return
				var/a1 = active1
				var/a2 = active2
				switch(href_list["field"])
					if("name")
						if (istype(active1, /datum/data/record))
							var/t1 = reject_bad_name(input(usr, "Please input name:", "Secure. records", active1.fields["name"]) as text|null)
							if (!t1 || active1 != a1)
								return
							active1.fields["name"] = t1
					if("id")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(trim(strip_html(input("Please input id:", "Secure. records", active1.fields["id"], null)  as text)),1,MAX_MESSAGE_LEN)
							if (!t1 || active1 != a1)
								return
							active1.fields["id"] = t1
					if("sex")
						if (istype(active1, /datum/data/record))
							if (active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if (istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
							if (!t1 || active1 != a1)
								return
							active1.fields["age"] = t1
					if("mi_crim")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(trim(strip_html(input("Please input minor disabilities list:", "Secure. records", active2.fields["mi_crim"], null)  as text)),1,MAX_MESSAGE_LEN)
							if (!t1 || active2 != a2)
								return
							active2.fields["mi_crim"] = t1
					if("mi_crim_d")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(trim(strip_html(input("Please summarize minor dis.:", "Secure. records", active2.fields["mi_crim_d"], null)  as message)),1,MAX_MESSAGE_LEN)
							if (!t1 || active2 != a2)
								return
							active2.fields["mi_crim_d"] = t1
					if("ma_crim")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(trim(strip_html(input("Please input major diabilities list:", "Secure. records", active2.fields["ma_crim"], null)  as text)),1,MAX_MESSAGE_LEN)
							if (!t1 || active2 != a2)
								return
							active2.fields["ma_crim"] = t1
					if("ma_crim_d")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(trim(strip_html(input("Please summarize major dis.:", "Secure. records", active2.fields["ma_crim_d"], null)  as message)),1,MAX_MESSAGE_LEN)
							if (!t1 || active2 != a2)
								return
							active2.fields["ma_crim_d"] = t1
					if("notes")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(html_encode(trim(input("Please summarize notes:", "Secure. records", html_decode(active2.fields["notes"]), null)  as message)),1,MAX_MESSAGE_LEN)
							if (!t1 || active2 != a2)
								return
							active2.fields["notes"] = t1
					if("criminal")
						if (istype(active2, /datum/data/record))
							temp = "<h5>Criminal Status:</h5>"
							temp += "<ul>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=none'>None</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=released'>Released</a></li>"
							temp += "</ul>"
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if ((istype(active1, /datum/data/record) && L.Find(rank)))
							temp = "<h5>Rank:</h5>"
							temp += "<ul>"
							for(var/rank in joblist)
								temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
					if("species")
						if (istype(active1, /datum/data/record))
							var/t1 = copytext(trim(strip_html(input("Please enter race:", "General records", active1.fields["species"], null)  as message)),1,MAX_MESSAGE_LEN)
							if (!t1 || active1 != a1)
								return
							active1.fields["species"] = t1


//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if ("Change Rank")
						if (active1)
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in joblist)
								active1.fields["real_rank"] = href_list["real_rank"]

					if ("Change Criminal Status")
						if (active2)
							switch(href_list["criminal2"])
								if("none")
									active2.fields["criminal"] = "None"
								if("arrest")
									active2.fields["criminal"] = "*Arrest*"
								if("incarcerated")
									active2.fields["criminal"] = "Incarcerated"
								if("released")
									active2.fields["criminal"] = "Released"

							for(var/mob/living/carbon/human/H in mob_list)
								H.sec_hud_set_security_status()

					if ("Delete Record (Security) Execute")
						if (active2)
							qdel(active2)
							active2 = null

					if ("Delete Record (ALL) Execute")
						if (active1)
							for(var/datum/data/record/R in data_core.medical)
								if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									data_core.medical -= R
									qdel(R)
								else
							qdel(active1)
							active1 = null
						if (active2)
							qdel(active2)
							active2 = null
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/structure/machinery/computer/secure_data/proc/generate_fingerprint_menu()
	var/dat = ""

	dat += "<table><tr><td>"
	dat += "Name: [scanner.found_prints.criminal_name]<BR>"
	if(scanner.found_prints.criminal_squad)
		dat += "Squad: [scanner.found_prints.criminal_squad]<BR>"
	if(scanner.found_prints.criminal_rank)
		dat += "Rank: [scanner.found_prints.criminal_rank]<BR>"
	dat += "Description: [scanner.found_prints.description]<BR>"
	dat += "</td></tr></table>"

	dat += "<a href='?src=\ref[src];choice=print_report'>Print Evidence</a><BR>"
	dat += "<a href='?src=\ref[src];choice=return_menu'>Return</a><BR>"
	dat += "<a href='?src=\ref[src];choice=return_clear'>Clear Print and Return</a>"
	
	return dat

/obj/structure/machinery/computer/secure_data/proc/is_not_allowed(var/mob/user)
	return user.stat || user.is_mob_restrained() || (!in_range(src, user) && (!ishighersilicon(user)))

/obj/structure/machinery/computer/secure_data/proc/get_photo(var/mob/user)
	if(istype(user.get_active_hand(), /obj/item/photo))
		var/obj/item/photo/photo = user.get_active_hand()
		return photo.img
	if(ishighersilicon(user))
		var/mob/living/silicon/tempAI = usr
		var/datum/picture/selection = tempAI.GetPicture()
		if (selection)
			return selection.fields["img"]

/obj/structure/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			data_core.security -= R
			qdel(R)
			continue

	..(severity)

/obj/structure/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "messyfiles"