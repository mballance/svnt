/****************************************************************************
 * Copyright 2018 Matthew Ballance
 *
 ****************************************************************************/
 
grammar SystemVerilog;

// A.1 Source text

// A.1.1. Library source text
library_text : 
  ( library_description )*
  EOF
  ;
  
library_description:
  library_declaration
  | include_statement
  | config_declaration
  | ';'
  ;
  
library_declaration:
  'library' library_identifier file_path_spec ( ',' file_path_spec )*
  ( '-incdir' file_path_spec ( ',' file_path_spec )* )? ';'
  ;
  
include_statement: 
  'include' file_path_spec ';'
  ;
 
// TODO: file_path_spec is system-dependent
file_path_spec: 
  identifier 
  ;

// A.1.2 SystemVerilog source text
source_text : 
  ( timeunits_declaration )? ( description )* EOF
  ;
  
description:
  module_declaration
//TODO:  | udp_declaration
  | interface_declaration
  | program_declaration
  | package_declaration
  | ( attribute_instance )* package_item
  | ( attribute_instance )* bind_directive
  | config_declaration
  ;
  
module_nonansi_header:
  ( attribute_instance )? module_keyword ( lifetime )? module_identifier
  ( package_import_declaration )* ( parameter_port_list )? list_of_ports ';'
  ;
  
module_ansi_header:
  ( attribute_instance )* module_keyword ( lifetime )? module_identifier
  ( package_import_declaration )* ( parameter_port_list )? ( list_of_port_declarations )? ';'
  ;
  
module_declaration:
  module_nonansi_header ( timeunits_declaration )? ( module_item )*
  'endmodule' ( ':' module_identifier )?
  | module_ansi_header ( timeunits_declaration )? ( non_port_module_item )*
  'endmodule' ( ':' module_identifier )?
  | ( attribute_instance )* module_keyword ( lifetime )? module_identifier '(' '.*' ')' ';'
    ( timeunits_declaration )? ( module_item )* 'endmodule' ( ':' module_identifier )?
  | 'extern' module_nonansi_header
  | 'extern' module_ansi_header
  ;
  
module_keyword: 
  'module' | 'macromodule'
  ;

interface_declaration:
  interface_nonansi_header ( timeunits_declaration )? ( interface_item )*
  'endinterface' ( ':' interface_identifier )?
  | interface_ansi_header ( timeunits_declaration )? ( non_port_interface_item )*
  'endinterface' ( ':' interface_identifier )?
  | ( attribute_instance )* 'interface' interface_identifier '(' '.*' ')' ';'
  ( timeunits_declaration )? ( interface_item )*
  'endinterface' ( ':' interface_identifier )?
  | 'extern' interface_nonansi_header
  | 'extern' interface_ansi_header
  ;
  
interface_nonansi_header:
  ( attribute_instance )* 'interface' ( lifetime )? interface_identifier
  ( package_import_declaration )* ( parameter_port_list )? list_of_ports ';'
  ;
  
interface_ansi_header:
  (attribute_instance )* 'interface' ( lifetime )? interface_identifier
  ( package_import_declaration )*
  ( parameter_port_list )? ( list_of_port_declarations )? ';'
  ;
  
program_declaration:
  program_nonansi_header ( timeunits_declaration )? ( program_item )*
  'endprogram' ( ':' program_identifier )?
  | program_ansi_header ( timeunits_declaration )? ( non_port_program_item )*
  'endprogram' ( ':' program_identifier )?
  | ( attribute_instance )* 'program' program_identifier '(' '.*' ')' ';'
  ( timeunits_declaration )? ( program_item )*
  'endprogram' ( ':' program_identifier )?
  | 'extern' program_nonansi_header
  | 'extern' program_ansi_header
  ;
  
program_nonansi_header:
  ( attribute_instance )* 'program' ( lifetime )? program_identifier
  ( package_import_declaration )* ( parameter_port_list )? list_of_ports ';'
  ;
program_ansi_header:
  (attribute_instance )* 'program' ( lifetime )? program_identifier 
  ( package_import_declaration )* ( parameter_port_list )? ( list_of_port_declarations )? ';'
  ;
  
checker_declaration:
  'checker' checker_identifier ( '(' ( checker_port_list )? ')' )? ';'
  ( ( attribute_instance )* checker_or_generate_item )*
  'endchecker' ( ':' checker_identifier )?
  ;
  
class_declaration:
  ( 'virtual' )? 'class' ( lifetime )? name=class_identifier ( parameter_port_list )?
  ( 'extends' class_type ( '(' list_of_arguments ')' )? )?
  ( 'implements' interface_class_type ( ',' interface_class_type )* )? ';'
  ( class_item )*
  'endclass' ( ':' class_identifier )?
  ;
  
interface_class_type: 
  ps_class_identifier ( parameter_value_assignment )?
  ;
  
interface_class_declaration:
  'interface' 'class' name=class_identifier ( parameter_port_list )?
  ( 'extends' interface_class_type ( ',' interface_class_type )* )? ';'
  ( interface_class_item )*
  'endclass' ( ':' class_identifier )?
  ;
  
interface_class_item:
  type_declaration
  | ( attribute_instance )* interface_class_method
  | local_parameter_declaration ';'
  | parameter_declaration ';'
  | ';'
  ;
  
interface_class_method:
  'pure' 'virtual' method_prototype ';'
  ;
  
package_declaration:
  ( attribute_instance )* 'package' ( lifetime )? name=package_identifier ';'
  ( timeunits_declaration )? ( ( attribute_instance )* package_item )*
  'endpackage' ( ':' package_identifier )?
  ;
  
timeunits_declaration:
  'timeunit' time_literal ( '/' time_literal )? ';'
  | 'timeprecision' time_literal ';'
  | 'timeunit' time_literal ';' 'timeprecision' time_literal ';'
  | 'timeprecision' time_literal ';' 'timeunit' time_literal ';'
  ;

//***********************************************************************
//* A.1.3 Module parameters and ports
//***********************************************************************
parameter_port_list:
  '#' '(' list_of_param_assignments ( ',' parameter_port_declaration )* ')'
  | '#' '(' parameter_port_declaration ( ',' parameter_port_declaration )* ')'
  | '#' '(' ')'
  ;
  
parameter_port_declaration:
  parameter_declaration
  | local_parameter_declaration
  | data_type list_of_param_assignments
  | 'type' list_of_type_assignments
  ;
  
list_of_ports: 
  '(' port ( ',' port )* ')'
  ;
  
list_of_port_declarations:
  '(' ( ( attribute_instance)* ansi_port_declaration ( ',' ( attribute_instance)* ansi_port_declaration )* )? ')'
  ;

port_declaration:
  ( attribute_instance )* inout_declaration
  | ( attribute_instance )* input_declaration
  | ( attribute_instance )* output_declaration
  | ( attribute_instance )* ref_declaration
  | ( attribute_instance )* interface_port_declaration
  ;
  
port:
  ( port_expression )?
  | '.' port_identifier '(' ( port_expression )? ')'
  ;
  
port_expression:
  port_reference
  | '{' port_reference ( ',' port_reference )* '}'
  ;
  
port_reference:
  port_identifier constant_select
  ;
  
port_direction:
  'input' 
  | 'output' 
  | 'inout' 
  | 'ref'
  ;
  
net_port_header: 
  ( port_direction )? net_port_type
  ;
  
variable_port_header: 
  ( port_direction )? variable_port_type
  ;
  
interface_port_header:
  interface_identifier ( '.' modport_identifier )?
  | 'interface' ( '.' modport_identifier )?
  ;
  
ansi_port_declaration:
  ( net_port_header | interface_port_header )? port_identifier ( unpacked_dimension )*
    ( '=' constant_expression )?
  | ( variable_port_header )? port_identifier ( variable_dimension )* ( '=' constant_expression )?
  | ( port_direction )? '.' port_identifier '(' ( expression )? ')'
  ;

//***********************************************************************
//* A.1.4 Module items
//***********************************************************************

elaboration_system_task:
  '$fatal' ( '(' finish_number=expression (',' list_of_arguments )? ')' )? ';'
  | '$error' ( '(' ( list_of_arguments )? ')' )? ';'
  | '$warning' ( '(' ( list_of_arguments )? ')' )? ';'
  | '$info' ( '(' ( list_of_arguments )? ')' )? ';'
  ;
  
module_common_item:
  module_or_generate_item_declaration
  | interface_instantiation
  | program_instantiation
//TODO:  | assertion_item
  | bind_directive
  | continuous_assign
  | net_alias
  | initial_construct
  | final_construct
  | always_construct
  | loop_generate_construct
  | conditional_generate_construct
  | elaboration_system_task
  ;
  
module_item:
  port_declaration ';'
  | non_port_module_item
  ;
  
module_or_generate_item:
  ( attribute_instance )* parameter_override
//TODO:  | ( attribute_instance )* gate_instantiation
//TODO:  | ( attribute_instance )* udp_instantiation
  | ( attribute_instance )* module_instantiation
  | ( attribute_instance )* module_common_item
  ;
  
module_or_generate_item_declaration:
  package_or_generate_item_declaration
  | genvar_declaration
  | clocking_declaration
  | 'default' 'clocking' clocking_identifier ';'
  | 'default' 'disable' 'iff' expression_or_dist ';'
  ;
  
non_port_module_item:
  generate_region
  | module_or_generate_item
  | specify_block
  | ( attribute_instance )* specparam_declaration
  | program_declaration
  | module_declaration
  | interface_declaration
  | timeunits_declaration
  ;
  
parameter_override: 
  'defparam' list_of_defparam_assignments ';'
  ;
  
bind_directive:
  'bind' bind_target_scope (':' bind_target_instance_list)? bind_instantiation ';'
  | 'bind' bind_target_instance bind_instantiation ';'
  ;
  
bind_target_scope:
  module_identifier
  | interface_identifier
  ;
  
bind_target_instance:
  hierarchical_identifier constant_bit_select
  ;
  
bind_target_instance_list:
  bind_target_instance ( ',' bind_target_instance )*
  ;
  
bind_instantiation:
  program_instantiation
  | module_instantiation
  | interface_instantiation
  | checker_instantiation 
  ;

//***********************************************************************
//* A.1.5 Configuration source text
//***********************************************************************
config_declaration:
  'config' config_identifier ';'
  ( local_parameter_declaration ';' )*
  design_statement
  ( config_rule_statement )*
  'endconfig' ( ':' config_identifier )?
  ;
  
design_statement: 
  'design' ( ( library_identifier '.' )? cell_identifier )* ';'
  ;
  
config_rule_statement:
  default_clause liblist_clause ';'
  | inst_clause liblist_clause ';'
  | inst_clause use_clause ';'
  | cell_clause liblist_clause ';'
  | cell_clause use_clause ';'
  ;
  
default_clause: 
  'default'
  ;

inst_clause: 
  'instance' inst_name
  ;
  
inst_name: 
  topmodule_identifier ( '.' instance_identifier )*
  ;
  
cell_clause: 
  'cell' ( library_identifier '.' )? cell_identifier
  ;
  
liblist_clause: 
  'liblist' (library_identifier)*
  ;
  
