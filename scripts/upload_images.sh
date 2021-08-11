while IFS= read -r line || [[ -n "$line" ]]
do
    echo "$line"
    svc=$(echo $line | awk -F '[/:]' '{ print $4 }')
    if [ $svc = "latest" ]
    then
        svc=$(echo $line | awk -F '[/:]' '{ print $3 }') 
    fi
    if [ $svc = "sense-billing-service" ]
    then
        svc="billing"
    fi
    newsvc="gcr.io/plainsight-public/images/$svc:1.2.0"
    docker pull $line
    docker tag $line $newsvc
    docker push $newsvc
done < "$1"
