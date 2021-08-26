if [ $2 == "" ]; then
    echo "No version specified"
    exit 1;
fi

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
    newsvc="gcr.io/plainsight-public/images/$svc:$2"
    docker pull $line
    docker tag $line $newsvc
    docker push $newsvc
done < "$1"
