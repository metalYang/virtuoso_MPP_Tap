;----------;----------;
;1.工艺规则变量化
	;
;2.增加UI交互
	;
;3.兼容IC51
	;
;----------2019-11-14----------;
;1.可选掺杂类型等√
	;"P"为PSD;"N"为NSD;"NW"为NW;	
;2.掺杂切换参数输入类型同兼容symbol和string类型√
	;可以输入"P",也可以输入'P;	
;3.命令模式下自动识别输入参数为contact排数还是DIFF宽度√
	;输入整数位contact排数;输入浮点数为DIFF宽度,单位um;	
;4.增加规则切换√
	;默认匹配4x4阵列contact的规则;输入"min"或'min则在小于4排孔的时候使用最小规则;	
;5.MPP模板自动命名√
	;模板命名格式为"掺杂类型_Tap_contact排数row或DIFF宽度um"_规则;	
;----------;----------;

procedure(MPP()
	prog((DIFF_type arg_input rule)
		hiCreateAppForm(
			?name 'MPP_UI
			?fields list(
						hiCreateCyclicField(
							?name 'DIFF_type
							?prompt "DIFF type"
							?choices list("P" "N" "NW")
						)
					
						hiCreateFloatField(
							?name 'arg_input
							?prompt "Arg input"
							?value 0.5
						)
	
						hiCreateCyclicField(
							?name 'rule
							?prompt "Rule options"
							?choices list("min" "max")
						)
					)
			?formTitle "Create MPP Template"
		)

		hiDisplayForm('MPP_UI)
		DIFF_type = MPP_UI -> DIFF_type -> value
		arg_input = MPP_UI -> arg_input -> value
		rule = MPP_UI -> rule -> value

;		return(list(DIFF_type arg_input rule))
		
		create_MPP(DIFF_type arg_input rule)
	)
)

procedure(create_MPP(DIFF_type arg_input @rest rule)
	prog((techID tech_lib contact_row contact_list DIFF_width enc_sub_list contacts_type)
		
		;CONTACT = ""
		;DIFF = ""
		;PPLUS = ""
		;NPLUS = ""
		;NWELL = ""
		;CONTACT_width = 
		;CONTACT_space_min = 
		;CONTACT_space_max = 
		;CONTACT_enclosure_DIFF = 
		;DIFF_enclosure_PLUS = 
		;DIFF_enclosure_NWELL = 
		;CONTACT_enclosure_METAL = CONTACT_enclosure_DIFF
		;DIFF_enclosure_PPLUS = DIFF_enclosure_PLUS
		;DIFF_enclosure_NPLUS = DIFF_enclosure_PLUS
		
		
		tech_lib = "hl110lpf"
		techID = techGetTechFile(ddGetObj(tech_lib))
		if(techID == nil then
			println("error!_tech_lib_")
			return(nil)
		)
		
		if(rule == nil then
			rule = "max"
			else
				rule = car(rule)
		)
		
		sprintf(DIFF_type "%s" DIFF_type)
		sprintf(rule "%s" rule)
		sprintf(arg_input_type "%s" type(arg_input))
		
		cond(
			(arg_input_type == "fixnum"
				contact_row = arg_input
				DIFF_width = cadr(contact_DIFF_width_list_func(contact_row rule))
				MPP_name = strcat(DIFF_type "_Tap_" sprintf(nil "%d" contact_row) "_row")
			)
			(arg_input_type == "flonum"
				DIFF_width = arg_input
				cond(rule == "min"
					(
					contact_row = fix((DIFF_width + 0.162 - 0.126)/(0.162 + 0.144))
					)
				)
				contact_row = fix((DIFF_width + 0.18 - 0.126)/(0.18 + 0.144))
				MPP_name = strcat(DIFF_type "_Tap_" sprintf(nil "%f" DIFF_width) "_um")
			)
			(t
				println("error!_arg_input_type_")
				return(nil)
			)
		)
		
		
		contact_list = car(contact_DIFF_width_list_func(contact_row rule))
		enc_sub_list = enc_sub_list_func(DIFF_type)
		
		create_MPP_Template(techID MPP_name DIFF_width enc_sub_list contact_list)
		
		leRodMppForm ~> rodMPPTemplate ~> value = MPP_name
		leSetEntryLayer(list("DIFF" "drawing"))
		lxHiCreateMPP()
	);prog
);procedure(create_MPP)

procedure(contact_row(row_sep)
	list(
		?layer	 list("CONT" "drawing")
		?width	 0.144000
		?length	 0.144000
		?choppable	 t
		?sep	 row_sep
		?justification	 "center"
		?space	 0.18
		?beginOffset	 -0.090000
		?endOffset	 -0.090000
		?beginSegOffset	 0.090000
		?endSegOffset	 0.090000
		?gap	 "distribute"
	)
)

procedure(enc_sub_layer(layer enc_space)
	list(
		?layer	 list(layer "drawing")
		?enclosure	 -enc_space
		?choppable	 t
		?beginOffset	 enc_space
		?endOffset	 enc_space
	)
)

procedure(contact_DIFF_width_list_func(contact_row rule)
	prog((cpoy_row contact_list DIFF_width)
		cond(
			(contact_row == 0 
				println("error!_contacts_value_")
				return(nil)
			)
			
			(rule == "min"
				cond(
					(contact_row == 1
						contact_list = list(contact_row(0))
						DIFF_width = 0.27
					)
					(contact_row == 2
						contact_list = list(contact_row(0.153) contact_row(-0.153))
						DIFF_width = 0.576
					)
					(contact_row == 3
						contact_list = list(contact_row(0) contact_row(0.306) contact_row(-0.306))
						DIFF_width = 0.882
					)
				)
			)
			
			(remainder(contact_row 2) == 0
				contact_list = list()
				cpoy_row = contact_row / 2
				DIFF_width = 0.18 * (contact_row-1) + 0.144 * contact_row + 0.126
				for(step 1 cpoy_row
					contact_list = append(contact_list list(contact_row(0.162 * (1 - (2 * step)))))
					contact_list = append(contact_list list(contact_row(0.162 * ((2 * step) - 1))))
				)
			)
			
			(remainder(contact_row 2) == 1
				contact_list = list(contact_row(0))
				cpoy_row = (contact_row - 1) / 2
				DIFF_width = 0.18 * (contact_row-1) + 0.144 * contact_row + 0.126
				for(step 1 cpoy_row
					contact_list = append(contact_list list(contact_row(0.324 * step)))
					contact_list = append(contact_list list(contact_row(-0.324 * step)))
				)
			)
			
			(t
				println("error!_contact_list_")
				return(nil)
			)
		)
		return(list(contact_list DIFF_width))
	);prog
);contact_DIFF_width_list_func

procedure(enc_sub_list_func(DIFF_type)
	prog((enc_sub_layer enc_sub_layer)
		cond(
			(DIFF_type == "P"
				enc_sub_list = list(enc_sub_layer("PSD" 0.027))				
			)
			(DIFF_type == "N"
				enc_sub_list = list(enc_sub_layer("NSD" 0.027))
			)
			
			(DIFF_type == "NW"
				enc_sub_list = list(enc_sub_layer("NSD" 0.027) enc_sub_layer("NW" 0.234))
			)
			
			(t
				println("error!_DIFF_type_")
			)
		)
		return(enc_sub_list)
	)
)

procedure(create_MPP_Template(techID MPP_name DIFF_width enc_sub_list contact_list)
	prog(()
		leDefineMPPTemplate(
			?techId	 techID
			?name	 MPP_name
			?layer	 list("DIFF" "drawing")
			?width	 DIFF_width
			?choppable	 nil
			?endType	 "truncate"
			?beginExt	 0.000000
			?endExt	 0.000000
			?justification	 "center"
			?offset	 0.000000
			?offsetSubPath	 list(
			list(
				?layer	 list("M1" "drawing")
				?width	 DIFF_width
				?choppable	 t
				?sep	 0.000000
				?justification	 "center"
				?beginOffset	 0.000000
				?endOffset	 0.000000
				)
			)
			?encSubPath
				enc_sub_list
				
			?subRect
				contact_list
				
		); end of leDefineMPPTemplate procedure
	)
)
