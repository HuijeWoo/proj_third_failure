resource "aws_route_table_association" "public" {
  count          = length(var.my_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.route_public.id
}

resource "aws_route_table_association" "web_private" {
  count          = length(var.my_cidr_web_private)
  subnet_id      = element(aws_subnet.web_private.*.id, count.index)
  route_table_id = aws_route_table.route_private.id
}

resource "aws_route_table_association" "was_private" {
  count          = length(var.my_cidr_was_private)
  subnet_id      = element(aws_subnet.was_private.*.id, count.index)
  route_table_id = aws_route_table.route_private.id
}
