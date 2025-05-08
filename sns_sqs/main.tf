provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "demo_topic" {
  name = "demo-sns-topic"
}

resource "aws_sqs_queue" "demo_queue" {
  name = "demo-sqs-queue"
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  topic_arn = aws_sns_topic.demo_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.demo_queue.arn
}

resource "aws_sqs_queue_policy" "demo_queue_policy" {
  queue_url = aws_sqs_queue.demo_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.demo_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.demo_topic.arn
          }
        }
      }
    ]
  })
}

output "sns_topic_arn" {
  value = aws_sns_topic.demo_topic.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.demo_queue.url
}