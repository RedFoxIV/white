
/datum/gear/roles
	sort_category = "Роли"
	var/job_path = null

/datum/gear/roles/purchase(client/C)
	C?.prefs?.jobs_buyed += job_path
	C?.prefs?.save_preferences()
	return TRUE

/datum/gear/roles/mechanic
	display_name = "Механик"
	description = "Занимается исключительно улучшением всего и вся на станции. Имеет RPED с компонентами."
	cost = 1500
	job_path = /datum/job/station_engineer/mechanic

/datum/gear/roles/field_medic
	display_name = "Полевой медик"
	description = "Имеет имплантер для слежки за заключёнными/офицерами и набор инструментов. Он обязательно их спасёт."
	cost = 2000
	job_path = /datum/job/doctor/field_medic

/datum/gear/roles/bomj
	display_name = "Бомж"
	description = "Просто бомж."
	cost = 50
	job_path = /datum/job/bomj

/datum/gear/roles/exploration
	display_name = "Рейнджер"
	description = "Храбрый исследователь космоса."
	cost = 4000
	job_path = /datum/job/exploration

/datum/gear/roles/hunter
	display_name = "Охотник"
	description = "Опытный боец с неплохим снаряжением, специализируется на истреблении фауны в экстремальных условиях. Имеет запас шахтёрских очков для быстрого старта."
	cost = 6000
	job_path = /datum/job/hunter