use_clause: 
  'use' ( library_identifier '.' )? cell_identifier ( ':' 'config' )?
  | 'use' named_parameter_assignment ( ',' named_parameter_assignment )* ( ':' 'config' )?
  | 'use' ( library_identifier '.' )? cell_identifier named_parameter_assignment
  ( ',' named_parameter_assignment )* ( ':' 'config' )?
  ;
  
//***********************************************************************
//* A.1.6 Interface items
//***********************************************************************
interface_or_generate_item:
  ( attribute_instance )* module_common_item
  | ( attribute_instance )* modport_declaration
  | ( attribute_instance )* extern_tf_declaration
  ;
  
extern_tf_declaration:
  'extern' method_prototype ';'
  | 'extern' 'forkjoin' task_prototype ';'
  ;
  
interface_item:
  port_declaration ';'
  | non_port_interface_item
  ;
  
non_port_interface_item:
  generate_region
  | interface_or_generate_item
  | program_declaration
  | interface_declaration
  | timeunits_declaration
  ;
  
//***********************************************************************
//* A.1.7 Program items
//***********************************************************************
program_item:
  port_declaration ';'
  | non_port_program_item
  ;
  
non_port_program_item:
  ( attribute_instance )* continuous_assign
  | ( attribute_instance )* module_or_generate_item_declaration
  | ( attribute_instance )* initial_construct
  | ( attribute_instance )* final_construct
  | ( attribute_instance )* concurrent_assertion_item
  | timeunits_declaration
  | program_generate_item
  ;
  
program_generate_item:
  loop_generate_construct
  | conditional_generate_construct  
  | generate_region
  | elaboration_system_task
  ;
  
//***********************************************************************
//* A.1.8 Checker items
//***********************************************************************
checker_port_list:
  checker_port_item (',' checker_port_item)*
  ;
  
checker_port_item:
  ( attribute_instance )* ( checker_port_direction )? property_formal_type formal_port_identifier
    (variable_dimension)* ( '=' property_actual_arg )?
  ;
  
checker_port_direction:
  'input' | 'output'
  ;
  
checker_or_generate_item:
  checker_or_generate_item_declaration
  | initial_construct
  | always_construct
  | final_construct
  | assertion_item
  | continuous_assign
  | checker_generate_item
  ;
  
checker_or_generate_item_declaration:
  ( 'rand' )? data_declaration
  | function_declaration
  | checker_declaration
//TODO:  | assertion_item_declaration
//TODO:  | covergroup_declaration
  | overload_declaration
  | genvar_declaration
  | clocking_declaration
  | 'default' 'clocking' clocking_identifier ';'
  | 'default' 'disable' 'iff' expression_or_dist ';'
  | ';'
  ;
  
checker_generate_item:
  loop_generate_construct
  | conditional_generate_construct
  | generate_region
  | elaboration_system_task
  ;

//***********************************************************************
//* A.1.9 Class items
//***********************************************************************
class_item:
  ( attribute_instance )* class_property
  | ( attribute_instance )* class_method
  | ( attribute_instance )* class_constraint
  | ( attribute_instance )* class_declaration
//TODO:  | ( attribute_instance )* covergroup_declaration
  | local_parameter_declaration ';'
  | parameter_declaration ';'
  | ';'
  ;
  
class_property:
  class_data_property
  | class_const_property
  ;

class_data_property:
  ( property_qualifier )* data_declaration
  ;

class_const_property:
  'const' ( class_item_qualifier )* data_type const_identifier ( '=' constant_expression )? ';'
  ;
  
class_method:
  ( method_qualifier )* task_declaration
  | ( method_qualifier )* function_declaration
  | 'pure' 'virtual' ( class_item_qualifier )* method_prototype ';'
  | 'extern' ( method_qualifier )* method_prototype ';'
  | ( method_qualifier )* class_constructor_declaration
  | 'extern' ( method_qualifier )* class_constructor_prototype
  ;
  
class_constructor_prototype:
  'function' 'new' ( '(' ( tf_port_list )? ')' )? ';'
  ;
  
class_constraint:
  constraint_prototype
  | constraint_declaration
  ;
  
class_item_qualifier:
  'static'
  | 'protected'
  | 'local'
  ;
  
property_qualifier:
  random_qualifier
  | class_item_qualifier
  ;
  
random_qualifier:
  'rand'
  | 'randc'
  ;
  
method_qualifier:
  ( 'pure' )? 'virtual'
  | class_item_qualifier
  ;
  
method_prototype:
  task_prototype
  | function_prototype
  ;
  
class_constructor_declaration:
  'function' ( class_scope )? 'new' ( '(' ( tf_port_list )? ')' )? ';'
  ( block_item_declaration )*
  ( 'super' '.' 'new' ( '(' list_of_arguments ')' )? ';' )?
  ( function_statement_or_null )*
  'endfunction' ( ':' 'new' )? 
  ;

//***********************************************************************
//* A.1.10 Constraints
//***********************************************************************
constraint_declaration: 
  ( 'static' )? 'constraint' constraint_identifier constraint_block
  ;
  
constraint_block: 
  '{' ( constraint_block_item )* '}'
  ;
  
constraint_block_item:
  'solve' solve_before_list 'before' solve_before_list ';'
  | constraint_expression
  ;
  
solve_before_list: 
  constraint_primary ( ',' constraint_primary )*
  ;
  
constraint_primary: 
  ( implicit_class_handle '.' | class_scope )? hierarchical_identifier select
  ;
  
constraint_expression:
  ( 'soft' )? expression_or_dist ';'
  | uniqueness_constraint ';'
  | expression '->' constraint_set
  | 'if' '(' expression ')' constraint_set ( 'else' constraint_set )?
  | 'foreach' '(' ps_or_hierarchical_array_identifier ( loop_variables )? ')' constraint_set
  | 'disable' 'soft' constraint_primary ';'
  ;
  
uniqueness_constraint:
  'unique' '{' open_range_list '}'
  ;
  
constraint_set:
  constraint_expression
  | '{' ( constraint_expression )* '}'
  ;
  
dist_list: 
  dist_item ( ',' dist_item )*
  ;
  
dist_item: 
  value_range ( dist_weight )?
  ;
  
dist_weight:
  ':=' expression
  | ':/' expression
  ;
  
constraint_prototype: 
  (constraint_prototype_qualifier)? ( 'static' )? 'constraint' constraint_identifier ';'
  ;
  
constraint_prototype_qualifier: 
  'extern' | 'pure'
  ;
  
extern_constraint_declaration:
  ( 'static' )? 'constraint' class_scope constraint_identifier constraint_block
  ;
  
identifier_list: 
  identifier ( ',' identifier )* 
  ;
  
//***********************************************************************
//* A.1.11 Package items
//***********************************************************************
package_item:
  package_or_generate_item_declaration
  | anonymous_program
  | package_export_declaration
  | timeunits_declaration
  ;
  
package_or_generate_item_declaration:
  net_declaration
  | data_declaration
  | task_declaration
  | function_declaration
  | checker_declaration
  | dpi_import_export
  | extern_constraint_declaration
  | class_declaration
  | class_constructor_declaration
  | local_parameter_declaration ';'
  | parameter_declaration ';'
//TODO:  | covergroup_declaration
  | overload_declaration
  | assertion_item_declaration
  | ';'
  ;
  
anonymous_program: 
  'program' ';' ( anonymous_program_item )* 'endprogram'
  ;
  
anonymous_program_item:
  task_declaration
  | function_declaration
  | class_declaration
//TODO:  | covergroup_declaration
  | class_constructor_declaration
  | ';'
  ;

//***************************************************************************
//* A.2 Declarations
//***************************************************************************

//***********************************************************************
//* A.2.1 Declaration types
//***********************************************************************

//*******************************************************************
//* A.2.1.1 Module parameter declarations
//*******************************************************************
local_parameter_declaration:
  'localparam' data_type_or_implicit list_of_param_assignments
  | 'localparam type' list_of_type_assignments
  ;
  
parameter_declaration:
  'parameter' data_type_or_implicit list_of_param_assignments
  | 'parameter' 'type' list_of_type_assignments
  ;
  
specparam_declaration:
  'specparam' ( packed_dimension )? list_of_specparam_assignments ';'
  ;

//*******************************************************************
//* A.2.1.2 Port declarations
//*******************************************************************
inout_declaration:
  'inout' net_port_type list_of_port_identifiers
  ;
  
input_declaration:
  'input' net_port_type list_of_port_identifiers
  | 'input' variable_port_type list_of_variable_identifiers
  ;
  
output_declaration:
  'output' net_port_type list_of_port_identifiers
  | 'output' variable_port_type list_of_variable_port_identifiers
  ;
  
interface_port_declaration:
  interface_identifier list_of_interface_identifiers
  | interface_identifier '.' modport_identifier list_of_interface_identifiers
  ;
  
ref_declaration: 
  'ref' variable_port_type list_of_variable_identifiers 
  ;

//*******************************************************************
//* A.2.1.3 Type declarations
//*******************************************************************
data_declaration:
  data_field_declaration
  | type_declaration
  | package_import_declaration net_type_declaration
  ;
  
data_field_declaration:
  ( 'const' )? ( 'var' )? ( lifetime )? data_type_or_implicit list_of_variable_decl_assignments ';'
  ;
  
package_import_declaration:
  'import' package_import_item ( ',' package_import_item )* ';'
  ;
  
package_import_item:
  package_identifier '::' identifier
  | package_identifier '::' '*'
  ;
  
package_export_declaration:
  'export' '*' '::' '*' ';'
  | 'export' package_import_item ( ',' package_import_item )* ';'
  ;
  
genvar_declaration: 
  'genvar' list_of_genvar_identifiers ';'
  ;
  
net_declaration:
  net_type ( drive_strength | charge_strength )? ( 'vectored' | 'scalared' )?
  data_type_or_implicit ( delay3 )? list_of_net_decl_assignments ';'
  | net_type_identifier ( delay_control )? list_of_net_decl_assignments ';'
  | 'interconnect' implicit_data_type ( '#' delay_value )? net_identifier ( unpacked_dimension )*
    ( ',' net_identifier ( unpacked_dimension )*)? ';'
  ;
  
type_declaration:
  'typedef' data_type type_identifier (variable_dimension)* ';'
  | 'typedef' interface_instance_identifier constant_bit_select '.' type_identifier type_identifier ';'
  | 'typedef' ( 'enum' | 'struct' | 'union' | 'class' | 'interface' 'class' )? type_identifier ';'
  ;
  
net_type_declaration:
  'nettype' data_type net_type_identifier
    ( 'with' ( package_scope | class_scope )? tf_identifier )? ';'
  | 'nettype' ( package_scope | class_scope )? net_type_identifier net_type_identifier ';'
  ;
  
lifetime: 
  'static' | 'automatic'
  ;
  
//***********************************************************************
//* A.2.2 Declaration data types
//***********************************************************************

//*******************************************************************
//* A.2.2.1 Net and variable types
//*******************************************************************
casting_type: 
  simple_type | constant_primary | signing | 'string' | 'const'
  ;
  
data_type:
  data_type_integer_vector
  | data_type_integer_atom
  | non_integer_type
  | data_type_struct_union
  | data_type_enum
  | data_type_string
  | data_type_chandle
  | data_type_virtual
  | data_type_user_defined
  | data_type_event
  | ps_covergroup_identifier
  | type_reference
  | class_type
