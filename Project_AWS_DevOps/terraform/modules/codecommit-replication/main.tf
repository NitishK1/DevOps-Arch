# Lambda function for CodeCommit replication
resource "aws_iam_role" "replication_lambda" {
  name = "${var.project_name}-${var.environment}-codecommit-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-codecommit-replication"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy" "replication_lambda_policy" {
  name = "${var.project_name}-${var.environment}-replication-policy"
  role = aws_iam_role.replication_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetTree",
          "codecommit:GetBlob",
          "codecommit:GetDifferences",
          "codecommit:GitPull"
        ]
        Resource = var.source_repository_arn
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:CreateCommit",
          "codecommit:PutFile",
          "codecommit:GitPush"
        ]
        Resource = var.destination_repository_arn
      }
    ]
  })
}

# Lambda function code
resource "aws_lambda_function" "replication" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-${var.environment}-codecommit-replication"
  role          = aws_iam_role.replication_lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 300

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SOURCE_REGION      = var.source_region
      DESTINATION_REGION = var.destination_region
      SOURCE_REPO        = var.source_repository_name
      DESTINATION_REPO   = var.destination_repository_name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-codecommit-replication"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = file("${path.module}/lambda_function.py")
    filename = "index.py"
  }
}

# EventBridge rule to trigger on CodeCommit push
resource "aws_cloudwatch_event_rule" "codecommit_push" {
  name        = "${var.project_name}-${var.environment}-codecommit-push"
  description = "Trigger on CodeCommit push events"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      referenceType = ["branch"]
      referenceName = ["main"]
      repositoryName = [var.source_repository_name]
    }
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-codecommit-push"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.codecommit_push.name
  target_id = "ReplicationLambda"
  arn       = aws_lambda_function.replication.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.replication.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.codecommit_push.arn
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "replication_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.replication.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-replication-lambda-logs"
    Environment = var.environment
    Project     = var.project_name
  }
}
