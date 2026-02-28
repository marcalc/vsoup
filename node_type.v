module vsoup

// NodeType represents the type of a DOM node, matching Lexbor's lxb_dom_node_type_t.
pub enum NodeType {
	undef                  = 0x00
	element                = 0x01
	attribute              = 0x02
	text                   = 0x03
	cdata_section          = 0x04
	entity_reference       = 0x05
	entity                 = 0x06
	processing_instruction = 0x07
	comment                = 0x08
	document               = 0x09
	document_type          = 0x0A
	document_fragment      = 0x0B
	notation               = 0x0C
}
