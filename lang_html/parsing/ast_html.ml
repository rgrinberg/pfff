(* Yoann Padioleau
 * 
 * Copyright (C) 2009,2010,2011 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)

open Common

module PI = Parse_info

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(* 
 * This file contains the type definitions for a HTML Document, its AST,
 * also called the DOM (Document Object Model) by the W3C.
 * src: http://dev.w3.org/html5/spec/spec.html
 *
 * For the types of the full 'HTML + JS(script) + CSS(style)' see ast_web.ml.
 * For information on characters encoding, ascii, utf-8, etc, see encodings.ml
 * 
 * There are multiple ways to represent an HTML AST:
 *  - just as a tree of 'Element of ... | CdData of ...' (as done in ocamlnet).
 *    This is simple but lack type-checking. Some checking can be done though
 *    by using the spec of a DTD and run a validator.
 *  - a tree with phantom types (as done in xHTML)
 *  - a real AST, with one different constructor per html element, and
 *    precise types for the set of acceptable attributes. Because
 *    the DTD of HTML is complex, such an AST can be quite tedious to write.
 *  - an ocamlduce/cduce AST, which have a type system specially made to 
 *    express the kind of invariants of a DTD.
 * 
 * update: I've added token/info in the html tree so we can at least have 
 *  an AST-based highlighter which is needed for coloring urls as in href
 *  for instance.
 * 
 * The solution used in this module is to define multiple html types 
 * because depending on the usage certain types are more convenient than
 * other.
 * 
 * alternative implementations: 
 * - xHTML.ml: but poor AST, no parsing, and phantom types are tricky
 * - xml-light: just for strict XML and poor AST
 * - pxp: just for strict XML ?
 * - ocamlnet netstring: looks like a very simple html parser, very (too?)
 *    simple AST (checking is done via an external DTD), also support
 *    ascii only (but can go through an ascii encoding of the input stream)
 * - ocigen: use xHTML.ml or ocamlduce to encode html elements, no parsing
 * - cduce/ocamlduce: they say they rely on pxp/expat/xml-light for input.
 *    They have potentially a better AST to work on, a well typed one.
 *    The one in xHTML.ml use phantom types so it's good for ensuring
 *    the well-typed construction of html, but does not help when
 *    we work on the AST, to do pattern matching on it, to have the
 *    exhaustive check of OCaml, etc.
 *  - htcaml: camlp4 on top of xmlm, https://github.com/samoht/htcaml
 *    simple AST
 * - mirage ?
 * - mmm ? 
 * - hevea has a htmllexer.mll, looks quite similar to the one in ocamlnet
 * - efuns has a html mode ? mldonkey ? cameleon ?
 * - ocamlgtk has a small xml lexer (src/xml_lexer.mll)
 * See also http://caml.inria.fr/cgi-bin/hump.fr.cgi?sort=0&browse=49
 * 
 * alternative in other languages:
 *  - the one in firefox, webkit
 *  - a python and php one, http://code.google.com/p/html5lib
 *  - a javascript one, http://ejohn.org/blog/pure-javascript-html-parser/
 * 
 * See also http://en.wikipedia.org/wiki/HTML5
 *)

(*****************************************************************************)
(* The AST related types *)
(*****************************************************************************)

(* ------------------------------------------------------------------------- *)
(* Token/info *)
(* ------------------------------------------------------------------------- *)

type pinfo = Parse_info.token
type info = Parse_info.info
and tok = info
(* a shortcut to annotate some information with token/position information *)
and 'a wrap = 'a * info
 (* with tarzan *)

(* ------------------------------------------------------------------------- *)
(* HTML raw version *)
(* ------------------------------------------------------------------------- *)

type html_raw = HtmlRaw of string 

(* ------------------------------------------------------------------------- *)
(* HTML tree version *)
(* ------------------------------------------------------------------------- *)

(* src: ocamlnet/netstring/nethtml.mli *)
(** The type [document] represents parsed HTML documents:
 *
 * {ul
 * {- [Element (name, args, subnodes)] is an element node for an element of
 *   type [name] (i.e. written [<name ...>...</name>]) with arguments [args]
 *   and subnodes [subnodes] (the material within the element). The arguments
 *   are simply name/value pairs. Entity references (something like [&xy;])
 *   occuring in the values are {b not} resolved.
 *
 *   Arguments without values (e.g. [<select name="x" multiple>]: here,
 *   [multiple] is such an argument) are represented as [(name,name)], i.e. the
 *   name is also returned as value.
 *
 *   As argument names are case-insensitive, the names are all lowercase.}
 * {- [Data s] is a character data node. Again, entity references are contained
 *   as such and not as what they mean.}
 * }
 *
 * Character encodings: The parser is restricted to ASCII-compatible
 * encodings (see the function {!Netconversion.is_ascii_compatible} for
 * a definition). In order to read other encodings, the text must be
 * first recoded to an ASCII-compatible encoding (example below).
 * Names of elements and attributes must additionally be ASCII-only.
 *)

