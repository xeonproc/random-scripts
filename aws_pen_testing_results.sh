#!/bin/bash

queries=(
    "SELECT r.account_id, r.name, r.type, r.records, r.alias_target FROM aws_all.aws_route53_zone AS z, aws_all.aws_route53_record AS r WHERE r.zone_id = z.id AND NOT z.private_zone;"
    #"select CAST(public_ip AS text) as public_ip, account_id from \"aws_all\".\"aws_vpc_eip\""
    #"select dns_name, account_id from \"aws_all\".\"aws_ec2_application_load_balancer\""
    #"select dns_name, account_id from \"aws_all\".\"aws_ec2_classic_load_balancer\""
    #"select dns_name, account_id from \"aws_all\".\"aws_ec2_gateway_load_balancer\""
    #"select dns_name, account_id from \"aws_all\".\"aws_ec2_gateway_load_balancer\""
    #"select dns_name, account_id from \"aws_all\".\"aws_ec2_network_load_balancer\""
    #"select name as public_bucket_name, account_id from \"aws_all\".\"aws_s3_bucket\" where bucket_policy_is_public = true or block_public_policy = false or block_public_acls = false or ignore_public_acls = false"
    #"select db_name, endpoint_address, account_id from \"aws_all\".\"aws_rds_db_instance\" where publicly_accessible = true"
    #"select name, account_id, endpoint, resources_vpc_config->>'EndpointPublicAccess' as endpoint_public_access, resources_vpc_config->>'PublicAccessCidrs' as public_access_cidrs from aws_all.aws_eks_cluster;"
    #"select queue_arn, queue_url, policy from aws_all.aws_sqs_queue where policy -> 'Statement' @> jsonb_build_array(jsonb_build_object('Effect', 'Allow', 'Principal', '*', 'Action', 'sqs:*'))"
    #"select topic_arn, policy from aws_all.aws_sns_topic where policy -> 'Statement' @> jsonb_build_array(jsonb_build_object('Effect', 'Allow', 'Principal', '*', 'Action', 'sns:*'))"
    #"select topic_arn, policy, account_id from aws_all.aws_sns_topic where policy -> 'Statement' @> jsonb_build_array(jsonb_build_object('Effect', 'Allow', 'Principal', '*', 'Action', 'sns:*'))"
    #"select topic_arn, policy, account_id from aws_all.aws_sns_topic where policy -> 'Statement' @> jsonb_build_array(jsonb_build_object('Effect', 'Allow', 'Principal', '*', 'Action', 'sns:*'))"
)

output_file="test.csv"

for query in "${queries[@]}"
do
    steampipe_query="steampipe query \"$query\" --output csv"
    echo "Executing: $steampipe_query"
    eval $steampipe_query >> $output_file
done

echo "Done!