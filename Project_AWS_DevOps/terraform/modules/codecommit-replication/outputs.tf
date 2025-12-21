output "lambda_function_arn" {
  description = "ARN of the replication Lambda function"
  value       = aws_lambda_function.replication.arn
}

output "lambda_function_name" {
  description = "Name of the replication Lambda function"
  value       = aws_lambda_function.replication.function_name
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.codecommit_push.arn
}
