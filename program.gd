extends Node

@onready var button_group: Node = get_node_or_null("{0}/UI/Content/Buttons".format([get_path()]))
@onready var output: Label = get_node_or_null("{0}/UI/Content/Output".format([get_path()]))

var button_groups: Array[Node] = []
var buttons: Array[Button] = []
var math_equation: String = ""

var has_error: bool = false

func _ready() -> void:
	if button_group == null:
		printerr("The button group doesn't exist. Exitting...")
		push_error("Non-existent button group.")
		get_tree().quit(1)
		
	get_button_groups()
	get_buttons()
	
func get_button_groups() -> void:
	for child in button_group.get_children():
		if not child is HBoxContainer:
			print_verbose("{0} <{1}> is not a valid button group.".format([child, child.name]))
			push_warning("{0} <{1}> is not a valid button group.".format([child, child.name]))
			continue
			
		button_groups.append(child as Node)
	print_verbose("There are {0} button groups.".format([button_groups.size()]))
		
func get_buttons() -> void:
	for group in button_groups:
		for button in group.get_children():
			if not button is Button:
				continue
			
			var _b: Button = button as Button
			_b.pressed.connect(button_pressed.bind(_b))
			buttons.append(button)

func disable_all_buttons() -> void:
	for button in buttons:
		if not button is Button:
			continue
		button.disabled = true
		
func enable_all_buttons() -> void:
	for button in buttons:
		if not button is Button:
			continue
		button.disabled = false
		
func find_button(name: StringName) -> Button:
	for button in buttons:
		if button.name == name:
			return button
			
	return null

func button_pressed(button: Button) -> void:
	if button.is_in_group("calculator_equation_input"):
		if math_equation.length() == 0:
			output.text = ""
			
		output.text += "{0}".format([button.text])
		
		math_equation += "{0}"\
			.format([button.text]) \
			.replace("×", "*") \
			.replace("÷", "/")
			
	
	
	if button.is_in_group("calculator_function"):
		match button.text:
			"AC":
				clear()
			
			"=":
				compute_equation()
			
			_:
				print_verbose("{0} <{1}> has a un-implemented function.".format([button, button.get_path()]))
				push_warning("{0} <{1}> has a un-implemented function.".format([button, button.get_path()]))

func clear_error() -> void:
	enable_all_buttons()
	has_error = false

func clear() -> void:
	output.text = "0"
	math_equation = ""
	
	if has_error:
		clear_error()
	

func compute_equation() -> void:
	var expression: Expression = Expression.new()
	var error: Error = expression.parse(math_equation)
	if error != Error.OK:
		show_error()
		return
	
	var result = expression.execute()
	if not result is int and not result is float:
		show_error()
		return
		
	output.text = "{0}".format([result])
		

func show_error() -> void:
	output.text = "Error."
	disable_all_buttons()
	find_button("Clear").disabled = false
	has_error = true
