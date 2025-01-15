output "created_iam_users_all" {
  value = aws_iam_user.users
  description = "Full list of created users"
}

//======================================================================================================================

output "created_iam_users_id" {
  value = aws_iam_user.users[*].id                  // * <- Select all users from the list
  description = "List of IDs of all created users "
}

//======================================================================================================================

output "map_created_aim_uses_custom" {
  value = [
    for user in aws_iam_user.users:
    "Username: ${user.name} has ARN: ${user.arn}"
  ]
  description = "Username: USER_NAME has ARN: USER_ARN"
}

//======================================================================================================================

output "map_created_iam_users" {
  value = {
    for user in aws_iam_user.users:
    user.unique_id => user.id
  }
  description = "USER_UNIQUE_ID : USER_ID"            // "APSPDSD43KSKD6KDS1" : "Alex"
}

//======================================================================================================================

output "map_list_names_4_characters" {
  value = [
    for x in aws_iam_user.users:
    x.name
    if length(x.name) == 4
  ]
  description = "List of users with a name containing only 4 characters"
}

//======================================================================================================================

output "map_list_of_servers" {
  #  value = aws_instance.servers                    // Print full instances information
  value = {
    for server in aws_instance.servers:
    server.id => server.public_ip                    // Print Map of 'Instance_ID : Public_IP'
  }

  description = "Server info Map in format -> INSTANCE_ID : PUBLIC_IP"

  depends_on = [aws_instance.servers]
}