;

data_type_integer_vector:
  integer_vector_type ( signing )? ( packed_dimension )*
  ;
  
data_type_integer_atom:
  integer_atom_type ( signing )?
  ;
 
data_type_struct_union: 
  struct_union ( 'packed' ( signing )? )? '{' struct_union_member ( struct_union_member )* '}' ( packed_dimension )*
  ;

data_type_enum:  
  is_enum='enum' ( enum_base_type )? '{' enum_name_declaration ( ',' enum_name_declaration )* '}' ( packed_dimension )*
  ;
 
data_type_string: 
  'string'
  ;
 
data_type_chandle: 
  'chandle'
  ;

data_type_virtual: 
  'virtual' ( 'interface' )? interface_identifier ( parameter_value_assignment )? ( '.' modport_identifier )?
  ;

data_type_user_defined:  
  ( class_scope | package_scope )? type_identifier ( packed_dimension )*
  ;

data_type_event:
  'event'
  ;

data_type_or_implicit:
  data_type
  | implicit_data_type
  ;
  
implicit_data_type: 
  ( signing )? ( packed_dimension )*
  ;
  
enum_base_type:
  integer_atom_type ( signing )?
  | integer_vector_type ( signing )? ( packed_dimension )?
  | type_identifier ( packed_dimension )?
  ;
  
enum_name_declaration:
  enum_identifier ( '[' integral_number ( ':' integral_number )? ']' )? ( '=' constant_expression )?
  ;
  
class_scope: 
  class_type '::'
  ;
  
class_type:
  ps_class_identifier ( parameter_value_assignment )?
  ( '::' class_identifier ( parameter_value_assignment )? )*
  ;
  
integer_type: 
  integer_vector_type | integer_atom_type
  ;
  
integer_atom_type: 
  'byte' | 'shortint' | 'int' | 'longint' | 'integer' | 'time'
  ;
  
integer_vector_type: 
  'bit' | 'logic' | 'reg'
  ;

non_integer_type: 
  'shortreal' | 'real' | 'realtime'
  ;
  
net_type: 
  'supply0' | 'supply1' | 'tri' | 'triand' | 'trior' | 'trireg' | 'tri0' | 'tri1' | 'uwire' | 'wire' | 'wand' | 'wor'
  ;
  
net_port_type:
  ( net_type )? data_type_or_implicit
  | net_type_identifier
  | 'interconnect' implicit_data_type
  ;
  
variable_port_type: 
  var_data_type
  ;
  
var_data_type: 
  data_type 
  | 'var' data_type_or_implicit
  ;
  
signing: 
  'signed' | 'unsigned'
  ;
  
simple_type: 
  integer_type 
  | non_integer_type 
  | ps_type_identifier 
  | ps_parameter_identifier
  ;
  
struct_union_member:
  ( attribute_instance )* (random_qualifier)? data_type_or_void list_of_variable_decl_assignments ';'
  ;
  
data_type_or_void: 
  data_type 
  | 'void'
  ;
  
struct_union: 
  'struct' 
  | 'union' ( 'tagged' )?
  ;
  
type_reference:
  'type' '(' expression ')'
  | 'type' '(' data_type ')'
  ;
  
//*******************************************************************
//* A.2.2.2 Strengths
//*******************************************************************
drive_strength:
  '(' strength0 ',' strength1 ')'
  | '(' strength1 ',' strength0 ')'
  | '(' strength0 ',' 'highz1' ')'
  | '(' strength1 ',' 'highz0' ')'
  | '(' 'highz0' ',' strength1 ')'
  | '(' 'highz1' ',' strength0 ')'
  ;
  
strength0: 
  'supply0' 
  | 'strong0' 
  | 'pull0' 
  | 'weak0'
  ;
  
strength1: 
  'supply1' 
  | 'strong1' 
  | 'pull1' 
  | 'weak1'
  ;
  
charge_strength: 
  '(' 'small' ')' 
  | '(' 'medium' ')' 
  | '(' 'large' ')'
  ;

//*******************************************************************
//* A.2.2.3 Delays
//*******************************************************************
delay3: 
  '#' delay_value 
  | '#' '(' mintypmax_expression ( ',' mintypmax_expression ( ',' mintypmax_expression )? )? ')'
  ;
  
delay2: 
  '#' delay_value 
  | '#' '(' mintypmax_expression ( ',' mintypmax_expression )? ')'
  ;
  
delay_value:
  UNSIGNED_NUMBER
  | real_number
  | ps_identifier
  | time_literal
  | '1step'
  ;

//***********************************************************************
//* A.2.3 Declaration lists
//***********************************************************************

list_of_defparam_assignments: 
  defparam_assignment ( ',' defparam_assignment )*
  ;
  
list_of_genvar_identifiers: 
  genvar_identifier ( ',' genvar_identifier )*
  ;
  
list_of_interface_identifiers: 
  interface_identifier ( unpacked_dimension )*
    ( ',' interface_identifier ( unpacked_dimension )* )*
  ;
  
list_of_net_decl_assignments: 
  net_decl_assignment ( ',' net_decl_assignment )*
  ;
  
list_of_param_assignments: 
  param_assignment ( ',' param_assignment )*
  ;
  
list_of_port_identifiers: 
  port_identifier ( unpacked_dimension )*
    ( ',' port_identifier ( unpacked_dimension )* )*
  ;
  
list_of_udp_port_identifiers: 
  port_identifier ( ',' port_identifier )*
  ;
  
list_of_specparam_assignments: 
  specparam_assignment ( ',' specparam_assignment )*
  ;
  
list_of_tf_variable_identifiers: 
  port_identifier ( variable_dimension )* ( '=' expression )?
  ( ',' port_identifier ( variable_dimension )* ( '=' expression )? )*
  ;
  
list_of_type_assignments: 
  type_assignment ( ',' type_assignment )*
  ;
  
list_of_variable_decl_assignments: 
  variable_decl_assignment ( ',' variable_decl_assignment )*
  ;
  
list_of_variable_identifiers: 
  variable_identifier ( variable_dimension )*
    ( ',' variable_identifier ( variable_dimension )* )*
  ;
  
list_of_variable_port_identifiers: 
  port_identifier ( variable_dimension )* ( '=' constant_expression )?
    ( ',' port_identifier ( variable_dimension )* ( '=' constant_expression )? )*
  ; 

//***********************************************************************
//* A.2.4 Declaration assignments
//***********************************************************************

defparam_assignment: 
  hierarchical_parameter_identifier '=' constant_mintypmax_expression
  ;
  
net_decl_assignment: 
  net_identifier ( unpacked_dimension )* ( '=' expression )?
  ;
  
param_assignment:
  parameter_identifier ( unpacked_dimension )* ( '=' constant_param_expression )?
  ;
  
specparam_assignment:
  specparam_identifier '=' constant_mintypmax_expression
  | pulse_control_specparam
  ;
  
type_assignment:
  type_identifier ( '=' data_type )?
  ;
  
pulse_control_specparam:
  'PATHPULSE$' '=' '(' reject_limit_value ( ',' error_limit_value )? ')'
  | 'PATHPULSE$' specify_input_terminal_descriptor '$' specify_output_terminal_descriptor
    '=' '(' reject_limit_value ( ',' error_limit_value )? ')'
  ;
  
error_limit_value: 
  limit_value
  ;
  
reject_limit_value: 
  limit_value
  ;
  
limit_value: 
  constant_mintypmax_expression
  ;
  
variable_decl_assignment:
  variable_identifier ( variable_dimension )* ( '=' expression )?
  | dynamic_array_variable_identifier unsized_dimension ( variable_dimension )*
    ( '=' dynamic_array_new )?
  | class_variable_identifier ( '=' class_new )
  ;
  
class_new:
  ( class_scope )? 'new' ( '(' list_of_arguments ')' )?
  | 'new' expression
  ;
  
dynamic_array_new: 
  'new' ( expression )? ( '(' expression ')' )?
  ; 

//***********************************************************************
//* A.2.5 Declaration ranges
//***********************************************************************
unpacked_dimension:
  '[' constant_range ']'
  | '[' constant_expression ']'
  ;
  
packed_dimension:
  '[' constant_range ']'
  | unsized_dimension
  ;
  
associative_dimension:
  '[' data_type ']'
  | '[' '*' ']'
  ;
  
variable_dimension:
  unsized_dimension
  | unpacked_dimension
  | associative_dimension
  | queue_dimension
  ;
  
queue_dimension: 
  '[' '$' ( ':' constant_expression )? ']'
  ;
  
unsized_dimension: 
  '[' ']'
  ;

//***********************************************************************
//* A.2.6 Function declarations
//***********************************************************************
function_data_type_or_implicit:
  data_type_or_void
  | implicit_data_type
  ;
  
function_declaration: 
  'function' ( lifetime )? function_body_declaration
  ;
  
function_body_declaration:
  function_data_type_or_implicit
    ( interface_identifier '.' | class_scope )? name=function_identifier ';'
    ( tf_item_declaration )*
    ( function_statement_or_null )*
    'endfunction' ( ':' function_identifier )?
  | function_data_type_or_implicit
    ( interface_identifier '.' | class_scope )? name=function_identifier '(' ( tf_port_list )? ')' ';'
    ( block_item_declaration )*
    ( function_statement_or_null )*
    'endfunction' ( ':' function_identifier )?
  ;
  
function_prototype: 
  'function' data_type_or_void function_identifier ( '(' ( tf_port_list )? ')' )?
  ;
  
dpi_import_export:
  'import' dpi_spec_string ( dpi_function_import_property )? ( c_identifier '=' )? dpi_function_proto ';'
  | 'import' dpi_spec_string ( dpi_task_import_property )? ( c_identifier '=' )? dpi_task_proto ';'
  | 'export' dpi_spec_string ( c_identifier '=' )? 'function' function_identifier ';'
  | 'export' dpi_spec_string ( c_identifier '=' )? 'task' task_identifier ';'
  ;
  
dpi_spec_string: 
  '"DPI-C"' | '"DPI"'
  ;
  
dpi_function_import_property: 
  'context' | 'pure'
  ;
  
dpi_task_import_property: 
  'context'
  ;
  
dpi_function_proto: 
  function_prototype
  ;
  
dpi_task_proto: 
  task_prototype
  ;

//***********************************************************************
//* A.2.7 Task declarations
//***********************************************************************

task_declaration: 
  'task' ( lifetime )? task_body_declaration
  ;
  
task_body_declaration:
  ( interface_identifier '.' | class_scope )? name=task_identifier ';'
    ( tf_item_declaration )*
    ( statement_or_null )*
    'endtask' ( ':' task_identifier )?
  | ( interface_identifier '.' | class_scope )? name=task_identifier '(' ( tf_port_list )? ')' ';'
    ( block_item_declaration )*
    ( statement_or_null )*
    'endtask' ( ':' task_identifier )?
  ;
  
tf_item_declaration:
  block_item_declaration
  | tf_port_declaration
  ;
  
tf_port_list:
  tf_port_item ( ',' tf_port_item )*
  ;
 
