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
echo "Failures: $FAILURE_COUNT"

#echo 'Case 0:'
#
#	echo 'mode: dict'
#	echo 'username: someuser'
#	echo 'intensity: normal'
#
#	hashh=
#	./smf-gremlin -m dict -i normal someuser
#
#	Expected result: 
#	Actual result:
#
#Case 1:
#	
#	mode: dict
#	intensity: normal
#	username: someuser
#	
#
#	Expected result: yellow
#	Actual result: 
#
#Case 2:
#
#	mode: dict
#	username: someuser
#	intensity: normal
#
#	Expected result: Oranges
#
#Case 3:
#
#	mode: dict
#	username: someuser
#	intensity: intense
#
#	Expected result: 
#	Actual result:
#
#Case 4:
#
#	mode: dict
#	intensity: intense
#	username: someuser
#
#	Expected result: yellow
#	Actual result: 
#
#Case 5:
#
#	mode: dict
#	username: someuser
#	intensity: intense
#
#	Expected result: Oranges
#
#Case 6:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#
#	Expected result: 
#	Actual result:
#
#Case 7:
#
#	mode: dict
#	intensity: insane
#	username: someuser
#
#	Expected result: yellow
#	Actual result: 
#
#Case 8:
#
#	mode: dict
#	intensity: insane
#
#	Expected result: Oranges
#	Actual result: 
#
#Case 9:
#
#	mode: dict
#	username: someuser
#	intensity: intense
#
#	Expected result: Grapefruit20
#	Actual result: 
#	
#
#Case 10:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#
#	Expected result: Grapefruit20
#	Actual result: 
#
#Case 9:
#
#	mode: dict
#	username: someuser
#	intensity: intense
#
#	Expected result: hardboiled8
#	Actual result: 
#	
#
#Case 10:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#
#	Expected result: hardboiled8
#	Actual result: 
#
#Case 11:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#	
#	Expected result: sug@rcub3z
#	Actual result:
#
#Case 12:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#	
#	Expected result: Sug@rcub3z
#	Actual result:
#
#
#Case 13:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#	
#	Expected result: p1zza@ndwings38
#	Actual result:
#
#Case 14:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#	
#	Expected result: W33kendNach0s423
#	Actual result:
#
#Case 14:
#
#	mode: dict
#	username: someuser
#	intensity: insane
#	
#	Expected result: Cak3s0928
#	Actual result:
#
#
#Case 15:
#
#	mode: brute
#	username: someuser
#	charset: all
#	range: 1 5
#
#	Expected result: 8&cA$
#	Actual result:
#
#Case 16:
#
#	mode: brute
#	username: someuser
#	charset: alnum
#	range: 1 4
#
#	Expected result: f5Az
#	Actual result:
#
#Case 17:
#
#	mode: brute
#	username: someuser
#	charset: alnum
#	range: 2 6
#
#	Expected result: f5Az
#	Actual result:
#
#Case 18:
#
#	mode: brute
#	username: someuser
#	charset: alpha
#	range: 2 6
#
#	Expected result: nEWssC
#	Actual result:
#
#Case 19:
#
#	mode: brute
#	username: someuser
#	charset: lower
#	range: 1 4
#
#	Expected result: meud
#	Actual result:
#
#Case 19:
#
#	mode: brute
#	username: someuser
#	charset: digit
#	range: 1 8
#
#	Expected result: 86341532
#	Actual result:
#
#Case 20:
#
#	mode: brute
#	username: someuser
#	charset: digit
#	range: unspecified
#
#	Expected result: 86341532
#	Actual result:
#
#Case 21:
#
#	mode: brute
#	username: someuser
#	charset: symbol
#	range: 1 4
#

#	Expected result: &%)$
#	Actual result:
