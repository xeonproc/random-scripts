#!/bin/bash
#Version=2.4

### AWS Profile Generation with Organization Account List
### User Defined Variables ###
START_URL="https://[start-url].awsapps.com/start#/";
#START_URL="https://[start-url].awsapps.com/start#/";
REGION="us-east-1";

### AWS Profile Location Related Variables ###
AWS_PROFILE_DIR=${HOME}/.aws
PROFILEFILE="${AWS_PROFILE_DIR}/config"
CONNECTIONFILE_DIR="$HOME/.steampipe/config"
CONNECTIONFILE="${CONNECTIONFILE_DIR}/aws.spc"
IGNORE_FILE="${HOME}/.aws/.ignore" 
profilefile=${PROFILEFILE};
ROLE_NAME="redstone-secops-audit"
OUTPUT_FORMAT="json";

# Set defaults for profiles
defregion="${REGION}"
defoutput="json"
### End of Variable Decleration ###



DEFAULT_PROFILE=$(cat <<EOF
[default]
region=${defregion}
output=${defoutput}
credential_process = /opt/homebrew/bin/aws-vault exec -j default
EOF
)

## Check AWS CLI Version 
if [[ $(aws --version) == aws-cli/1* ]]; then
	echo "";
	echo "ERROR: $0 requires AWS CLI v2 or higher";
	echo "";
	exit 1
fi

## Check if AWS Profile Directory is not Exists, creating one
if [ ! -d ${AWS_PROFILE_DIR} ]; then
	echo "${AWS_PROFILE_DIR} is missing, creating...";
	mkdir ${AWS_PROFILE_DIR}
fi

## Check if AWS Profile is not Exists and no default profile
if [ ! -f ${PROFILEFILE} ]; then
	echo "Profile File missing, creating";
	touch ${PROFILEFILE};
	echo "${DEFAULT_PROFILE}" >> "$profilefile";
        echo "" >> "$profilefile";	
fi

## Create Default Profile for empty profile.
if [ ! -s ${PROFILEFILE} ]; then
	echo "Profile is empty, Creating Default Profile";
	echo "${DEFAULT_PROFILE}" >> "$profilefile";
        echo "" >> "$profilefile";	
fi
echo "";

## Take Backup of old profile file of there is any populated profile
cat ${PROFILEFILE} | grep "^sso_account_id =" >> /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Profile exists, creating backup";
	cp -p ${PROFILEFILE} ${PROFILEFILE}.bk
fi
####

## Create Connection dir and File if not exists
mkdir -p ${CONNECTIONFILE_DIR}

if [ ! -f ${CONNECTIONFILE} ]; then
	echo "AWS Connection Profile File missing, creating";
	touch ${CONNECTIONFILE};
fi

function update_profile2() {
i="1"
while true; do
	cat ${profilefile} | grep "^\[profile ${OLD_PROFILE}\]$" | awk '{print $2}' | sed 's/\]//g' >> /dev/null 2>&1
	if [ $? -eq 0 ]; then
		Profile_Name="${AC_Name}_AWS_Account_${i}"
		((j++))
		VIEW=$(echo "${VIEW}" | sed "s/${profilename}/${Profile_Name}/g")
		profilename="${Profile_Name}"
		break
	else
		break
	fi
done
}

function update_profile() {
j="1"
while true; do
	cat ${profilefile} | grep "^\[profile ${profilename}\]$" | awk '{print $2}' | sed 's/\]//g' >> /dev/null 2>&1
	if [ $? -eq 0 ]; then
		Profile_Name="${AC_Name}_AWS_Account_$j"
		sed -i "s/profile ${profilename}/profile ${Profile_Name}/g" ${profilefile}
		((j++))
		Profile_Name="${AC_Name}_AWS_Account_$j"
		VIEW=$(echo "${VIEW}" | sed "s/${profilename}/${Profile_Name}/g")
		profilename="${Profile_Name}"
		break
	else
		break
	fi
done
}

function add_profile() {
if [ -s ${PROFILEFILE} ]; then
	echo "" >> "$profilefile";
	echo "$VIEW" >> "$profilefile";
	echo "" >> "$profilefile";
else 
	echo "$VIEW" >> "$profilefile";
	echo "" >> "$profilefile";
fi
}