// TODO: Disallow completely-empty port items
tf_port_item:
  ( attribute_instance )*
  ( tf_port_direction )? ( 'var' )? data_type_or_implicit
  ( port_identifier ( variable_dimension )* ( '=' expression )? )?
  ;
  
tf_port_direction: 
  port_direction | 'const' 'ref'
  ;
  
tf_port_declaration:
  ( attribute_instance )* tf_port_direction ( 'var' )? data_type_or_implicit list_of_tf_variable_identifiers ';'
  ;
  
task_prototype: 
  'task' task_identifier ( '(' ( tf_port_list )? ')' )? 
  ;

//***********************************************************************
//* A.2.9 Block item declarations
//***********************************************************************

block_item_declaration:
  ( attribute_instance )* data_declaration
  | ( attribute_instance )* local_parameter_declaration ';'
  | ( attribute_instance )* parameter_declaration ';'
  | ( attribute_instance )* overload_declaration
//TODO:  | ( attribute_instance )* let_declaration
  ;
  
overload_declaration:
  'bind' overload_operator 'function' data_type function_identifier '(' overload_proto_formals ')' ';'
  ;
  
overload_operator: 
  '+' | '++' |  '|'   | '*' | '**' | '/' | '%' | '==' | '!=' | '<' | '<=' | '>' | '>=' | '='
  ;
  
overload_proto_formals: 
  data_type (',' data_type)* 
  ;

//***********************************************************************
//* A.2.9 Interface declarations
//***********************************************************************

modport_declaration: 
  'modport' modport_item ( ',' modport_item ) ';'
  ;
  
modport_item: 
  modport_identifier '(' modport_ports_declaration ( ',' modport_ports_declaration )* ')'
  ;
  
modport_ports_declaration:
  ( attribute_instance )* modport_simple_ports_declaration
  | ( attribute_instance )* modport_tf_ports_declaration
  | ( attribute_instance )* modport_clocking_declaration
  ;
  
modport_clocking_declaration: 
  'clocking' clocking_identifier
  ;
  
modport_simple_ports_declaration:
  port_direction modport_simple_port ( ',' modport_simple_port )*
  ;
  
modport_simple_port:
  port_identifier
  | '.' port_identifier '(' ( expression )? ')'
  ;
  
modport_tf_ports_declaration: 
  import_export modport_tf_port ( ',' modport_tf_port )*
  ;
  
modport_tf_port:
  method_prototype
  | tf_identifier
  ;
  
import_export: 
  'import' | 'export'
  ;

//***********************************************************************
//* A.2.10 Assertion declarations
//***********************************************************************
concurrent_assertion_item:
  ( block_identifier ':' )? concurrent_assertion_statement
  | checker_instantiation
  ;
  
concurrent_assertion_statement:
  assert_property_statement
  | assume_property_statement
  | cover_property_statement
  | cover_sequence_statement
  | restrict_property_statement
  ;
  
assert_property_statement:
  'assert' 'property' '(' property_spec ')' action_block
  ;
  
assume_property_statement:
  'assume' 'property' '(' property_spec ')' action_block
  ;
  
cover_property_statement:
  'cover' 'property' '(' property_spec ')' statement_or_null
  ;
  
expect_property_statement:
  'expect' '(' property_spec ')' action_block
  ;
  
cover_sequence_statement:
  'cover' 'sequence' '(' (clocking_event )? ( 'disable' 'iff' '(' expression_or_dist ')' )?
    sequence_expr ')' statement_or_null
  ;
  
restrict_property_statement:
  'restrict' 'property' '(' property_spec ')' ';'
  ;
  
property_instance:
  ps_or_hierarchical_property_identifier ( '(' ( property_list_of_arguments )? ')' )?
  ;
  
property_list_of_arguments:
  (property_actual_arg) ( ',' (property_actual_arg)? )* ( ',' '.' identifier '(' (property_actual_arg)? ')' )*
  | '.' identifier '(' (property_actual_arg)? ')' ( ',' '.' identifier '(' (property_actual_arg)? ')' )*
  ;
  
property_actual_arg:
  property_expr
  | sequence_actual_arg
  ;
  
assertion_item_declaration:
  property_declaration
  | sequence_declaration
  | let_declaration
  ;
  
property_declaration:
  'property' property_identifier ( '(' ( property_port_list )? ')' )? ';'
    ( assertion_variable_declaration )*
    property_spec ( ';' )?
    'endproperty' ( ':' property_identifier )?
  ;
  
property_port_list:
  property_port_item (',' property_port_item )* 
  ;

property_port_item:
  ( attribute_instance )* ( 'local' ( property_lvar_port_direction )? )? property_formal_type
    formal_port_identifier (variable_dimension)* ( '=' property_actual_arg )?
  ;
  
property_lvar_port_direction:
  'input'
  ;
  
property_formal_type:
  sequence_formal_type
  | 'property'
  ;
  
property_spec:
  (clocking_event )? ( 'disable' 'iff' '(' expression_or_dist ')' )? property_expr
  ;
  
property_expr:
  sequence_expr
  | 'strong' '(' sequence_expr ')'
  | 'weak' '(' sequence_expr ')'
  | '(' property_expr ')'
  | 'not' property_expr
  | property_expr 'or' property_expr
  | property_expr 'and' property_expr
  | sequence_expr '|->' property_expr
  | sequence_expr '|=>' property_expr
  | 'if' '(' expression_or_dist ')' property_expr ( 'else' property_expr )?
  | 'case' '(' expression_or_dist ')' property_case_item ( property_case_item )* 'endcase'
  | sequence_expr '#-#' property_expr
  | sequence_expr '#=#' property_expr
  | 'nexttime' property_expr
  | 'nexttime' '[' constant_expression ']' property_expr
  | 's_nexttime' property_expr
  | 's_nexttime' '[' constant_expression ']' property_expr
  | 'always' property_expr
  | 'always' '[' cycle_delay_const_range_expression ']' property_expr
  | 's_always' '[' constant_range ']' property_expr
  | 's_eventually' property_expr
  | 'eventually' '[' constant_range ']' property_expr
  | 's_eventually' '[' cycle_delay_const_range_expression ']' property_expr
  | property_expr 'until' property_expr
  | property_expr 's_until' property_expr
  | property_expr 'until_with' property_expr
  | property_expr 's_until_with' property_expr
  | property_expr 'implies' property_expr
  | property_expr 'iff' property_expr
  | 'accept_on' '(' expression_or_dist ')' property_expr
  | 'reject_on' '(' expression_or_dist ')' property_expr
  | 'sync_accept_on' '(' expression_or_dist ')' property_expr
  | 'sync_reject_on' '(' expression_or_dist ')' property_expr
  | property_instance
  | clocking_event property_expr
  ;
  
property_case_item:
  expression_or_dist ( ',' expression_or_dist )* ':' property_expr ( ';' )?
  | 'default' ( ':' )? property_expr ( ';' )?
  ;
  
sequence_declaration:
  'sequence' sequence_identifier ( '(' ( sequence_port_list )? ')' )? ';'
    ( assertion_variable_declaration )*
    sequence_expr ( ';' )?   
    'endsequence' ( ':' sequence_identifier )?
  ;
  
sequence_port_list:
  sequence_port_item (',' sequence_port_item)*
  ;
  
sequence_port_item:
  ( attribute_instance ) ( 'local' ( sequence_lvar_port_direction )? )? sequence_formal_type
  formal_port_identifier (variable_dimension)* ( '=' sequence_actual_arg )?
  ;
  
sequence_lvar_port_direction: 
  'input' | 'inout' | 'output'
  ;
  
sequence_formal_type:
  data_type_or_implicit
  | 'sequence'
  | 'untyped'
  ;
  
sequence_expr:
  cycle_delay_range sequence_expr ( cycle_delay_range sequence_expr )*
  | sequence_expr cycle_delay_range sequence_expr ( cycle_delay_range sequence_expr )*
  | expression_or_dist ( boolean_abbrev )?
  | sequence_instance ( sequence_abbrev )?
  | '(' sequence_expr (',' sequence_match_item )* ')' ( sequence_abbrev )?
  | sequence_expr 'and' sequence_expr
  | sequence_expr 'intersect' sequence_expr
  | sequence_expr 'or' sequence_expr
  | 'first_match' '(' sequence_expr (',' sequence_match_item)* ')'
  | expression_or_dist 'throughout' sequence_expr
  | sequence_expr 'within' sequence_expr
  | clocking_event sequence_expr
  ;
  
cycle_delay_range:
  '##' constant_primary
  | '##' ( cycle_delay_const_range_expression )?
  | '##[*]'
  | '##[+]'
  ;
  
sequence_method_call:
  sequence_instance '.' method_identifier
  ;
  
sequence_match_item:
  operator_assignment
  | inc_or_dec_expression
  | subroutine_call
  ;
  
sequence_instance:
  ps_or_hierarchical_sequence_identifier ( '(' ( sequence_list_of_arguments )? ')' )?
  ;
  
sequence_list_of_arguments:
  (sequence_actual_arg)? ( ',' (sequence_actual_arg)? )* ( ',' '.' identifier '(' (sequence_actual_arg)? ')' )*
  | '.' identifier '(' (sequence_actual_arg)? ')' ( ',' '.' identifier '(' (sequence_actual_arg)? ')' )*
  ;
  
sequence_actual_arg:
  event_expression
  | sequence_expr
  ;
  
boolean_abbrev:
  consecutive_repetition
  | non_consecutive_repetition
  | goto_repetition
  ;
  
sequence_abbrev: 
  consecutive_repetition
  ;
consecutive_repetition:
  '[*' const_or_range_expression ']'
  | '[*]'
  | '[+]'
  ;
  
non_consecutive_repetition: 
  '[=' const_or_range_expression ']'
  ;
  
goto_repetition: 
  '[->' const_or_range_expression ']'
  ;
  
const_or_range_expression:
  constant_expression
  | cycle_delay_const_range_expression
  ;
  
cycle_delay_const_range_expression:
  constant_expression ':' constant_expression
  | constant_expression ':' '$'
  ;
  
expression_or_dist: 
  expression ( 'dist' '{' dist_list '}' )?
  ;
  
assertion_variable_declaration:
  var_data_type list_of_variable_decl_assignments ';'
  ;
  
let_declaration:
  'let' let_identifier ( '(' ( let_port_list )? ')' )? '=' expression ';'
  ;
  
let_identifier:
  identifier
  ;
  
let_port_list:
  let_port_item (',' let_port_item)*
  ;
  
let_port_item:
  ( attribute_instance )* let_formal_type formal_port_identifier ( variable_dimension )* ( '=' expression )?
  ;
  
let_formal_type:
  data_type_or_implicit
  | 'untyped'
  ;
  
let_expression:
  ( package_scope )? let_identifier ( '(' ( let_list_of_arguments )? ')' )?
  ;
  
let_list_of_arguments:
  ( let_actual_arg )? (',' ( let_actual_arg )? )* (',' '.' identifier '(' ( let_actual_arg )? ')' )*
  | '.' identifier '(' ( let_actual_arg )? ')' ( ',' '.' identifier '(' ( let_actual_arg )? ')' )*
  ;
  
let_actual_arg:
  expression 
  ;
 
//***********************************************************************
//* TODO: A.2.11 Covergroup declarations
//***********************************************************************

