module Layout = {
  let makeProps = (~title: string, ~description: string, ~children: React.element, ()) =>
    {
      "title": title,
      "description": description,
      "children": children,
    }

  @module("@theme/Layout") external make: React.component<'a> = "default"
}
