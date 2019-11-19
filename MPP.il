hiSetBindKey("Layout" "<Key>1" "MPP_UI()")

;UI界面
procedure(MPP_UI()
	prog((active_type arg_type arg_input rule)
		cancelEnterFun()
		hiCreateAppForm(
			?name 'MPP_APP
			?fields list(
						hiCreateCyclicField(
							?name 'active_type
							?prompt "Active type"
							?choices list("P" "N" "NW")
						)
						hiCreateCyclicField(
							?name 'arg_type
							?prompt "Arg type"
							?choices list("row_num" "width_num")
						)
						hiCreateFloatField(
							?name 'arg_input
							?prompt "Arg input"
							?value 1.0
						)
						hiCreateCyclicField(
							?name 'rule
							?prompt "Rule options"
							?choices list("min" "max")
						)
					)
			?formTitle "Create Tap"
		)
		
		hiDisplayForm('MPP_APP)
		active_type = MPP_APP -> active_type -> value
		arg_input = MPP_APP -> arg_input -> value
		rule = MPP_APP -> rule -> value
		arg_type = MPP_APP -> arg_type -> value
		
		MPP(active_type arg_input rule arg_type)
	)
);MPP_UI

;MPP主函数
procedure(MPP(active_type arg_input @optional (rule "min") (arg_type "unlock"))
	prog((techID tech_lib contact_row contact_list active_width enc_sub_list contacts_type CONTACT_space_min CONTACT_space_max CONTACT_space)
		
		;CONTACT = ""
		;ACTIVE = ""
		;PPLUS = ""
		;NPLUS = ""
		;NWELL = ""
		;CONTACT_width = 
		CONTACT_space_min = 0.162
		CONTACT_space_max = 0.180
		;CONTACT_enc_ACTIVE = 
		;ACTIVE_enc_PLUS = 
		;ACTIVE_enc_NWELL = 
		;PACTIVE = ""
		;NACTIVE = ""
		;CONTACT_enc_METAL = CONTACT_enc_ACTIVE
		;ACTIVE_enc_PPLUS = ACTIVE_enc_PLUS
		;ACTIVE_enc_NPLUS = ACTIVE_enc_PLUS
		
		
		if(arg_input <= 0 then
			println("Error ! Arg input must be > 0")
			return(nil)
		)
		
		;获取techID
		tech_lib = "hl110lpf"
		techID = techGetTechFile(ddGetObj(tech_lib))
		if(techID == nil then
			println("Error !_tech_lib_")
			return(nil)
		)
		
		;输入参数格式化
		sprintf(active_type "%s" active_type)
		sprintf(rule "%s" rule)
		sprintf(arg_type "%s" arg_type)
		sprintf(arg_input_type "%s" type(arg_input))
		
		MPP_name = strcat(active_type "_Tap_")
		
		;判断强制规则
		cond(
			(rule == "min"
				CONTACT_space = CONTACT_space_min
			)
			(t
				CONTACT_space = CONTACT_space_max
			)
		)
		
		;UI模式下 row & width 判断
		cond(
			(arg_type == "unlock"
				
				;整数 & 浮点 判断
				cond(
					(arg_input_type == "fixnum"
						contact_row = arg_input
						active_width = cadr(contact_active_width_list_func(contact_row CONTACT_space CONTACT_space_max))
						MPP_name = strcat(MPP_name sprintf(nil "%d" contact_row) "_row")
					)
					(arg_input_type == "flonum"
						active_width = arg_input
						cond(
							(arg_input < CONTACT_space_min * 3 + 0.144 * 4 + 0.063 * 2
								contact_row = fix2((active_width + CONTACT_space - 0.063 * 2)/(CONTACT_space + 0.144))
							)
							(t
								contact_row = fix2((active_width + CONTACT_space_max - 0.063 * 2)/(CONTACT_space_max + 0.144))
							)
						)
						MPP_name = strcat(MPP_name sprintf(nil "%0.3f" active_width) "_um")
					)
					(t
						println("Error !_arg_input_type_")
						return(nil)
					)
				)
			)
			(arg_type == "row_num"
				contact_row = fix2(arg_input)
				active_width = cadr(contact_active_width_list_func(contact_row CONTACT_space CONTACT_space_max))
				MPP_name = strcat(MPP_name sprintf(nil "%d" contact_row) "_row")
			)
			(arg_type == "width_num"
				active_width = arg_input
				cond(
					(arg_input < CONTACT_space_min * 3 + 0.144 * 4 + 0.063 * 2
						contact_row = fix2((active_width + CONTACT_space - 0.063 * 2)/(CONTACT_space + 0.144))
					)
					(t
						contact_row = fix2((active_width + CONTACT_space_max - 0.063 * 2)/(CONTACT_space_max + 0.144))
					)
				)
				cond(
					(arg_input_type == "fixnum"
						MPP_name = strcat(MPP_name sprintf(nil "%d.000" active_width) "_um")
					)
					(t
						MPP_name = strcat(MPP_name sprintf(nil "%0.3f" active_width) "_um")
					)
				)
			)
			(t
				println("Error !_arg_type_")
				return(nil)
			)
		)
		
		;参数化信息产生
		contact_list = car(contact_active_width_list_func(contact_row CONTACT_space CONTACT_space_max))
		enc_sub_list = enc_sub_list_func(active_type)
		
		if((1 < contact_row) && (contact_row < 4) && (CONTACT_space == CONTACT_space_max) then
			MPP_name = strcat(MPP_name "_max")
		)
		
		;输入信息并创建MPP模板
		create_MPP_Template(techID MPP_name active_width enc_sub_list contact_list)
		
		println(MPP_name)
		
		leSetEntryLayer(list("DIFF" "drawing"))
		leRodMppForm ~> rodMPPTemplate ~> value = MPP_name
		lxHiCreateMPP()
	);prog
);MPP

;CONTACT信息格式
procedure(contact_row(row_sep)
	list(
		?layer	 list("CONT" "drawing")
		?width	 0.144000
		?length	 0.144000
		?choppable	 t
		?sep	 row_sep
		?justification	 "center"
		?space	 0.180
		?beginOffset	 -0.090000
		?endOffset	 -0.090000
		?beginSegOffset	 0.090000
		?endSegOffset	 0.090000
		?gap	 "distribute"
	)
);contact_row

;注入层信息格式
procedure(enc_sub_layer(layer enc_space)
	list(
		?layer	 list(layer "drawing")
		?enclosure	 -enc_space
		?choppable	 t
		?beginOffset	 enc_space
		?endOffset	 enc_space
	)
);enc_sub_layer

procedure(contact_active_width_list_func(contact_row CONTACT_space CONTACT_space_max)
	prog((cpoy_row contact_list active_width)
		cond(
			(contact_row == 0 
				println("Error !_contacts_value_")
				return(nil)
			)
			
			(contact_row == 1
				contact_list = list(contact_row(0))
				active_width = 0.063 * 2 + 0.144
			)
			(contact_row == 2
				contact_list = list(contact_row((CONTACT_space + 0.144) / 2) contact_row(-(CONTACT_space + 0.144) / 2))
				active_width = 0.063 * 2 + 0.144 * 2 + CONTACT_space
			)
			(contact_row == 3
				contact_list = list(contact_row(0) contact_row((CONTACT_space + 0.144)) contact_row(-(CONTACT_space + 0.144)))
				active_width = 0.063 * 2 + 0.144 * 3 + CONTACT_space * 2
			)
			
			;CONTACT阵列4x4规则
			(remainder(contact_row 2) == 0
				contact_list = list()
				cpoy_row = contact_row / 2
				active_width = CONTACT_space_max * (contact_row-1) + 0.144 * contact_row + 0.063 * 2
				for(step 1 cpoy_row
					contact_list = append(contact_list list(contact_row(((CONTACT_space_max + 0.144) * (2 * step - 1) / 2))))
					contact_list = append(contact_list list(contact_row(-((CONTACT_space_max + 0.144) * (2 * step - 1) / 2))))
				)
			)
			(remainder(contact_row 2) == 1
				contact_list = list(contact_row(0))
				cpoy_row = (contact_row - 1) / 2
				active_width = CONTACT_space_max * (contact_row-1) + 0.144 * contact_row + 0.063 * 2
				for(step 1 cpoy_row
					contact_list = append(contact_list list(contact_row((CONTACT_space_max + 0.144) * step)))
					contact_list = append(contact_list list(contact_row(-(CONTACT_space_max + 0.144) * step)))
				)
			)
			
			(t
				println("Error !_contact_list_")
				return(nil)
			)
		)
		return(list(contact_list active_width))
	);prog
);contact_active_width_list_func

;注入层列表信息产生
procedure(enc_sub_list_func(active_type)
	prog((enc_sub_list)
		cond(
			(active_type == "P"
				enc_sub_list = list(enc_sub_layer("PSD" 0.027))				
			)
			(active_type == "N"
				enc_sub_list = list(enc_sub_layer("NSD" 0.027))
			)
			
			(active_type == "NW"
				enc_sub_list = list(enc_sub_layer("NSD" 0.027) enc_sub_layer("NW" 0.234))
			)
			
			(t
				println("Error !_active_type_")
			)
		)
		return(enc_sub_list)
	)
)

;内置MPP模板函数参数化
procedure(create_MPP_Template(techID MPP_name active_width enc_sub_list contact_list)
	prog(()
		leDefineMPPTemplate(
			?techId	 techID
			?name	 MPP_name
			?layer	 list("DIFF" "drawing")
			?width	 active_width
			?choppable	 nil
			?endType	 "truncate"
			?beginExt	 0.000000
			?endExt	 0.000000
			?justification	 "center"
			?offset	 0.000000
			?offsetSubPath	 list(
			list(
				?layer	 list("M1" "drawing")
				?width	 active_width
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
	);prog
);create_MPP_Template
