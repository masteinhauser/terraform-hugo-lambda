# Lambda function to call hugo

resource "aws_lambda_function" "hugo_lambda" {
    /*
    # Not working, see https://github.com/hashicorp/terraform/issues/4931
    s3_bucket = "${aws_s3_bucket.lambda.id}"
    s3_key = "${aws_s3_bucket_object.lambda.id}"
    */
    depends_on = ["null_resource.lambda_download"]
    filename = "artifacts/lambda.zip"
    function_name = "hugo-lambda"
    role = "${aws_iam_role.lambda_role.arn}"
    handler = "RunHugo.handler"
    runtime = "nodejs"
    memory_size = 128
    timeout = 30

}

#output "hugo_lambda_arn" { value = "${aws_lambda_function.hugo_lambda.arn}" } // timeout problem.
output "hugo_lambda_name" { value = "${var.root_domain}-lambda"}

# Download hugo lambda function
resource "null_resource" "lambda_download" {
    triggers {
        lambda_function_tar_url = "${var.lambda_function_tar_url}"
        lambda_role = "${aws_iam_role.lambda_role.name}"
    }

    provisioner "local-exec" {
        command = "des=artifacts/lambda.zip; if [ ! -f $des ]; then curl -L -s -o $des ${var.lambda_function_tar_url}; fi"
    }
}

/* 
# Not working, see https://github.com/hashicorp/terraform/issues/4931
# s3 bucket for lambda function
resource "aws_s3_bucket" "lambda" {
    bucket = "lambda.${var.root_domain}"
    force_destroy = true   force_destroy = true
    acl = "private"
    tags {
        Name = "lambda.${var.root_domain}"
    }
}

resource "aws_s3_bucket_object" "lambda" {
    bucket = "${aws_s3_bucket.lambda.id}"
    depends_on = ["null_resource.lambda_download"]
    key = "lambda"
    source = "artifacts/lambda.zip"
}
*/
