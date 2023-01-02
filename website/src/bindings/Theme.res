module Layout = {
  type props = {
    title: string,
    description: string,
    children: React.element,
  }

  @module("@theme/Layout") external make: React.component<props> = "default"
}