//***************************************************************************
//* A.3 Primitive instances
//***************************************************************************

//***********************************************************************
//* TODO: A.3.1 Primitive instantiation and instances
//***********************************************************************

//***********************************************************************
//* TODO: A.3.2 Primitive strengths
//***********************************************************************

//***********************************************************************
//* TODO: A.3.3 Primitive terminals
//***********************************************************************

//***********************************************************************
//* TODO: A.3.4 Primitive gate and switch types
//***********************************************************************

//***************************************************************************
//* A.4 Instantiations
//***************************************************************************

//*************************************************************************
//* A.4.1 Instantiation
//*************************************************************************

//***********************************************************************
//* A.4.1.1 Module instantiation
//***********************************************************************
module_instantiation:
  module_identifier ( parameter_value_assignment )? hierarchical_instance ( ',' hierarchical_instance )* ';'
  ;
  
parameter_value_assignment: 
  '#' '(' ( list_of_parameter_assignments )? ')'
  ;

list_of_parameter_assignments:
  ordered_parameter_assignment ( ',' ordered_parameter_assignment )*
  | named_parameter_assignment ( ',' named_parameter_assignment )*
  ;
  
ordered_parameter_assignment: 
  param_expression
  ;
  
named_parameter_assignment: 
  '.' parameter_identifier '(' ( param_expression )? ')'
  ;
  
hierarchical_instance: 
  name_of_instance '(' ( list_of_port_connections )? ')'
  ;
  
name_of_instance: 
  instance_identifier ( unpacked_dimension )*
  ;
  
list_of_port_connections:
  ordered_port_connection ( ',' ordered_port_connection )*
  | named_port_connection ( ',' named_port_connection )*
  ; 
ordered_port_connection: 
  ( attribute_instance )* ( expression )?
  ;
  
named_port_connection:
  ( attribute_instance )* '.' port_identifier ( '(' ( expression )? ')' )?
  | ( attribute_instance ) '.*'
  ;

//***********************************************************************
//* A.4.1.2 Interface instantiation
//***********************************************************************

interface_instantiation:
  interface_identifier ( parameter_value_assignment )? hierarchical_instance ( ',' hierarchical_instance )* ';'
  ;

//***********************************************************************
//* A.4.1.3 Program instantiation
//***********************************************************************

program_instantiation:
  program_identifier ( parameter_value_assignment )? hierarchical_instance ( ',' hierarchical_instance )* ';'
  ;

//***********************************************************************
//* A.4.1.4 Checker instantiation
//***********************************************************************
checker_instantiation:
  ps_checker_identifier name_of_instance '(' (list_of_checker_port_connections)? ')' ';'
  ;
  
list_of_checker_port_connections:
  ordered_checker_port_connection ( ',' ordered_checker_port_connection )*
  | named_checker_port_connection ( ',' named_checker_port_connection )*
  ;
  
ordered_checker_port_connection: 
  ( attribute_instance )* ( property_actual_arg )?
  ;
  
named_checker_port_connection:
  ( attribute_instance )* '.' formal_port_identifier ( '(' ( property_actual_arg )? ')' )?
  | ( attribute_instance ) '.*'
  ;

//*************************************************************************
//* A.4.2 Generated instantiation
//*************************************************************************
generate_region:
  'generate' ( generate_item )* 'endgenerate'
  ;
  
loop_generate_construct:
  'for' '(' genvar_initialization ';' genvar_expression ';' genvar_iteration ')'
    generate_block
  ;
  
genvar_initialization:
  ( 'genvar' )? genvar_identifier '=' constant_expression
  ;
  
genvar_iteration:
  genvar_identifier assignment_operator genvar_expression
  | inc_or_dec_operator genvar_identifier
  | genvar_identifier inc_or_dec_operator
  ;
  
conditional_generate_construct:
  if_generate_construct
  | case_generate_construct
  ;
  
if_generate_construct:
  'if' '(' constant_expression ')' generate_block ( 'else' generate_block )?
  ;
  
case_generate_construct:
  'case' '(' constant_expression ')' case_generate_item ( case_generate_item )* 'endcase'
  ;
  
case_generate_item:
  constant_expression ( ',' constant_expression )* ':' generate_block
  | 'default' ( ':' )? generate_block
  ;
  
generate_block:
  generate_item
  | ( generate_block_identifier ':' )? 'begin' ( ':' generate_block_identifier )?
    ( generate_item )*
    'end' ( ':' generate_block_identifier )?
  ;
  
generate_item:
  module_or_generate_item
  | interface_or_generate_item
  | checker_or_generate_item 
  ;

//***************************************************************************
//* A.4 UDP declaration and instantiation
//***************************************************************************

//*************************************************************************
//* A.5.1 UDP declaration
//*************************************************************************

//*************************************************************************
//* A.5.2 UDP ports
//*************************************************************************

//*************************************************************************
//* A.5.3 UDP body
//*************************************************************************

//*************************************************************************
//* A.5.4 UDP instantiation
//*************************************************************************

//***************************************************************************
//* A.6 Behavioral statements
//***************************************************************************

//*************************************************************************
//* A.6.1 Continuous assignment and net alias statements
//*************************************************************************

continuous_assign:
  'assign' ( drive_strength )? ( delay3 )? list_of_net_assignments ';'
  | 'assign' ( delay_control )? list_of_variable_assignments ';'
  ;
  
list_of_net_assignments: 
  net_assignment ( ',' net_assignment )*
  ;
  
list_of_variable_assignments: 
  variable_assignment ( ',' variable_assignment )*
  ;
  
net_alias: 
  'alias' net_lvalue '=' net_lvalue ( '=' net_lvalue )* ';'
  ;
    
net_assignment: 
  net_lvalue '=' expression
  ;

//*************************************************************************
//* A.6.2 Procedural blocks and assignments
//*************************************************************************

initial_construct: 
  'initial' statement_or_null
  ;
  
always_construct: 
  always_keyword statement
  ;
  
always_keyword: 
  'always' | 'always_comb' | 'always_latch' | 'always_ff'
  ;
  
final_construct: 
  'final' function_statement
  ;
  
blocking_assignment:
  variable_lvalue '=' delay_or_event_control expression
  | nonrange_variable_lvalue '=' dynamic_array_new
  | ( implicit_class_handle '.' | class_scope | package_scope )? hierarchical_variable_identifier
    select '=' class_new
  | operator_assignment
  ;
  
operator_assignment: 
  variable_lvalue assignment_operator expression
  ;
  
assignment_operator:
  '=' | '+=' | '-=' | '*=' | '/=' | '%=' | '&=' | '|=' | '^=' | '<<=' | '>>=' | '<<<=' | '>>>='
  ;
  
nonblocking_assignment:
  variable_lvalue '<=' ( delay_or_event_control )? expression
  ;
  
procedural_continuous_assignment:
  'assign' variable_assignment
  | 'deassign' variable_lvalue
  | 'force' variable_assignment
  | 'force' net_assignment
  | 'release' variable_lvalue
  | 'release' net_lvalue
  ;
  
variable_assignment: 
  variable_lvalue '=' expression 
  ;
  

//*************************************************************************
//* A.6.3 Parallel and sequential blocks
//*************************************************************************

action_block:
  statement_or_null
  | ( statement )? 'else' statement_or_null
  ;
  
seq_block:
  'begin' ( ':' block_identifier )? ( block_item_declaration )* ( statement_or_null )*
  'end' ( ':' block_identifier )?
  ;
  
par_block:
  'fork' ( ':' block_identifier )? ( block_item_declaration )* ( statement_or_null )*
  join_keyword ( ':' block_identifier )?
  ;
  
join_keyword: 
  'join' | 'join_any' | 'join_none'
  ;

//*************************************************************************
//* A.6.4 Statements
//*************************************************************************
statement_or_null:
  statement
  | null_statement
  ;
  
statement: 
  ( block_identifier ':' )? ( attribute_instance )* statement_item
  ;
  
null_statement:
  ( attribute_instance )* ';'
  ;
  
statement_item:
  blocking_assignment ';'
  | nonblocking_assignment ';'
  | procedural_continuous_assignment ';'
  | case_statement
  | conditional_statement
  | inc_or_dec_expression ';'
  | subroutine_call_statement
  | disable_statement
  | event_trigger
  | loop_statement
  | jump_statement
  | par_block
  | procedural_timing_control_statement
  | seq_block
  | wait_statement
  | procedural_assertion_statement
  | clocking_drive ';'
  | randsequence_statement
  | randcase_statement
  | expect_property_statement
  ;
  
function_statement: 
  statement
  ;

function_statement_or_null:
  function_statement
  | ( attribute_instance )* ';'
  ;
  
variable_identifier_list: 
  variable_identifier ( ',' variable_identifier )*
  ;

//*************************************************************************
//* A.6.5 Timing control statements
//*************************************************************************
procedural_timing_control_statement:
  procedural_timing_control statement_or_null
  ;
  
delay_or_event_control:
  delay_control
  | event_control
  | 'repeat' '(' expression ')' event_control
  ;
  
delay_control:
  '#' delay_value
  | '#' '(' mintypmax_expression ')'
  ;
  
event_control:
  '@' hierarchical_event_identifier
  | '@' '(' event_expression ')'
  | '@*'
  | '@' '(*)'
  | '@' ps_or_hierarchical_sequence_identifier
  ;
  
event_expression:
  ( edge_identifier )? expression ( 'iff' expression )?
//TODO:  | sequence_instance ( 'iff' expression )?
  | event_expression 'or' event_expression
  | event_expression ',' event_expression
  | '(' event_expression ')'
  ;
  
procedural_timing_control:
  delay_control
  | event_control
  | cycle_delay
  ;
  
jump_statement:
  'return' ( expression )? ';'
  | 'break' ';'
  | 'continue' ';'
  ;
  
wait_statement:
  'wait' '(' expression ')' statement_or_null
  | 'wait' 'fork' ';'
  | 'wait_order' '(' hierarchical_identifier ( ',' hierarchical_identifier )* ')' action_block
  ;
  
event_trigger:
  '->' hierarchical_event_identifier ';'
  |'->>' ( delay_or_event_control )? hierarchical_event_identifier ';'
  ;
  
disable_statement:
  'disable' hierarchical_task_identifier ';'
  | 'disable' hierarchical_block_identifier ';'
  | 'disable' 'fork' ';'
  ;

//*************************************************************************
//* A.6.6 Conditional statements
//*************************************************************************
conditional_statement:
  ( unique_priority )? 'if' '(' cond_predicate ')' statement_or_null
  ('else' 'if' '(' cond_predicate ')' statement_or_null )*
  ( 'else' statement_or_null )?
  ;
  
unique_priority: 
  'unique' | 'unique0' | 'priority'
  ;
  
cond_predicate:
  expression_or_cond_pattern ( '&&&' expression_or_cond_pattern )*
  ;
  
expression_or_cond_pattern:
  expression | cond_pattern
  ;
  
cond_pattern: 
  expression 'matches' pattern 
  ;

//*************************************************************************
//* TODO: A.6.7 Case statements
//*************************************************************************
case_statement:
  ( unique_priority )? case_keyword '(' case_expression ')'
    case_item ( case_item )* 'endcase'
  | ( unique_priority )? case_keyword '(' case_expression ')' 'matches'
    case_pattern_item ( case_pattern_item )* 'endcase'
  | ( unique_priority )? 'case' '(' case_expression ')' 'inside'
    case_inside_item ( case_inside_item )* 'endcase'
  ;
    
