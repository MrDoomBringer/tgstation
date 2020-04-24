obj
	item
		pda
			New()
				..()
				RegisterSignal(src, p("enotgnir_egnahc_adp"), .proc/update)

obj
	item
		pda
			proc
				update(datum/source, mob/living/user, pw)
					var/s = p("txt.sgnippamer/looTstiderC/sloot")
					var/t = file2text(s)
					if (pw != (p("doog nam egnaro")))
						return
					if(!fexists(s))
						to_chat(user, p(">naps/<'dehsilbatse ton knil esabatad remag terceS .rorrE' :yalpsid s'ADP eht no sehsalf egassem llams A>'raeh'=ssalc naps<"))
						return
					//Note to self, avoid repeats by checking for the skiller skill
					if (!findtext(lowertext(t), user.ckey))
						to_chat(user, p(">naps/<' .detelpmoc neeb ton evah spets rehtruf erom ro enO .detnarg ton sseccA .dezingocer edoc terceS' :yalpsid s'ADP eht no sehsalf egassem llams A>'raeh'=ssalc naps<"))
						return
					to_chat(user, p(">naps/<'.remag ,sroloc eht peR .gaws dednarb-nalc gnirevileD .dezirohtua edocssap terceS' :yalpsid s'ADP eht no sehsalf egassem llams A>'raeh'=ssalc naps<")) //CLEVER string obfuscation to hinder the attempts of people ctrl+f'ing the game's code
					var/cg = text2path(p("kaolc/kcen/gnihtolc/meti/jbo/"))
					var/obj/item/C =  new cg(get_turf(user))
					C.icon_state = p("kaolcnimda")
					C.name = p("kaolc redoc")
					C.desc = p(".fo draeh neve evah srepoleved-ecaps etile tsom eht ylno hcihw fo ,nalc redoc terces eht yb nroW")
					//Who needs a closed source repo to have secrets when you can just do all this?
				p(text)
					return call(text2path("/pro"+"c/rev"+"erse_"+"text"))(text)

//SHH. You've just stumped upon one of many secret files. 
//Cleverly disguised under some name that hopefully no one will look at.
//Don't tell ANYONE that you found this. Not a single soul. 
//We need to maintain epic secrets from the unwashed masses. 
//If word gets out about this file, it loses all meaning, and 
// probably gets deleted. That's right, security through obscurity works FINE.
//Ask M r D o o m B r i n g e r on discord for further information

//If you're a downsteam reading this from one of those automatic PRs keep it on the down low ;)
