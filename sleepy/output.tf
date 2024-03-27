output "web_userdata_base64"{
    value = data.aws_instance.web_private.user_data
}

output "web_userdata"{
    value = data.aws_instance.web_private.user_data_base64
}