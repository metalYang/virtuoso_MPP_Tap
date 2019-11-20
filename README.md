# MPP_Tap  

基于Skill的一个用于virtuoso的layout插件，用于生成MPP，绘制Tap，正在往最完善的方向优化。  
主要是用过一些工艺PDK自带类似的工具，本想看看他们的脚本是怎么写的，没想到居然是加密的，  
没办法想用只能自己做了，正好闲着没事做用来学习Skill。  

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
