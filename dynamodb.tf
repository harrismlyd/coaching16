resource "aws_dynamodb_table" "url_shortener" {
  name         = "coach16-url-shortener"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_id"

  attribute {
    name = "short_id"
    type = "S"
  }

  attribute {
    name = "long_url"
    type = "S"
  }

  attribute {
    name = "hits"
    type = "N"
  }

  tags = {
    Name        = "coach16-dynamodb-table"
  }
}