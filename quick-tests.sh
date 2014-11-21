HASHH=''
WORDLIST='testlist.txt'
TESTCASES='test-cases.txt'

# this is pretty hacky, but I'm not exactly a bash pro lol

let FAIL_COUNT=0

function genhash {
	user=$(whoami)
	password=$1
	HASHH=$(echo -n "$user$password" | sha1sum | awk '{ print $1 }')
}

function test_dict {

	# store args in variables to make them easier to read
	intensity=$1
	password=$2
	user=$(whoami)

	# update the $HASHH global	
	genhash $password

	# display info about the test we are performing
	echo '    mode: dict'
	echo "    username: $user"
	echo "    intensity: $intensity" 
	echo ""
	echo "    expected result: $password"

	# run the smf-gremlin and store the result
	result=$(./smf-gremlin -m dict -i $intensity $user $HASHH $WORDLIST | \
	awk '{ print $3 }' | tail -n1)

	# report the result of the test
	echo "    actual result: $result"
	if [ $result == $password ]; then
		echo '     SUCCESS'
	else
		echo '     FAILURE'
		let FAIL_COUNT=$FAIL_COUNT+1 # we want to know how many tests failed
	fi
}

function test_brute {

	# store args in variables to make them easier to read
	charset=$1
	rmin=$2
	rmax=$3
	password=$4
	user=$(whoami)

	# update the $HASHH global	
	genhash $password

	# display info about the test we are performing
	echo '    mode: brute'
	echo "    username: $(whoami)"
	echo "    charset: $charset"
	echo ""
	echo "    expected result: $password"
	
	# run the smf-gremlin and store the result
	result=$(./smf-gremlin -m brute -c $charset -r $rmin $rmax $user $HASHH | \
	awk '{ print $3 }' | tail -n1)

	# report the result of the test
	if [ $result == $password ]; then
		echo '     SUCCESS'
	else
		echo '     FAILURE'
		let FAIL_COUNT=$FAIL_COUNT+1
	fi
}

let case_num=0
while read line; do

	# print the test case number
	echo "Case: $case_num"

	# set $mode to column 1 of line
	mode=$(echo "$line" | awk '{ print $1 }')
	
	# set $args to columns 2 through N
	mode_len=$(echo `expr length "$mode" + 2`)
	args=$(echo "$line" | cut -b $mode_len-)

	echo "mode: $mode"

	
	# call test_test() if mode is dict. else call test_brute()
	[ $mode == 'dict' ] && test_dict $args || test_brute $args

	# case_num++
	let case_num=$case_num+1

done < $TESTCASES

# display failure count
echo ""
echo "Failures: $FAIL_COUNT"

