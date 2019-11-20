;键位设置
hiSetBindKey("Layout" "<Key>1" "MPP_UI()")

;MPP主函数
procedure(MPP(active_type arg_input @optional (rule "min") (arg_type "unlock"))
	prog((techID contact_row contact_list active_width enc_sub_list contacts_type CONTACT_space
			tech_lib
			CONTACT ACTIVE PPLUS NPLUS NWELL METAL PACTIVE NACTIVE
			CONTACT_width CONTACT_space_min CONTACT_space_max
			CONTACT_enc_ACTIVE ACTIVE_enc_PLUS ACTIVE_enc_NWELL ACTIVE_enc_PPLUS ACTIVE_enc_NPLUS)
			
			
	/*--------------------*/  
	/**/	tech_lib = ""
	/*--------------------*/  
	/**/	CONTACT = ""
	/**/	PACTIVE = ""
	/**/	NACTIVE = ""
	/**/	PPLUS = ""
	/**/	NPLUS = ""
	/**/	NWELL = ""
	/**/	METAL = ""
	/*--------------------*/  
	/**/	CONTACT_width = 0.000
	/**/	CONTACT_space_min = 0.000
	/**/	CONTACT_space_max = 0.000
	/**/	CONTACT_enc_ACTIVE = 0.000
	/**/	ACTIVE_enc_PLUS = 0.000
	/**/	ACTIVE_enc_NWELL = 0.000
	/**/	ACTIVE_enc_PPLUS = ACTIVE_enc_PLUS
	/**/	ACTIVE_enc_NPLUS = ACTIVE_enc_PLUS
	/*--------------------*/  
		
		
		;输入参数格式化
		sprintf(active_type "%s" active_type)
		sprintf(rule "%s" rule)
		sprintf(arg_type "%s" arg_type)
		sprintf(arg_input_type "%s" type(arg_input))
		
		
		if(arg_input <= 0 then
			println("*Error* ! Arg input must be > 0")
			return(nil)
		)
		
		;获取techID
		techID = techGetTechFile(ddGetObj(tech_lib))
		if(techID == nil then
			println("*Error* ! Check techlib ")
			return(nil)
		)
		
		MPP_name = strcat(active_type "-Tap_")
		
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
						active_width = cadr(contact_list_active_width_func(contact_row CONTACT_space))
						MPP_name = strcat(MPP_name sprintf(nil "%d" contact_row) "_row")
					)
					(arg_input_type == "flonum"
						active_width = arg_input
						cond(
							(active_width < CONTACT_width + CONTACT_enc_ACTIVE * 2
								println(strcat("*Error* ! Active width must be >= " sprintf(nil "%0.3f um" CONTACT_width + CONTACT_enc_ACTIVE * 2)))
								return(nil)
							)
							(active_width < CONTACT_space_min * 3 + CONTACT_width * 4 + CONTACT_enc_ACTIVE * 2
								contact_row = fix2((active_width + CONTACT_space - CONTACT_enc_ACTIVE * 2)/(CONTACT_space + CONTACT_width))
							)
							(t
								contact_row = fix2((active_width + CONTACT_space_max - CONTACT_enc_ACTIVE * 2)/(CONTACT_space_max + CONTACT_width))
							)
						)
						MPP_name = strcat(MPP_name sprintf(nil "%0.3f" active_width) "_um")
					)
					(t
						println("*Error* !_arg_input_type_")
						return(nil)
					)
				)
			)
			(arg_type == "rownum"
				contact_row = fix2(arg_input)
				if(contact_row == 0 then
					println("*Error* ! Contact rownum must be > 0")
					return(nil)
				)
				active_width = cadr(contact_list_active_width_func(contact_row CONTACT_space))
				MPP_name = strcat(MPP_name sprintf(nil "%d" contact_row) "_row")
			)
			(arg_type == "widthnum"
				active_width = arg_input
				cond(
					(active_width < CONTACT_width + CONTACT_enc_ACTIVE * 2
						println(strcat("*Error* ! Active width must be >= " sprintf(nil "%0.3f um" CONTACT_width + CONTACT_enc_ACTIVE * 2)))
						return(nil)
					)
					(active_width < CONTACT_space_min * 3 + CONTACT_width * 4 + CONTACT_enc_ACTIVE * 2
						contact_row = fix2((active_width + CONTACT_space - CONTACT_enc_ACTIVE * 2)/(CONTACT_space + CONTACT_width))
					)
					(t
						contact_row = fix2((active_width + CONTACT_space_max - CONTACT_enc_ACTIVE * 2)/(CONTACT_space_max + CONTACT_width))
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
				println("*Error* !_arg_type_")
				return(nil)
			)
		)
		
		;参数化信息产生
		contact_list = car(contact_list_active_width_func(contact_row CONTACT_space))
		enc_sub_list = car(enc_sub_list_func(active_type))
		ACTIVE = cadr(enc_sub_list_func(active_type))
		
		if((1 < contact_row) && (contact_row < 4) && (CONTACT_space == CONTACT_space_max) then
			MPP_name = strcat(MPP_name "_max")
		)
		
		;输入信息并创建MPP模板
		create_MPP_Template(MPP_name ACTIVE active_width enc_sub_list contact_list)
		
		println(MPP_name)
		
		leSetEntryLayer(list(ACTIVE "drawing"))
		leRodMppForm ~> rodMPPTemplate ~> value = MPP_name
		lxHiCreateMPP()
	);prog
);MPP

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
							?choices list("rownum" "widthnum")
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