(* src: ocamlnet/netstring/nethtml.mli, extended with pad's wrap and newtype *)
type html_tree = 
  | Element of 
      tag *
      (attr_name * attr_value) list *
      html_tree list
  | Data of string wrap

 and tag = Tag of string wrap
 and attr_name  = Attr of string wrap
 and attr_value = Val  of string wrap

 (* with tarzan *)

(* 
 * TODO
 * type url = Url of string (* actually complicated sublanguage *)
 * type color = Color of string (* ?? *)
 * 
 * ??? tree ? how be precise ? 
 * see xHtml.ml ? but too complicated to build ... shadow type sucks
 *
 * (* aka script *)
 * type javascript = unit
 * 
 * (*aka style *)
 * type css = unit
 *)

(* ------------------------------------------------------------------------- *)
(* HTML full AST version *)
(* ------------------------------------------------------------------------- *)

(* The following type is derived from the grammar in the following book:
 * src: HTML & XHTML definitive guide edition 6 
 *)
type html = Html of attrs * head * body (* | frameset? *)
 and head = Head of attrs
 and body = Body of attrs

 and attrs = tok * (attr_name * attr_value) list

(*
a_content [a] 	::=	heading
 	|	text
a_tag 	::=	<a>
 	 	{a_content}0
 	 	</a>
abbr_tag 	::=	<abbr> text </abbr>
acronym_tag 	::=	<acronym> text </acronym>
address_content 	::=	p_tag
 	|	text
address_tag 	::=	<address>
 	 	{address_content}0
 	 	</address>
applet_content 	::=	{<param>}0
 	 	body_content
applet_tag 	::=	<applet> applet_content </applet>
b_tag 	::=	<b> text </b>
basefont_tag 	::=	<basefont> body_content </basefont>
bdo_tag 	::=	<bdo> text </bdo>
big_tag 	::=	<big> text </big>
blink_tag 	::=	<blink> text </blink>
block 	::=	{block_content}0
block_content 	::=	<isindex>
 	|	basefont_tag
 	|	blockquote_tag
 	|	center_tag
 	|	dir_tag
 	|	div_tag
 	|	dl_tag
 	|	form_tag
 	|	listing_tag
 	|	menu_tag
 	|	multicol_tag
 	 	 
 	|	nobr_tag
 	|	ol_tag
 	|	p_tag
 	|	pre_tag
 	|	table_tag
 	|	ul_tag
 	|	xmp_tag
blockquote_tag 	::=	<blockquote> body_content </blockquote>
body_content 	::=	<bgsound>
 	|	<hr>
 	|	address_tag
 	|	block
 	|	del_tag
 	|	heading
 	|	ins_tag
 	|	layer_tag
 	|	map_tag
 	|	marquee_tag
 	|	text
body_tag 	::=	<body>
 	 	{body_content}0
 	 	</body>
caption_tag 	::=	<caption> body_content </caption>
center_tag 	::=	<center> body_content </center>
cite_tag 	::=	<cite> text </cite>
code_tag 	::=	<code> text </code>
colgroup_content 	::=	{<col>}0
colgroup_tag 	::=	<colgroup>
 	 	colgroup_content
content_style 	::=	abbr_tag
 	|	acronym_tag
 	|	cite_tag
 	|	code_tag
 	|	dfn_tag
 	|	em_tag
 	|	kbd_tag
 	|	q_tag
 	|	strong_tag
 	|	var_tag
dd_tag 	::=	<dd> flow </dd>
del_tag 	::=	<del> flow </del>
dfn_tag 	::=	<dfn> text </dfn>
dir_tag [b] 	::=	<dir>
 	 	{li_tag}
 	 	</dir>
div_tag 	::=	<div> body_content </div>
dl_content 	::=	dt_tag dd_tag
dl_tag 	::=	<dl>
 	 	{dl_content}
 	 	</dl>
dt_tag 	::=	<dt>
 	 	text
 	 	</dt>
em_tag 	::=	<em> text </em>
fieldset_tag 	::=	<fieldset>
 	 	[legend_tag]
 	 	{form_content}0
 	 	</fieldset>
flow 	::=	{flow_content}0
flow_content 	::=	block
 	|	text
font_tag 	::=	<font> style_text </font>
form_content [c] 	::=	<input>
 	|	<keygen>
 	|	body_content
 	|	fieldset_tag
 	|	label_tag
 	|	select_tag
 	|	textarea_tag
form_tag 	::=	<form>
 	 	{form_content}0
 	 	</form>
frameset_content 	::=	<frame>
 	|	noframes_tag
frameset_tag 	::=	<frameset>
 	 	{frameset_content}0
 	 	</frameset>
h1_tag 	::=	<h1> text </h1>
h2_tag 	::=	<h2> text </h2>
h3_tag 	::=	<h3> text </h3>
h4_tag 	::=	<h4> text </h4>
h5_tag 	::=	<h5> text </h5>
 	 	 
h6_tag 	::=	<h6> text </h6>
head_content 	::=	<base>
 	|	<isindex>
 	|	<link>
 	|	<meta>
 	|	<nextid>
 	|	style_tag
 	|	title_tag
head_tag 	::=	<head>
 	 	{head_content}0
 	 	</head>
heading 	::=	h1_tag
 	|	h2_tag
 	|	h3_tag
 	|	h4_tag
 	|	h5_tag
 	|	h6_tag
html_content 	::=	head_tag body_tag
 	|	head_tag frameset_tag
html_document 	::=	html_tag
html_tag 	::=	<html> html_content </html>
i_tag 	::=	<i> text </i>
ilayer_tag 	::=	<ilayer> body_content </ilayer>
ins_tag 	::=	<ins> flow </ins>
kbd_tag 	::=	<kbd> text </kbd>
label_content [d] 	::=	<input>
 	|	body_content
 	|	select_tag
 	|	textarea_tag
label_tag 	::=	<label>
 	 	{label_content}0
 	 	</label>
layer_tag 	::=	<layer> body_content </layer>
legend_tag 	::=	<legend> text </legend>
li_tag 	::=	<li> flow </li>
listing_tag 	::=	<listing> literal_text </listing>
map_content 	::=	{<area>}0
map_tag 	::=	<map> map_content </map>
marquee_tag 	::=	<marquee> style_text </marquee>
menu_tag [e] 	::=	<menu>
 	 	{li_tag}0
 	 	</menu>
multicol_tag 	::=	<multicol> body_content </multicol>
nobr_tag 	::=	<nobr> text </nobr>
noembed_tag 	::=	<noembed> text </noembed>
noframes_tag 	::=	<noframes>
 	 	{body_content}0
 	 	</noframes>
noscript_tag 	::=	<noscript> text </noscript>
object_content 	::=	{<param>}0
 	 	body_content
object_tag 	::=	<object> object_content </object>
ol_tag 	::=	<ol>
 	 	{li_tag}
 	 	</ol>
optgroup_tag 	::=	<optgroup>
 	 	{option_tag}0
 	 	</optgroup>
option_tag 	::=	<option> plain_text </option>
p_tag 	::=	<p> text </p>
physical_style 	::=	b_tag
 	|	bdo_tag
 	|	big_tag
 	|	blink_tag
 	|	font_tag
 	|	i_tag
 	|	s_tag
 	|	small_tag
 	|	span_tag
 	|	strike_tag
 	|	sub_tag
 	|	sup_tag
 	|	tt_tag
 	|	u_tag
pre_content 	::=	<br>
 	|	<hr>
 	|	a_tag
 	|	style_text
pre_tag 	::=	<pre>
 	 	{pre_content}0
 	 	</pre>
q_tag 	::=	<q> text </q>
s_tag 	::=	<s> text </s>
samp_tag 	::=	<samp> text </samp>
script_tag [f] 	::=	<script> plain_text </script>
select_content 	::=	optgroup_tag
 	|	option_tag
select_tag 	::=	<select>
 	 	{select_content}0
 	 	</select>
server_tag [g] 	::=	<server> plain_text </server>
small_tag 	::=	<small> text </small>
span_tag 	::=	<span> text </span>
strike_tag 	::=	<strike> text </strike>
strong_tag 	::=	<strong> text </strong>
style_tag 	::=	<style> plain_text </style>
sub_tag 	::=	<sub> text </sub>
sup_tag 	::=	<sup> text </sup>
table_cell 	::=	td_tag
 	|	th_tag
table_content 	::=	<tbody>
 	|	<tfoot>
 	|	<thead>
 	|	tr_tag
table_tag 	::=	<table>
 	 	[caption_tag]
 	 	{colgroup_tag}0
 	 	{table_content}0
 	 	</table>
td_tag 	::=	<td> body_content </td>
text 	::=	{text_content}0
text_content 	::=	<br>
 	|	<embed>
 	|	<iframe>
 	|	<img>
 	|	<spacer>
 	|	<wbr>
 	|	a_tag
 	|	applet_tag
 	|	content_style
 	|	ilayer_tag
 	|	noembed_tag
 	|	noscript_tag
 	 	 
 	|	object_tag
 	|	physical_style
 	|	plain_text
textarea_tag 	::=	<textarea> plain_text </textarea>
th_tag 	::=	<th> body_content </th>
title_tag 	::=	<title> plain_text </title>
tr_tag 	::=	<tr>
 	 	{table_cell}0
 	 	</tr>
tt_tag 	::=	<tt> text </tt>
u_tag 	::=	<u> text </u>
ul_tag 	::=	<ul>
 	 	{li_tag}
 	 	</ul>
var_tag 	::=	<var> text </var>
xmp_tag 	::=	<xmp> literal_text </xmp>
*)

(* ------------------------------------------------------------------------- *)
(* a small wrapper over ocamlnet *)
type html_tree2 = Nethtml.document list

(*****************************************************************************)
(* Some constructors *)
(*****************************************************************************)

let fakeInfo ?(next_to=None) ?(str="") () = { 
  PI.token = PI.FakeTokStr (str, next_to);
  comments = ();
  transfo = PI.NoTransfo;
  }

(*****************************************************************************)
(* Wrappers *)
(*****************************************************************************)
