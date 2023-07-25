locals {
  prefix_name = "ds-test"
}

resource "aws_sqs_queue" "q" {
  name = "${local.prefix_name}-s3-sqs-queue-tf"
}


data "aws_iam_policy_document" "test" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.q.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }
  }
}
/*
resource "aws_sqs_queue" "queue" {
  name   = "${local.prefix_name}-s3-event-notification-queue"
  policy = data.aws_iam_policy_document.queue.json
}
*/
resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.q.id
  policy    = data.aws_iam_policy_document.test.json
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${local.prefix_name}-trigger-bucket-tf"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn     = aws_sqs_queue.q.arn
    name = "${local.prefix_name}-event"
    events        = ["s3:ObjectCreated:*","s3:ObjectRemoved:*"]
  }
}