;单排CONTACT
procedure(subRect_func(row_sep @optional (layer CONTACT) (CONTACT_width CONTACT_width) (space CONTACT_space_max))
	list(
		?layer	 list(layer "drawing")
		?width	 CONTACT_width
		?length	 CONTACT_width
		?choppable	 t
		?sep	 row_sep
		?justification	 "center"
		?space	 space
		?beginOffset	 -space / 2
		?endOffset	 -space / 2
		?beginSegOffset	 space / 2
		?endSegOffset	 space / 2
		?gap	 "distribute"
	)
);subRect_func

;单层注入
procedure(encSubPath_func(enc_space layer)
	list(
		?layer	 list(layer "drawing")
		?enclosure	 -enc_space
		?choppable	 t
		?beginOffset	 enc_space
		?endOffset	 enc_space
	)
);encSubPath_func

;同时输出CONTACT数据和ACTIVE宽度
procedure(contact_list_active_width_func(contact_row CONTACT_space @optional (CONTACT CONTACT) (CONTACT_width CONTACT_width) (CONTACT_space_max CONTACT_space_max) (CONTACT_enc_ACTIVE CONTACT_enc_ACTIVE) (CONTACT_width CONTACT_width))
	prog((cpoy_row contact_list active_width)
		cond(
			
			(contact_row == 1
				contact_list = list(subRect_func(0))
				active_width = CONTACT_enc_ACTIVE * 2 + CONTACT_width
			)
			(contact_row == 2
				contact_list = list(subRect_func((CONTACT_space + CONTACT_width) / 2) subRect_func(-(CONTACT_space + CONTACT_width) / 2))
				active_width = CONTACT_enc_ACTIVE * 2 + CONTACT_width * 2 + CONTACT_space
			)
			(contact_row == 3
				contact_list = list(subRect_func(0) subRect_func((CONTACT_space + CONTACT_width)) subRect_func(-(CONTACT_space + CONTACT_width)))
				active_width = CONTACT_enc_ACTIVE * 2 + CONTACT_width * 3 + CONTACT_space * 2
			)
			
			;CONTACT阵列4x4规则
			(remainder(contact_row 2) == 0
				contact_list = nil
				cpoy_row = contact_row / 2
				active_width = CONTACT_space_max * (contact_row - 1) + CONTACT_width * contact_row + CONTACT_enc_ACTIVE * 2
				for(step 1 cpoy_row
					contact_list = append(contact_list list(subRect_func(((CONTACT_space_max + CONTACT_width) * (2 * step - 1) / 2))))
					contact_list = append(contact_list list(subRect_func(-((CONTACT_space_max + CONTACT_width) * (2 * step - 1) / 2))))
				)
			)
			(remainder(contact_row 2) == 1
				contact_list = list(subRect_func(0))
				cpoy_row = (contact_row - 1) / 2
				active_width = CONTACT_space_max * (contact_row - 1) + CONTACT_width * contact_row + CONTACT_enc_ACTIVE * 2
				for(step 1 cpoy_row
					contact_list = append(contact_list list(subRect_func((CONTACT_space_max + CONTACT_width) * step)))
					contact_list = append(contact_list list(subRect_func(-(CONTACT_space_max + CONTACT_width) * step)))
				)
			)
			
			(t
				println("*Error* !_contact_list_")
				return(nil)
			)
		)
		return(list(contact_list active_width))
	);prog
);contact_list_active_width_func

;同时输出注入层数据和ACTIVE层类型
procedure(enc_sub_list_func(active_type @optional (PACTIVE PACTIVE) (NACTIVE NACTIVE) (PPLUS PPLUS) (NPLUS NPLUS) (NWELL NWELL) (ACTIVE_enc_PPLUS ACTIVE_enc_PPLUS) (ACTIVE_enc_NPLUS ACTIVE_enc_NPLUS) (ACTIVE_enc_NWELL ACTIVE_enc_NWELL))
	prog((enc_sub_list ACTIVE)
		cond(
			(active_type == "P"
				enc_sub_list = list(encSubPath_func(ACTIVE_enc_PPLUS PPLUS))
				ACTIVE = PACTIVE
			)
			(active_type == "N"
				enc_sub_list = list(encSubPath_func(ACTIVE_enc_NPLUS NPLUS))
				ACTIVE = NACTIVE
			)
			(active_type == "NW"
				enc_sub_list = list(encSubPath_func(ACTIVE_enc_NPLUS NPLUS) encSubPath_func(ACTIVE_enc_NWELL NWELL))
				ACTIVE = NACTIVE
			)
			(t
				println("*Error* !_active_type_")
			)
		)
		return(list(enc_sub_list ACTIVE))
	)
)

;内置MPP模板函数参数化
procedure(create_MPP_Template(MPP_name ACTIVE active_width enc_sub_list contact_row_list @optional (techID techID) (METAL METAL))
	prog(()
		leDefineMPPTemplate(
			?techId	 techID
			?name	 MPP_name
			?layer	 list(ACTIVE "drawing")
			?width	 active_width
			?choppable	 nil
			?endType	 "truncate"
			?beginExt	 0.000000
			?endExt	 0.000000
			?justification	 "center"
			?offset	 0.000000
			?offsetSubPath	 list(
			list(
				?layer	 list(METAL "drawing")
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
				contact_row_list
				
		); end of leDefineMPPTemplate procedure
	);prog
);create_MPP_Template