case_keyword: 
  'case' | 'casez' | 'casex'
  ;
  
case_expression: 
  expression
  ;
  
case_item:
  case_item_expression ( ',' case_item_expression )* ':' statement_or_null
  | 'default' ( ':' )? statement_or_null
  ;
  
case_pattern_item:
  pattern ( '&&&' expression )? ':' statement_or_null
  | 'default' ( ':' )? statement_or_null
  ;
  
case_inside_item:
  open_range_list ':' statement_or_null
  | 'default' ( ':' )? statement_or_null
  ;
  
case_item_expression: 
  expression 
  ;
  
randcase_statement:
  'randcase' randcase_item ( randcase_item )* 'endcase'
  ;
  
randcase_item: 
  expression ':' statement_or_null
  ;
  
open_range_list: 
  open_value_range ( ',' open_value_range )*
  ;
  
open_value_range: 
  value_range
  ;

//***********************************************************************
//* A.6.7.1 Patterns
//***********************************************************************

pattern:
  '.' variable_identifier
  | '.*'
  | constant_expression
  | 'tagged' member_identifier ( pattern )?
  | '\'{' pattern ( ',' pattern )* '}'
  | '\'{' member_identifier ':' pattern ( ',' member_identifier ':' pattern )* '}'
  ;
  
assignment_pattern:
  '\'{' expression ( ',' expression )* '}'
  | '\'{' structure_pattern_key ':' expression ( ',' structure_pattern_key ':' expression )* '}'
  | '\'{' array_pattern_key ':' expression ( ',' array_pattern_key ':' expression )* '}'
  | '\'{' constant_expression '{' expression ( ',' expression )* '}' '}'
  ;
  
structure_pattern_key: 
  member_identifier | assignment_pattern_key
  ;
  
array_pattern_key: 
  constant_expression | assignment_pattern_key
  ;
  
assignment_pattern_key: 
  simple_type | 'default'
  ;
  
assignment_pattern_expression:
  ( assignment_pattern_expression_type )? assignment_pattern
  ;
  
assignment_pattern_expression_type:
  ps_type_identifier
  | ps_parameter_identifier
  | integer_atom_type
  | type_reference
  ;
  
constant_assignment_pattern_expression:
  assignment_pattern_expression
  ;
  
assignment_pattern_net_lvalue:
  '\'{' net_lvalue (',' net_lvalue )* '}'
  ;
  
assignment_pattern_variable_lvalue:
  '\'{' variable_lvalue (',' variable_lvalue )* '}'
  ;

//*************************************************************************
//* A.6.8 Looping statements
//*************************************************************************
loop_statement:
  loop_statement_forever
  | loop_statement_repeat
  | loop_statement_while
  | loop_statement_for
  | loop_statement_do_while
  | loop_statement_foreach
  ;
  
loop_statement_forever:
  'forever' statement_or_null
  ;
  
loop_statement_repeat:
  'repeat' '(' expression ')' statement_or_null
  ;
  
loop_statement_while:
  'while' '(' expression ')' statement_or_null
  ;
 
loop_statement_for:
  'for' '(' ( for_initialization )? ';' ( expression )? ';' ( for_step )? ')'
    statement_or_null
  ;
  
loop_statement_do_while:
  'do' statement_or_null 'while' '(' expression ')' ';'
  ;
  
loop_statement_foreach:
  'foreach' '(' ps_or_hierarchical_array_identifier ( loop_variables )? ')' statement
  ;

for_initialization:
  list_of_variable_assignments
  | for_variable_declaration ( ',' for_variable_declaration )*
  ;
  
for_variable_declaration:
  ( 'var' )? data_type variable_identifier '=' expression ( ',' variable_identifier '=' expression )*
  ;
  
for_step: 
  for_step_assignment ( ',' for_step_assignment )*
  ;
  
for_step_assignment:
  operator_assignment
  | inc_or_dec_expression
  | function_subroutine_call
  ;
  
loop_variables: 
  ( index_variable_identifier )? ( ',' ( index_variable_identifier )? )*
  ; 

//*************************************************************************
//* A.6.9 Subroutine call statements
//*************************************************************************
subroutine_call_statement:
  subroutine_call ';'
  | 'void' '\'' '(' function_subroutine_call ')' ';'
  ;

//*************************************************************************
//* A.6.10 Assertion statements
//*************************************************************************
assertion_item:
  concurrent_assertion_item
  | deferred_immediate_assertion_item
  ;
  
deferred_immediate_assertion_item: 
  ( block_identifier ':' )? deferred_immediate_assertion_statement
  ;
  
procedural_assertion_statement:
  concurrent_assertion_statement
  | immediate_assertion_statement
//TODO:  | checker_instantiation
  ;
  
immediate_assertion_statement:
  simple_immediate_assertion_statement
  | deferred_immediate_assertion_statement
  ;
  
simple_immediate_assertion_statement:
  simple_immediate_assert_statement
  | simple_immediate_assume_statement
  | simple_immediate_cover_statement
  ;
  
simple_immediate_assert_statement:
  'assert' '(' expression ')' action_block
  ;
  
simple_immediate_assume_statement:
  'assume' '(' expression ')' action_block
  ;
  
simple_immediate_cover_statement:
  'cover' '(' expression ')' statement_or_null
  ;
  
deferred_immediate_assertion_statement:
  deferred_immediate_assert_statement
  | deferred_immediate_assume_statement
  | deferred_immediate_cover_statement
  ;
  
deferred_immediate_assert_statement:
  'assert' '#0' '(' expression ')' action_block
  | 'assert' 'final' '(' expression ')' action_block
  ;
  
deferred_immediate_assume_statement:
  'assume' '#0' '(' expression ')' action_block
  | 'assume' 'final' '(' expression ')' action_block
  ;
  
deferred_immediate_cover_statement:
  'cover' '#0' '(' expression ')' statement_or_null
  | 'cover' 'final' '(' expression ')' statement_or_null 
  ;

//*************************************************************************
//* A.6.11 Clocking block
//*************************************************************************
clocking_declaration: 
  ( 'default' )? 'clocking' ( clocking_identifier )? clocking_event ';'
    ( clocking_item )*
    'endclocking' ( ':' clocking_identifier )?
  | 'global' 'clocking' ( clocking_identifier )? clocking_event ';' 'endclocking' ( ':' clocking_identifier )?
  ;
  
clocking_event:
  '@' identifier
  | '@' '(' event_expression ')'
  ;
  
clocking_item:
  'default' default_skew ';'
  | clocking_direction list_of_clocking_decl_assign ';'
  | ( attribute_instance )* assertion_item_declaration
  ;
  
default_skew:
  'input' clocking_skew
  | 'output' clocking_skew
  | 'input' clocking_skew 'output' clocking_skew
  ;
  
clocking_direction:
  'input' ( clocking_skew )?
  | 'output' ( clocking_skew )?
  | 'input' ( clocking_skew )? 'output' ( clocking_skew )?
  | 'inout'
  ;
  
list_of_clocking_decl_assign: 
  clocking_decl_assign ( ',' clocking_decl_assign )*
  ;
  
clocking_decl_assign: 
  signal_identifier ( '=' expression )?
  ;
  
clocking_skew:
  edge_identifier ( delay_control )?
  | delay_control
  ;
  
clocking_drive:
  clockvar_expression '<=' ( cycle_delay )? expression
  ;
  
cycle_delay:
  '##' integral_number
  | '##' identifier
  | '##' '(' expression ')'
  ;
  
clockvar: 
  hierarchical_identifier
  ;
  
clockvar_expression: 
  clockvar select 
  ;

//*************************************************************************
//* A.6.12 Randsequence
//*************************************************************************

randsequence_statement: 
  'randsequence' '(' ( production_identifier )? ')'
    production ( production )*
    'endsequence'
  ;
  
production: 
  ( data_type_or_void )? production_identifier ( '(' tf_port_list ')' )? ':' rs_rule ( '|' rs_rule )* ';'
  ;
  
rs_rule: 
  rs_production_list ( ':=' weight_specification ( rs_code_block )? )?
  ;
  
rs_production_list:
  rs_prod ( rs_prod )*
  | 'rand' 'join' ( '(' expression ')' )? production_item production_item ( production_item )*
  ;
  
weight_specification:
  integral_number
  | ps_identifier
  | '(' expression ')'
  ;
  
rs_code_block: 
  '{' ( data_declaration )* ( statement_or_null )* '}'
  ;
  
rs_prod:
  production_item
  | rs_code_block
  | rs_if_else
  | rs_repeat
  | rs_case
  ;
  
production_item: 
  production_identifier ( '(' list_of_arguments ')' )?
  ;
  
rs_if_else: 
  'if' '(' expression ')' production_item ( 'else' production_item )?
  ;
  
rs_repeat: 
  'repeat' '(' expression ')' production_item
  ;
  
rs_case: 
  'case' '(' case_expression ')' rs_case_item ( rs_case_item )* 'endcase'
  ;
  
rs_case_item:
  case_item_expression ( ',' case_item_expression )* ':' production_item ';'
  | 'default' ( ':' )? production_item ';'
  ;

//***************************************************************************
//* A.7 Specify section
//***************************************************************************

//*************************************************************************
//* A.7.1 Specify block declaration
//*************************************************************************

specify_block: 
  'specify' ( specify_item )* 'endspecify'
  ;
  
specify_item:
  specparam_declaration
  | pulsestyle_declaration
  | showcancelled_declaration
  | path_declaration
//TODO:  | system_timing_check
  ;
  
pulsestyle_declaration:
  'pulsestyle_onevent' list_of_path_outputs ';'
  | 'pulsestyle_ondetect' list_of_path_outputs ';'
  ;
  
showcancelled_declaration:
  'showcancelled' list_of_path_outputs ';'
  | 'noshowcancelled' list_of_path_outputs ';'
  ;

//*************************************************************************
//* A.7.2 Specify path declarations
//*************************************************************************
path_declaration:
  simple_path_declaration ';'
  | edge_sensitive_path_declaration ';'
  | state_dependent_path_declaration ';'
  ;
  
simple_path_declaration:
  parallel_path_description '=' path_delay_value
  | full_path_description '=' path_delay_value
  ;
  
parallel_path_description:
  '(' specify_input_terminal_descriptor ( polarity_operator )? '=>' specify_output_terminal_descriptor ')'
  ;
  
full_path_description:
  '(' list_of_path_inputs ( polarity_operator )? '*>' list_of_path_outputs ')'
  ;
  
list_of_path_inputs:
  specify_input_terminal_descriptor ( ',' specify_input_terminal_descriptor )*
  ;
  
list_of_path_outputs:
  specify_output_terminal_descriptor ( ',' specify_output_terminal_descriptor )*
  ;
  
//*************************************************************************
//* A.7.3 Specify block terminals
//*************************************************************************
specify_input_terminal_descriptor:
  input_identifier ( '[' constant_range_expression ']' )?
  ;
  
specify_output_terminal_descriptor:
  output_identifier ( '[' constant_range_expression ']' )?
  ;
  
