open Ppxlib

let expand ~ctxt xs =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  let arr = Ast_builder.Default.pexp_array ~loc xs in
  [%expr Vector.fromArray [%e arr]]

let extension =
  Extension.V3.declare "vec" Extension.Context.expression
    Ast_pattern.(single_expr_payload (pexp_array __))
    expand

let rule = Ppxlib.Context_free.Rule.extension extension
let () = Ppxlib.Driver.register_transformation ~rules:[ rule ] "res_vector"
