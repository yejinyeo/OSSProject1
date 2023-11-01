#!/bin/bash

ITEM_F=$1
DATA_F=$2
USER_F=$3

# 사용자 정보 표시
echo "--------------------------"
echo "User Name: Yeo Yejin"
echo "Student Number: 12223557"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item'"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do
    echo -n "Enter your choice [1-9]: "
    read number

    case $number in
        1)
	    echo
            echo -n "Please enter the 'movie id’(1~1682): "
            read movie_id
	    echo
            awk -F"|" -v id=$movie_id '$1 == id { print $0 }' $ITEM_F
	    echo
            ;;
	
	2)
	    echo
            echo -n "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n): "
            read response
	    echo
            if [ "$response" == "y" ]; then
                awk -F"|" '$7 == "1" {print $1, $2}' $ITEM_F | sort -n | head -10
	    echo
            fi
            ;;

        3)
	    echo
            echo -n "Please enter the 'movie id’(1~1682): "
            read movie_id
	    echo
            avg_rating=$(awk -F"\t" -v id=$movie_id '$2 == id { sum+=$3; count++ } END { if (count > 0) printf "%.5f", sum/count; else print 0 }' $DATA_F)
            echo "average rating of $movie_id: $avg_rating"
	    echo
            ;;

	4)
	    echo
            echo -n "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n): "
            read response
	    echo
            if [ "$response" == "y" ]; then
                awk -F"|" 'BEGIN {OFS="|"} { $5=""; print $0 }' $ITEM_F | head -10
	    echo
            fi
            ;;

	5)
	    echo
            echo -n "Do you want to get the data about users from ‘u.user’?(y/n): "
            read response
	    echo
            if [ "$response" == "y" ]; then
                awk -F"|" 'NR <= 10 { gender = ($3 == "M") ? "male" : "female"; print "user", $1, "is", $2, "years old", gender, $4 }' $USER_F
	    echo
            fi
            ;;

	6)
	    echo
            echo -n "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n): "
            read response
	    echo
            if [ "$response" == "y" ]; then
                tail -n 10 $ITEM_F | awk -F"|" '{
                    split($3, date, "-")
                    newDate = sprintf("%4d%02d%02d", date[3], (index("JanFebMarAprMayJunJulAugSepOctNovDec", date[2]) + 2) / 3, date[1])
                    $3=newDate;
                    print
                }' OFS="|"
	    echo
            fi
            ;;	

	7)
	    echo
            echo -n "Please enter the ‘user id’(1~943): "
            read user_id
	    echo
            awk -v id=$user_id -F"\t" '$1 == id {print $2}' $DATA_F | sort -n | tr '\n' '|' | sed 's/|$//'
            echo
	    echo

            awk -v id=$user_id -F"\t" '$1 == id {print $2}' $DATA_F | sort -n | head -10 | while read movie_id; do
                movie_title=$(awk -v m_id=$movie_id -F"|" '$1 == m_id {print $2}' $ITEM_F)
                echo "$movie_id|$movie_title"
            done
	    echo
            ;;


	 8)
	    echo
            echo -n "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): "
            read response
	    echo

            if [[ "$response" == "y" ]]; then
                prog_ids=$(awk -F'|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}' $USER_F)
                awk -F'\t' -v users="$prog_ids" 'BEGIN {split(users, arr, " ")}
		    { for (i in arr) if ($1 == arr[i]) { sum[$2] += $3; count[$2]++ } }
		    END {
		        for (movie in sum) {
			    avg = sum[movie]/count[movie];
			    if (avg == int(avg))
			        printf "%s %d\n", movie, avg;
			    else
				printf "%s %.5f\n", movie, avg;
			}
		    }' $DATA_F | sort -k1,1n | awk '{ printf "%s ", $1; if ($2 ~ /\.0+$/) { print int($2); } else { gsub(/0+$/, "", $2); print $2; } }'	
	    echo
    	    fi
            ;;


        9)
            echo "Bye!"
            exit 0
            ;;

        *)
            echo "Invalid number."
	    echo
            ;;

    esac
done