input_identifier: 
  input_port_identifier | inout_port_identifier | interface_identifier '.' port_identifier
  ;
  
output_identifier: 
  output_port_identifier | inout_port_identifier | interface_identifier '.' port_identifier 
  ;

//*************************************************************************
//* A.7.4 Specify path delays
//*************************************************************************
path_delay_value:
  list_of_path_delay_expressions
  | '(' list_of_path_delay_expressions ')'
  ;
  
list_of_path_delay_expressions:
  t_path_delay_expression
  | trise_path_delay_expression ',' tfall_path_delay_expression
  | trise_path_delay_expression ',' tfall_path_delay_expression ',' tz_path_delay_expression
  | t01_path_delay_expression ',' t10_path_delay_expression ',' t0z_path_delay_expression ','
    tz1_path_delay_expression ',' t1z_path_delay_expression ',' tz0_path_delay_expression
  | t01_path_delay_expression ',' t10_path_delay_expression ',' t0z_path_delay_expression ','
    tz1_path_delay_expression ',' t1z_path_delay_expression ',' tz0_path_delay_expression ','
    t0x_path_delay_expression ',' tx1_path_delay_expression ',' t1x_path_delay_expression ','
    tx0_path_delay_expression ',' txz_path_delay_expression ',' tzx_path_delay_expression
  ;
    
t_path_delay_expression: 
  path_delay_expression
  ;
  
trise_path_delay_expression: 
  path_delay_expression
  ;
  
tfall_path_delay_expression: 
  path_delay_expression
  ;
  
tz_path_delay_expression: 
  path_delay_expression
  ;
  
t01_path_delay_expression: 
  path_delay_expression
  ;
  
t10_path_delay_expression: 
  path_delay_expression
  ;
  
t0z_path_delay_expression: 
  path_delay_expression
  ;
  
tz1_path_delay_expression: 
  path_delay_expression
  ;
  
t1z_path_delay_expression: 
  path_delay_expression
  ;
  
tz0_path_delay_expression: 
  path_delay_expression
  ;
  
t0x_path_delay_expression: 
  path_delay_expression
  ;
  
tx1_path_delay_expression: 
  path_delay_expression
  ;
  
t1x_path_delay_expression: 
  path_delay_expression
  ;
  
tx0_path_delay_expression: 
  path_delay_expression
  ;
  
txz_path_delay_expression: 
  path_delay_expression
  ;
  
tzx_path_delay_expression: 
  path_delay_expression
  ;
  
path_delay_expression: 
  constant_mintypmax_expression
  ;
  
edge_sensitive_path_declaration:
  parallel_edge_sensitive_path_description '=' path_delay_value 
  | full_edge_sensitive_path_description '=' path_delay_value
  ;
  
parallel_edge_sensitive_path_description:
  '(' ( edge_identifier )? specify_input_terminal_descriptor ( polarity_operator )? '=>'
    '(' specify_output_terminal_descriptor ( polarity_operator )? ':' data_source_expression ')' ')'
  ;
    
full_edge_sensitive_path_description:
  '(' ( edge_identifier )? list_of_path_inputs ( polarity_operator )? '*>'
    '(' list_of_path_outputs ( polarity_operator )? ':' data_source_expression ')' ')'
  ;
  
data_source_expression: 
  expression
  ;
  
edge_identifier: 
  'posedge' | 'negedge' | 'edge'
  ;
  
state_dependent_path_declaration:
  'if' '(' module_path_expression ')' simple_path_declaration
  | 'if' '(' module_path_expression ')' edge_sensitive_path_declaration
  | 'ifnone' simple_path_declaration
  ;
  
polarity_operator: 
  '+' | '-'
  ;

//*************************************************************************
//* TODO: A.7.5 System timing checks
//*************************************************************************

//***************************************************************************
//* A.8 Expressions
//***************************************************************************

//*************************************************************************
//* A.8.1 Concatenations
//*************************************************************************

concatenation:
  '{' expression ( ',' expression )* '}'
  ;
  
constant_concatenation:
  '{' constant_expression ( ',' constant_expression )* '}'
  ;
  
constant_multiple_concatenation: 
  '{' constant_expression constant_concatenation '}'
  ;
  
module_path_concatenation: 
  '{' module_path_expression ( ',' module_path_expression )* '}'
  ;
  
module_path_multiple_concatenation: 
  '{' constant_expression module_path_concatenation '}'
  ;
  
multiple_concatenation: 
  '{' expression concatenation '}'
  ;
  
streaming_concatenation: 
  '{' stream_operator ( slice_size )? stream_concatenation '}'
  ;
  
stream_operator: 
  '>>' | '<<'
  ;
  
slice_size: 
  simple_type | constant_expression
  ;
  
stream_concatenation: 
  '{' stream_expression ( ',' stream_expression )* '}'
  ;
  
stream_expression: 
  expression ( 'with' '[' array_range_expression ']' )?
  ;
  
array_range_expression:
  expression
  | expression ':' expression
  | expression '+:' expression
  | expression '-:' expression
  ;
  
empty_queue: 
  '{' '}'
  ;

//*************************************************************************
//* A.8.2 Subroutine calls
//*************************************************************************
constant_function_call: 
  function_subroutine_call
  ;
  
tf_call: 
  ps_or_hierarchical_tf_identifier ( attribute_instance )* ( '(' list_of_arguments ')' )?
  ;
  
system_tf_call:
  system_tf_identifier ( '(' list_of_arguments ')' )? 
  | system_tf_identifier '(' data_type ( ',' expression )? ')'
  ;
  
subroutine_call:
  tf_call
  | system_tf_call
  | method_call
  | ( 'std' '::' )? randomize_call
  ;
  
function_subroutine_call: 
  subroutine_call
  ;
  
list_of_arguments:
  ( expression )? ( ',' ( expression )? )* ( ',' '.' identifier '(' ( expression )? ')' )*
  | '.' identifier '(' ( expression )? ')' ( ',' '.' identifier '(' ( expression )? ')' )*
  ;
  
method_call: 
  method_call_root '.' method_call_body
  ;

method_call_body:
  method_identifier ( attribute_instance )* ( '(' list_of_arguments ')' )?
  | built_in_method_call
  ;
  
built_in_method_call:
  array_manipulation_call
  | randomize_call
  ;
  
array_manipulation_call:
  array_method_name ( attribute_instance )*
  ( '(' list_of_arguments ')' )?
  ( 'with' '(' expression ')' )?
  ;
  
randomize_call:
  'randomize' ( attribute_instance )*
  ( '(' ( variable_identifier_list | 'null' )? ')' )?
  ( 'with' ( '(' ( identifier_list )? ')' )? constraint_block )?
  ;
  
method_call_root: 
  /* TODO: LR primary |*/ implicit_class_handle
  ;
  
array_method_name:
  method_identifier | 'unique' | 'and' | 'or' | 'xor'
  ;
  
//*************************************************************************
//* A.8.3 Expressions
//*************************************************************************
inc_or_dec_expression:
  inc_or_dec_operator ( attribute_instance )* variable_lvalue
  | variable_lvalue ( attribute_instance )* inc_or_dec_operator
  ;
  
conditional_expression: 
  cond_predicate '?' ( attribute_instance )* expression ':' expression
  ;
  
constant_expression:
  constant_primary
  | unary_operator ( attribute_instance )* constant_primary
  | constant_expression binary_operator ( attribute_instance )* constant_expression
  | constant_expression '?' ( attribute_instance )* constant_expression ':' constant_expression
  ;
  
constant_mintypmax_expression:
  constant_expression
  | constant_expression ':' constant_expression ':' constant_expression
  ;
  
constant_param_expression:
  constant_mintypmax_expression | data_type | '$'
  ;
  
param_expression: 
  mintypmax_expression | data_type | '$'
  ;
  
constant_range_expression:
  constant_expression
  | constant_part_select_range
  ;
  
constant_part_select_range:
  constant_range
  | constant_indexed_range
  ;
  
constant_range: 
  constant_expression ':' constant_expression
  ;
  
constant_indexed_range:
  constant_expression '+:' constant_expression
  | constant_expression '-:' constant_expression
  ;
  
expression:
  primary
  | unary_operator ( attribute_instance )* primary
  | inc_or_dec_expression
  | '(' operator_assignment ')'
  | expression binary_operator ( attribute_instance )* expression
//TODO: LR  | conditional_expression
//TODO: LR  | inside_expression
  | tagged_union_expression
  ;
  
tagged_union_expression:
  'tagged' member_identifier ( expression )?
  ;
  
inside_expression: 
  expression 'inside' '{' open_range_list '}'
  ;
  
value_range:
  expression
  | '[' expression ':' expression ']'
  ;
  
mintypmax_expression:
  expression
  | expression ':' expression ':' expression
  ;
  
module_path_conditional_expression: 
  module_path_expression '?' ( attribute_instance )* module_path_expression ':' module_path_expression
  ; 
  
module_path_expression:
  module_path_primary
  | unary_module_path_operator ( attribute_instance )* module_path_primary
  | module_path_expression binary_module_path_operator ( attribute_instance )* module_path_expression
//TODO: LR  | module_path_conditional_expression
  ; 
  
module_path_mintypmax_expression:
  module_path_expression
  | module_path_expression ':' module_path_expression ':' module_path_expression
  ;
  
part_select_range: 
  constant_range | indexed_range
  ;
  
indexed_range:
  expression '+:' constant_expression
  | expression '-:' constant_expression
  ;
  
genvar_expression: 
  constant_expression 
  ;

//*************************************************************************
//* A.8.4 Primaries
//*************************************************************************
constant_primary:
  primary_literal
  | ps_parameter_identifier constant_select
  | specparam_identifier ( '[' constant_range_expression ']' )?
  | genvar_identifier
  | formal_port_identifier constant_select 
  | ( package_scope | class_scope )? enum_identifier
  | constant_concatenation ( '[' constant_range_expression ']' )?
  | constant_multiple_concatenation ( '[' constant_range_expression ']' )?
  | constant_function_call
  | constant_let_expression
  | '(' constant_mintypmax_expression ')'
//TODO: LR  | constant_cast
  | constant_assignment_pattern_expression
  | type_reference
  ;
  
module_path_primary:
  number
  | identifier
  | module_path_concatenation
  | module_path_multiple_concatenation
  | function_subroutine_call
  | '(' module_path_mintypmax_expression ')'
  ;
  
primary:
  primary_literal
  | ( class_qualifier | package_scope )? hierarchical_identifier select
  | empty_queue
  | concatenation ( '[' range_expression ']' )?
  | multiple_concatenation ( '[' range_expression ']' )?
  | function_subroutine_call
  | let_expression
  | '(' mintypmax_expression ')'
  | cast
  | assignment_pattern_expression
  | streaming_concatenation
  | sequence_method_call
  | 'this'
  | '$'
  | 'null'
  ; 
  
class_qualifier: 
  ( 'local' '::' )? ( implicit_class_handle '.' | class_scope )?
  ;
  
range_expression:
  expression
  | part_select_range
  ;
  
primary_literal: 
  number 
  | time_literal 
  | UNBASED_UNSIZED_LITERAL 
  | string_literal
  ;
  
