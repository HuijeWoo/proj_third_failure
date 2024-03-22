resource "aws_route_table_association" "public" {
  count          = length(var.my_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.route_public.id
}

