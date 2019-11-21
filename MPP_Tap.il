;键位设置
hiSetBindKey("Layout" "<Key>1" "MPP_UI()")

;MPP主函数
procedure(MPP(active_type arg_input @optional (rule "min") (arg_type "unlock"))
	prog((techID contact_row contact_list active_width enc_sub_list contacts_type CONTACT_space
		tech_lib
		CONTACT ACTIVE PPLUS NPLUS NWELL METAL PACTIVE NACTIVE
		CONTACT_width CONTACT_space_min CONTACT_space_max
		CONTACT_enc_ACTIVE ACTIVE_enc_PLUS ACTIVE_enc_NWELL ACTIVE_enc_PPLUS ACTIVE_enc_NPLUS)
			
			
	/*------------------------------*/  
	/**/	tech_lib = "MPDK_HL18GFL"
	/*------------------------------*/  
	/**/	CONTACT = ""
	/**/	PACTIVE = ""
	/**/	NACTIVE = ""
	/**/	PPLUS = ""
	/**/	NPLUS = ""
	/**/	NWELL = ""
	/**/	METAL = ""
	/*------------------------------*/  
	/**/	CONTACT_width = 0.000
	/**/	CONTACT_space_min = 0.000
	/**/	CONTACT_space_max = 0.000
	/**/	CONTACT_enc_ACTIVE = 0.000
	/**/	ACTIVE_enc_PLUS = 0.000
	/**/	ACTIVE_enc_NWELL = 0.000
	/**/	ACTIVE_enc_PPLUS = ACTIVE_enc_PLUS
	/**/	ACTIVE_enc_NPLUS = ACTIVE_enc_PLUS
	/*------------------------------*/  
		
		
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
		?choppable	 nil
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

;----------以后再说----------;  
;1.解决第一次调用时会报错的问题;  
	;  
;2.解决UI交互逻辑的不合理;  
	;  
;----------;----------;  
;1.兼容IC51;  
	;  
;2.函数使用错误时，在CIW显示用法提示;  
	;  
;3.增加ACTIVE和METAL不完全重叠的情况;
	;
;----------2019-11-21----------;  
;1.修复切割的时候掺杂层也被切的问题;√
	;函数encSubPath_func()内?choppable项的值改为nil;
;----------2019-11-20----------;  
;1.增加active最小宽度限制;√  
	;增加active宽度不得小于单排contact的限制;  
;2.优化;√  
	;优化了几个不规范;例如子程序contact_row()和变量contact_row重名;规范子程序名(encSubPath_func()和subRect_func);  
;3.工艺信息变量化;√  
	;Done;  
;----------2019-11-19----------;  
;1.优先解决输入arg_input为active宽度且超过contact达到4x4的临界值时发生的规则错误(ACTIVE_enc_PLUS);√  
	;输入arg_input为active宽度时增加contact达到4x4临界值的判断;  
;2.解决fix()在运算浮点数时可能发生的错误;√  
	;更换fix()为fix2()解决SKILL的遗留BUG;  
;3.优化模板命名代码结构和格式;并增加规则信息;√  
	;浮点数保留到千分位;增加contact < 4x4时的规则区分;  
;----------2019-11-18----------;  
;1.增加UI交互√  
	;MPP_UI()调出交互窗口;  
	;可选掺杂类型：P/N/NW;  
	;可选contact排列个数/active宽度;  
	;可强制选用最小规则/4x4阵列contact规则;  
	;保留命令模式，格式按照MPP((s_active_type) (n_arg_input) [s_rule] [s_arg_type]);  
		;(s_active_type)输入类型为string或者symbol;  
		;(n_arg_input)输入类型为fixnum或者flonum;当为fixnum时匹配contact的排数;为flonum时匹配ACTIVE的宽度;  
		;[s_rule]可选;输入类型为string或者symbol;默认为"min";可以输入"max"更换成4x4阵列规则;实际上只要输入不是nil或者"min"都会判定为"max";  
		;[s_arg_type]可选，输入类型为string或者symbol;默认为"unlock";unlock下可以自动识别(n_arg_input)，可以输入"rownum"或者"widthnum"来强制指定(n_arg_input)的意义。  
;2.修复规则切换引起的bug，并将默认值更改为min√  
	;先将contact的row间距变量化来解决这个问题;并把规则判断提前处理;  
;3.修复enc_sub_list()的一个潜在错误√  
	;变量命名错误;  
;----------2019-11-14----------;  
;1.可选掺杂类型等√  
	;"P"为PSD;"N"为NSD;"NW"为NW;  
;2.掺杂切换参数输入类型同兼容symbol和string类型√  
	;可以输入"P",也可以输入'P;  
;3.命令模式下自动识别输入参数为contact排数还是active宽度√  
	;输入整数位contact排数;输入浮点数为active宽度,单位um;  
;4.增加规则切换√  
	;默认匹配4x4阵列contact的规则;输入"min"或'min则在小于4排孔的时候使用最小规则;  
;5.MPP模板自动命名√  
	;模板命名格式为"[掺杂类型]_Tap_[contact排数_row/active宽度_um]";  
;----------2019----------;  