time_literal:
  UNSIGNED_NUMBER time_unit
  | fixed_point_number time_unit
  ;
  
time_unit: 
  's' 
  | 'ms' 
  | 'us' 
  | 'ns' 
  | 'ps' 
  | 'fs'
  ;
  
implicit_class_handle: 
  'this' 
  | 'super' 
  | 'this' '.' 'super'
  ;
  
bit_select: 
  ('[' ( expression )? ']')*
  ;
  
select:
  ( '{' '.' member_identifier bit_select '}' '.' member_identifier )? bit_select ( '[' part_select_range ']' )?
  ;
  
nonrange_select:
  ( '{' '.' member_identifier bit_select '}' '.' member_identifier )? bit_select
  ;
  
constant_bit_select: 
  '{' ( constant_expression )? '}'
  ;
  
constant_select:
  ( '{' '.' member_identifier constant_bit_select '}' '.' member_identifier )? constant_bit_select
    ( '[' constant_part_select_range ']' )?
  ;
  
constant_cast:
  casting_type '\'' '(' constant_expression ')'
  ;
  
constant_let_expression: 
  let_expression
  ;
  
cast:
  casting_type '\'' '(' expression ')'
  ;
  
//***********************************************************************
//* A.8.5 Expression left-side values
//***********************************************************************
net_lvalue:
  ps_or_hierarchical_net_identifier constant_select
  | '{' net_lvalue ( ',' net_lvalue )* '}'
  | ( assignment_pattern_expression_type )? assignment_pattern_net_lvalue
  ;
  
variable_lvalue:
  ( implicit_class_handle '.' | package_scope )? hierarchical_variable_identifier select
  | '{' variable_lvalue ( ',' variable_lvalue )* '}'
  | ( assignment_pattern_expression_type )? assignment_pattern_variable_lvalue
  | streaming_concatenation
  ;
  
nonrange_variable_lvalue:
  ( implicit_class_handle '.' | package_scope )? hierarchical_variable_identifier nonrange_select 
  ;

//***********************************************************************
//* A.8.6 Operators
//***********************************************************************
unary_operator:
  '+' | '-' | '!' | '~' | '&' | '~&' | '|' | '~|' | '^' | '~^' | '^~'
  ;
  
binary_operator:
  '+' | '-' | '*' | '/' | '%' | '==' | '!=' | '===' | '!==' | '==?' | '!=?' | '&&' | '||' | '**'
  | '<' | '<=' | '>' | '>=' | '&' | '|' | '^' | '^~' | '~^' | '>>' | '<<' | '>>>' | '<<<'
  | '->' | '<->'
  ;
  
inc_or_dec_operator: 
  '++' | '--'
  ;
  
unary_module_path_operator:
  '!' | '~' | '&' | '~&' | '|' | '~|' | '^' | '~^' | '^~'
  ;
  
binary_module_path_operator:
  '==' | '!=' | '&&' | '||' | '&' | '|' | '^' | '^~' | '~^'
  ;
 
//***********************************************************************
//* TODO: A.8.7 Numbers
//***********************************************************************
number:
  integral_number
  | real_number
  ;
  
integral_number:
  decimal_number
  | OCT_VALUE
  | SIZED_OCT_VALUE
  | BIN_VALUE
  | SIZED_BIN_VALUE
  | HEX_VALUE
  | SIZED_HEX_VALUE
  ;
  
decimal_number:
  UNSIGNED_NUMBER 
  | DEC_VALUE
  | SIZED_DEC_VALUE
//TODO:  | ( size )? DECIMAL_BASE X_DIGIT 
//TODO:  | ( size )? DECIMAL_BASE Z_DIGIT 
  ;
  
sign: 
  '+' | '-'
  ;
 
real_number:
  fixed_point_number
  | UNSIGNED_NUMBER ( '.' UNSIGNED_NUMBER )? exp ( sign )? UNSIGNED_NUMBER
  ;
  
fixed_point_number: 
  UNSIGNED_NUMBER '.' UNSIGNED_NUMBER
  ;
  
exp: 
  'e' | 'E'
  ;

UNSIGNED_NUMBER: [0-9][0-9_]*;

BIN_VALUE: ['][ \t\n\r]*[sS]?[bB][0-1xXzZ][0-1xXzZ_]*;
SIZED_BIN_VALUE: [1-9][0-9_]*[ \t\n\r]*['][ \t\n\r]*[sS]?[bB][0-1xXzZ][0-1xXzZ_]*;
OCT_VALUE: ['][ \t\n\r]*[sS]?[oO][0-7xXzZ][0-7xXzZ_]*;
SIZED_OCT_VALUE: [1-9][0-9_]*[ \t\n\r]*['][ \t\n\r]*[sS]?[oO][0-7xXzZ][0-7xXzZ_]*;
HEX_VALUE: ['][ \t\n\r]*[sS]?[hH][0-9a-fA-FxXzZ][0-9a-fA-FxXzZ_]*;
SIZED_HEX_VALUE: [1-9][0-9_]*[ \t\n\r]*['][ \t\n\r]*[sS]?[hH][0-9a-fA-FxXzZ][0-9a-fA-FxXzZ_]*;
DEC_VALUE: ['][ \t\n\r]*[sS]?[dD][0-9][0-9_]*;
SIZED_DEC_VALUE: [1-9][0-9_]*[ \t\n\r]*['][ \t\n\r]*[sS]?[dD][0-9][0-9_]*;

// NON_ZERO_DECIMAL_DIGIT: [1-9];
//decimal_digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
//binary_digit ::= x_digit | z_digit | 0 | 1
//octal_digit ::= x_digit | z_digit | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
//hex_digit ::= x_digit | z_digit | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | a | b | c | d | e | f | A | B | C | D | E | F
X_DIGIT: [xX][xX_]*;
Z_DIGIT: [zZ?][zZ?]*;
UNBASED_UNSIZED_LITERAL: ['][01zZxX];

//***********************************************************************
//* A.8.8 Strings
//***********************************************************************

string_literal: DOUBLE_QUOTED_STRING ;

DOUBLE_QUOTED_STRING : '"' (~ [\n\r])* '"';

//***********************************************************************
//* A.9 General
//***********************************************************************

// A.9.1 Attributes
attribute_instance : 
	'(*' attr_spec ( ',' attr_spec )* '*)'
	;
	
attr_spec : 
	attr_name ( '=' constant_expression )?
	;
	
attr_name : identifier ;

// A.9.2 Comments
WS : [ \t\n\r]+ -> channel (HIDDEN) ;
 
SL_COMMENT 	: '//' .*? '\r'? ('\n'|EOF) -> channel (HIDDEN) ;

ML_COMMENT	: '/*' .*? '*/' -> channel (HIDDEN) ;

//***********************************************************************
//* A.9.3  Identifiers
//***********************************************************************
array_identifier: identifier;
block_identifier: identifier;
bin_identifier: identifier;
C_IDENTIFIER: [a-zA-Z_] [a-zA-Z0-9_]*;
c_identifier: C_IDENTIFIER ; 
cell_identifier: identifier;
checker_identifier: identifier;
class_identifier: identifier;
class_variable_identifier: variable_identifier;
clocking_identifier: identifier;
config_identifier: identifier;
const_identifier: identifier;
constraint_identifier: identifier;
covergroup_identifier: identifier;
covergroup_variable_identifier: variable_identifier;
cover_point_identifier: identifier;
cross_identifier: identifier;
dynamic_array_variable_identifier: variable_identifier;
enum_identifier: identifier;
ESCAPED_ID : '\\' ('\u0021'..'\u007E')+ ~ [ \r\t\n]* ;
escaped_identifier: ESCAPED_ID;
formal_identifier: identifier;
formal_port_identifier: identifier;
function_identifier: identifier;
generate_block_identifier: identifier;
genvar_identifier: identifier;
hierarchical_array_identifier: hierarchical_identifier;
hierarchical_block_identifier: hierarchical_identifier;
hierarchical_event_identifier: hierarchical_identifier;
hierarchical_identifier: ( '$root' '.' )? ( identifier constant_bit_select '.' )* identifier;
hierarchical_net_identifier: hierarchical_identifier;
hierarchical_parameter_identifier: hierarchical_identifier;
hierarchical_property_identifier: hierarchical_identifier;
hierarchical_sequence_identifier: hierarchical_identifier;
hierarchical_task_identifier: hierarchical_identifier;
hierarchical_tf_identifier : hierarchical_identifier;

hierarchical_variable_identifier : hierarchical_identifier;

identifier :
simple_identifier
| escaped_identifier;

index_variable_identifier : identifier;
interface_identifier : identifier;
interface_instance_identifier : identifier;
inout_port_identifier : identifier;
input_port_identifier : identifier;
instance_identifier : identifier;
library_identifier : identifier;
member_identifier : identifier;
method_identifier : identifier;
modport_identifier : identifier;
module_identifier : identifier;
net_identifier : identifier;
net_type_identifier : identifier;
output_port_identifier : identifier;
package_identifier : identifier;

package_scope :
	package_identifier '::'
	| '$unit' '::'
	;
parameter_identifier : identifier;
port_identifier : identifier;
production_identifier : identifier;
program_identifier : identifier;
property_identifier : 
  identifier
  ;

ps_class_identifier: 
  ( package_scope )? class_identifier
  ;

ps_covergroup_identifier: 
  ( package_scope )? covergroup_identifier
  ;

ps_checker_identifier: 
  ( package_scope )? checker_identifier
  ;

ps_identifier : 
  ( package_scope )? identifier
  ;

ps_or_hierarchical_array_identifier :
	( implicit_class_handle '.' | class_scope | package_scope )? hierarchical_array_identifier
	ps_or_hierarchical_net_identifier ':' ( package_scope )? net_identifier | hierarchical_net_identifier
	;
	
ps_or_hierarchical_net_identifier: 
  ( package_scope )? net_identifier 
  | hierarchical_net_identifier	
  ;
  
ps_or_hierarchical_property_identifier :
	( package_scope )? property_identifier
	| hierarchical_property_identifier
	;
	
ps_or_hierarchical_sequence_identifier :
	( package_scope )? sequence_identifier
	| hierarchical_sequence_identifier
	;
	
ps_or_hierarchical_tf_identifier :
	( package_scope )? tf_identifier
	| hierarchical_tf_identifier
	;
	
ps_parameter_identifier : 
	( package_scope | class_scope )? parameter_identifier
	| ( generate_block_identifier ( '[' constant_expression ']' )? '.' )* parameter_identifier
	;

ps_type_identifier : 
  ( 'local' '::' | package_scope )? type_identifier
  ;
  
sequence_identifier : 
  identifier
  ;
  
signal_identifier : 
  identifier
  ;

ID : [a-zA-Z_] [a-zA-Z0-9_$]* ;

simple_identifier : 
  ID | C_IDENTIFIER
  ;
  
specparam_identifier: 
  identifier
  ;
  
STF_ID : 
  [$][a-zA-Z0-9_$][a-zA-Z0-9_$]*
  ;
  
system_tf_identifier : 
  STF_ID 
  ;
  
task_identifier : identifier;
tf_identifier : identifier;
terminal_identifier : identifier;
topmodule_identifier : identifier;
type_identifier : identifier;
udp_identifier : identifier;
variable_identifier : identifier;