echo
echo "$0 will create all profiles with default values"

AWS_ORG_LIST=$(aws organizations list-accounts)
if [ $? -ne 0 ]; then
	echo "Failed"
	exit 1
else
	echo "Succeeded"
fi

declare -a created_profiles

echo "" >> "$profilefile"
echo "### The section below added by awsorgprofiletool TimeStamp: $(date +"%Y%m%d.%H%M")" >> "$profilefile"

echo "Working on aws organizations accounts lists";
AWS_ORG_LIST=$(aws organizations list-accounts)
AWS_ID=$(echo "${AWS_ORG_LIST}" | grep -o '"Id": "[^"]*' | grep -o '[^"]*$' | sort)

#echo "${AWS_ID}" | while read -r AC_ID;
for AC_ID in ${AWS_ID};
do
	echo "";
	echo "Processing for account ${AC_ID} ..."
	ORG_PROFILE=$(echo "${AWS_ORG_LIST}" | grep "\"\Id\"\: \"${AC_ID}"\" -A6)
	STATUS=$(echo "${AWS_ORG_LIST}" | grep "\"\Id\"\: \"${AC_ID}"\" -A6 | grep -o '"Status": "[^"]*' | grep -o '[^"]*$')
	AC_Name=$(echo "${AWS_ORG_LIST}" | grep "\"\Id\"\: \"${AC_ID}"\" -A6 | grep -o '"Name": "[^"]*' | grep -o '[^"]*$' | sed 's/[|]//g' | sed 's/  */_/g' | sed 's/\./_/g' | sed 's/-/_/g')
	profilename=${AC_Name}

	if [[ "${STATUS}" != "ACTIVE" ]]; then
		DELETE_PROFILE=$(cat "$profilefile" | grep "${AC_ID}" -A1 -B2 | grep -e "^\[profile" | awk '{$1="";print}' | sed 's/\]//g'| sed 's/^[[:space:]]//g')
		if [ ! -z ${DELETE_PROFILE} ]; then
			sed -i "/profile ${DELETE_PROFILE}/,+3d" ${profilefile}
			echo "	 ${STATUS} profile ${AC_Name}" removed from ${profilefile};
			continue
		fi
		echo "	 Ignoring ${AC_Name} as ${STATUS} account...";
		continue
	fi

VIEW=$(cat <<EOF
[profile ${profilename}]
region=us-east-1
source_profile=default
role_arn=arn:aws:iam::${AC_ID}:role/${ROLE_NAME}
#output=${OUTPUT_FORMAT}
EOF
)
	PROFILE_ID_COUNT=$(cat "$profilefile" | grep -ce "\[${AC_ID}\]" -A1 -B2) >> /dev/null 2>&1

	if [[ ${PROFILE_ID_COUNT} -eq 1 ]]; then
		OLD_PROFILE_VIEW=$(cat "$profilefile" | grep -e "\[${AC_ID}\]" -A1 -B2)
		if [ "${OLD_PROFILE_VIEW}" == "${VIEW}" ]; then
#			echo "  Profile for ${profilename}, Account_Id: ${AC_ID} already exists"
			continue
		else
			OLD_PROFILE=$(echo "${OLD_PROFILE_VIEW}" | grep -e "^\[profile" | awk '{$1="";print}' | sed 's/\]//g'| sed 's/^[[:space:]]//g' | sed 's/[|]//g' | sed 's/  */_/g' | sed 's/\./_/g' | sed 's/-/_/g')
#			echo -n "  Another Profile Detected With same Name, Updating ${AC_ID}... "
			profilename="${OLD_PROFILE}"

			update_profile2 ## Function call to update profile

#			echo "Succeeded"
			continue
		fi
	elif [[ $(cat "$profilefile" | grep -ce "^\[profile ${profilename}\]$") -ne 0 ]]; then
		OLD_PROFILE=${AC_Name}

		update_profile
	fi

	echo -n "  Creating New Profile $profilename... "
	add_profile ## Function call to add profile

	echo "Succeeded"

	created_profiles+=($profilename)
done

echo "" >> "$profilefile"
#echo "### The section above added by awsssoprofiletool.sh TimeStamp: $(date +"%Y%m%d.%H%M")" >> "$profilefile"

echo
echo "Processing complete."
echo

cat $profilefile | awk '!NF {if (++n <= 1) print; next}; {n=0;print}' > ${profilefile}_$(date +"%Y%m%d")
mv ${profilefile}_$(date +"%Y%m%d") $profilefile

if [[ "${#created_profiles[@]}" -eq 0 ]]; then
	echo "";
	echo "	No Changes Found, There are no New Profile in AWS!!";
	echo "";
### Delete Unnecessery Last Lines

	if [[ -z $(sed -n '$p' ${profilefile}) ]]; then >> /dev/null 2>&1
		sed -i '$d' $profilefile
	fi

	tail -n1 $profilefile | grep "The section above added by" >> /dev/null 2>&1
	if [ $? -eq 0 ]; then
		sed -i '$d' $profilefile
	fi

	if [[ -z $(sed -n '$p' ${profilefile}) ]]; then >> /dev/null 2>&1
		sed -i '$d' $profilefile
	fi

	if [[ -z $(sed -n '$p' ${profilefile}) ]]; then >> /dev/null 2>&1
		sed -i '$d' $profilefile
	fi

	tail -n1 $profilefile | grep "The section below added by" >> /dev/null 2>&1
	if [ $? -eq 0 ]; then
		sed -i '$d' $profilefile
	fi
else
	echo " Added the following profiles to $profilefile:"
	echo
	for i in "${created_profiles[@]}"
	do
		echo "$i"
	done
fi

## Process .ignore profile
if [ -f ${IGNORE_FILE} ]; then

echo "";
echo "Processing Ignore Profiles...";

declare -a ignored_profiles

IGNORE_PROFILES=$(cat ${IGNORE_FILE} | grep "^\[profile" | sed 's/\]//g' | sed 's/\[//g' | sed 's/^[[:space:]]//g' | awk '{print $2}') >> /dev/null 2>&1
for IP in ${IGNORE_PROFILES}; do
	IP_PROFILE=$(cat ${IGNORE_FILE} | grep "^\[profile ${IP}" -A3)
	IP_AC_ID=$(cat ${IGNORE_FILE} | grep "^\[profile ${IP}" -A3 | grep "role_arn=" | cut -d':' -f 4 | sed 's/\]//g' | sed 's/\[//g' | sed 's/^[[:space:]]//g')
	OLD_PROFILE=$(cat "$profilefile" | grep -e "${IP_AC_ID}" -A1 -B2 | grep "profile"| awk '{$1="";print}' | sed 's/\]//g'| sed 's/^[[:space:]]//g')
	ignored_profiles+=("$OLD_PROFILE")
done
fi

if [[ "${#ignored_profiles[@]}" -ne 0 ]]; then
	echo "  Ignored Profiles are..";
	for ips in "${ignored_profiles[@]}"
	do
		echo "	${ips}"
	done
fi

echo "";

## AWS Config Profiles for Steampipe
AWS_PROFILES=$(cat ${profilefile} | grep "^\[profile" | awk '{print $2}' | sed 's/\]//g' | sort)
for ips in "${ignored_profiles[@]}"
do
	AWS_PROFILES=$(echo "${AWS_PROFILES}" | grep -v "^${ips}$");
done

rm -f ${CONNECTIONFILE}
for SC in ${AWS_PROFILES}; do

CONNECTION_VIEW=$(cat <<EOF
connection "aws_${SC}" {
plugin = "aws"
profile = "${SC}"
regions = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
ignore_error_codes = ["AccessDenied", "AccessDeniedException", "NotAuthorized", "UnauthorizedOperation", "UnrecognizedClientException", "AuthorizationError", "InvalidInstanceId", "NoCredentialProviders", "operation", "timeout", "InvalidParameterValue"]
}
EOF
)
	echo "$CONNECTION_VIEW" >> "$CONNECTIONFILE";
	echo "" >> "$CONNECTIONFILE";
done

AGGREGATOR_VIEW=$(cat <<EOF
connection "aws_all" {
  type        = "aggregator"
  plugin      = "aws"
  connections = ["aws_*"]
}
EOF
)
echo "$AGGREGATOR_VIEW" >> "$CONNECTIONFILE"
###########
echo "";
echo "AWS Organization Accounts Profile Sync Task Completed.";
echo "";

exit 0
##### End of Script Execution #####
